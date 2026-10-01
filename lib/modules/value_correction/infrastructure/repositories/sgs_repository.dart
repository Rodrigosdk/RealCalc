import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/core/seed_works/network.dart';
import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/shared/network/response/sgs_response_network.dart';

import '../../domain/entites/series_point.dart';
import '../../domain/enum/correction_index.dart';
import '../../domain/repositories/i_correction_series_repository.dart';

class SgsRepository implements ICorrectionSeriesRepository {
  static const String _endpoint = 'https://api.bcb.gov.br/dados/serie/bcdata.sgs';

  final Network _network;

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
    final url = '$_endpoint.${index.sgsCode}/dados?formato=json'
        '&dataInicial=${_formatDate(start)}&dataFinal=${_formatDate(end)}';

    final response = await _network.get<List<dynamic>>(url);

    return response.fold(
      (error) => FailureResult<ErrorMessages, List<SeriesPoint>>(error),
      (data) {
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

        return SuccessResult<ErrorMessages, List<SeriesPoint>>(points);
      },
    );
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
