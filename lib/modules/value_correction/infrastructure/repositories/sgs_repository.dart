import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/core/seed_works/network.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/shared/network/response/sgs_response_network.dart';

import '../../domain/entites/series_point.dart';
import '../../domain/enum/correction_index.dart';
import '../../domain/enum/date_granularity.dart';
import '../../domain/repositories/i_correction_series_repository.dart';

class SgsRepository implements ICorrectionSeriesRepository {
  static const String _endpoint = 'https://api.bcb.gov.br/dados/serie/bcdata.sgs';
  static const int _dailySeriesWindowLimitYears = 10;

  final Network _network;
  final Map<String, Result<ErrorMessages, List<SeriesPoint>>> _cache = {};

  SgsRepository(this._network);

  @override
  Future<Result<ErrorMessages, List<SeriesPoint>>> correctionSeries() async {
    final now = DateTime.now();
    final start = DateTime(now.year - 1, now.month, now.day);
    return getSeries(
      index: CorrectionIndex.ipca,
      start: start,
      end: now,
    );
  }

  @override
  Future<Result<ErrorMessages, List<SeriesPoint>>> getSeries({
    required CorrectionIndex index,
    required DateTime start,
    required DateTime end,
  }) async {
    final cacheKey = _cacheKey(index, start, end);
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    final result = _shouldSplitDailySeries(index, start, end)
        ? await _getSeriesInDailyWindows(index: index, start: start, end: end)
        : await _getSeriesSingleWindow(index: index, start: start, end: end);

    if (result.isSuccess && index.granularity == DateGranularity.day) {
      final points = result.getOrNull() ?? const <SeriesPoint>[];
      final validationError = _validateLastAvailableMonth(points, end);
      if (validationError != null) {
        final failure = FailureResult<ErrorMessages, List<SeriesPoint>>(validationError);
        _cache[cacheKey] = failure;
        return failure;
      }
    }

    _cache[cacheKey] = result;
    return result;
  }

  bool _shouldSplitDailySeries(CorrectionIndex index, DateTime start, DateTime end) {
    final endDate = end.isAfter(start) ? end : start;
    final windowStart = DateTime(start.year, start.month, start.day);
    final windowEnd = DateTime(windowStart.year + _dailySeriesWindowLimitYears, windowStart.month, windowStart.day);
    return index.granularity == DateGranularity.day && endDate.isAfter(windowStart.add(const Duration(days: 3652))) && endDate.isAfter(windowEnd);
  }

  Future<Result<ErrorMessages, List<SeriesPoint>>> _getSeriesSingleWindow({
    required CorrectionIndex index,
    required DateTime start,
    required DateTime end,
  }) async {
    final response = await _network.get<List<dynamic>>(_buildUrl(index, start, end));

    return response.fold(
      (error) => FailureResult<ErrorMessages, List<SeriesPoint>>(error),
      (data) {
        final points = _parsePoints(data);
        return SuccessResult<ErrorMessages, List<SeriesPoint>>(points);
      },
    );
  }

  Future<Result<ErrorMessages, List<SeriesPoint>>> _getSeriesInDailyWindows({
    required CorrectionIndex index,
    required DateTime start,
    required DateTime end,
  }) async {
    final mergedPoints = <SeriesPoint>[];
    DateTime cursor = DateTime(start.year, start.month, start.day);

    while (!cursor.isAfter(end)) {
      final windowEnd = _nextWindowEnd(cursor, end);
      final windowKey = _cacheKey(index, cursor, windowEnd);
      final windowResult = _cache[windowKey] ?? await _getSeriesSingleWindow(
        index: index,
        start: cursor,
        end: windowEnd,
      );
      _cache[windowKey] = windowResult;

      if (windowResult.isError) {
        return windowResult;
      }

      final points = windowResult.getOrNull() ?? const <SeriesPoint>[];
      for (final point in points) {
        if (mergedPoints.any((candidate) => _sameDate(candidate.date, point.date))) {
          continue;
        }
        mergedPoints.add(point);
      }

      if (windowEnd == end) break;
      cursor = windowEnd.add(const Duration(days: 1));
    }

    mergedPoints.sort((a, b) => a.date.compareTo(b.date));

    if (index.granularity == DateGranularity.day) {
      final validationError = _validateLastAvailableMonth(mergedPoints, end);
      if (validationError != null) {
        return FailureResult<ErrorMessages, List<SeriesPoint>>(validationError);
      }
    }

    return SuccessResult<ErrorMessages, List<SeriesPoint>>(mergedPoints);
  }

  String _buildUrl(CorrectionIndex index, DateTime start, DateTime end) {
    return '$_endpoint.${index.sgsCode}/dados?formato=json'
        '&dataInicial=${_formatDate(start)}&dataFinal=${_formatDate(end)}';
  }

  List<SeriesPoint> _parsePoints(List<dynamic> data) {
    final points = <SeriesPoint>[];
    for (final item in data) {
      if (item is! Map<String, dynamic>) continue;

      final network = SgsResponseNetwork.fromJson(item);
      final rawValue = network.valor;
      if (rawValue == null || rawValue.trim().isEmpty) continue;

      final parsedValue = double.tryParse(rawValue.replaceAll(',', '.'));
      if (parsedValue == null) continue;

      final parsedDate = network.data;
      if (parsedDate == null || parsedDate.trim().isEmpty) continue;

      final date = _parseDate(parsedDate);
      if (date == null) continue;

      points.add(SeriesPoint(date: date, value: parsedValue));
    }

    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  ErrorMessages? _validateLastAvailableMonth(List<SeriesPoint> points, DateTime end) {
    if (points.isEmpty) return null;

    final lastPointMonth = DateTime(points.last.date.year, points.last.date.month, 1);
    final requestedMonth = DateTime(end.year, end.month, 1);

    if (lastPointMonth.isBefore(requestedMonth)) {
      return SeriesUnavailableError(lastPointMonth);
    }

    return null;
  }

  DateTime _nextWindowEnd(DateTime start, DateTime end) {
    final maxWindowEnd = DateTime(
      start.year + _dailySeriesWindowLimitYears,
      start.month,
      start.day,
    );

    if (maxWindowEnd.isAfter(end)) {
      return end;
    }

    return maxWindowEnd;
  }

  bool _sameDate(DateTime left, DateTime right) {
    return left.year == right.year && left.month == right.month && left.day == right.day;
  }

  String _cacheKey(CorrectionIndex index, DateTime start, DateTime end) {
    return '${index.sgsCode}|${_formatDate(start)}|${_formatDate(end)}';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  DateTime? _parseDate(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return null;

    return DateTime(year, month, day);
  }
}
