import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entites/period.dart';
import '../../../domain/entites/value_correction.dart';
import '../../../domain/enum/correction_index.dart';
import '../../../domain/repositories/i_correction_series_repository.dart';
import '../../../domain/validation/value_correction_validation.dart';
import '../../../use_cases/i_calculate_value_correction.dart';
import 'value_correction_state.dart';

class ValueCorrectionCubit extends Cubit<ValueCorrectionState> {
  final ICorrectionSeriesRepository _seriesRepository;
  final ICalculateValueCorrection _calculateValueCorrection;
  final ValueCorrectionValidation _validation;

  ValueCorrectionCubit(this._seriesRepository, this._calculateValueCorrection)
    : _validation = ValueCorrectionValidation(),
      super(ValueCorrectionInitial());

  Future<void> calculate({
    required CorrectionIndex index,
    required String initialDate,
    required String finalDate,
    required String percentage,
    required String value,
  }) async {
    emit(ValueCorrectionLoading());

    final start = _parseDate(initialDate, index);
    final end = _parseDate(finalDate, index);
    if (start == null || end == null) {
      emit(const ValueCorrectionError('Informe um período válido.'));
      return;
    }

    final parsedPercentage = _resolvePercentage(index, percentage);
    final originalValue = _parseNumber(value);
    final params = ValueCorrection(
      index: index.sgsCode,
      period: Period(initial: start, end: end),
      percentage: parsedPercentage,
      originalValue: originalValue,
      factor: 1,
      adjustedValue: originalValue,
      variation: 0,
    );

    final validationResult = _validation.validate(params);
    final validationFailure = validationResult.getErrorOrNull();
    if (validationFailure != null) {
      emit(
        ValueCorrectionError(
          validationFailure.message.first.message,
        ),
      );
      return;
    }

    final seriesResult = await _seriesRepository.getSeries(
      index: index,
      start: start,
      end: end,
    );

    final seriesError = seriesResult.getErrorOrNull();
    if (seriesError != null) {
      emit(ValueCorrectionError(seriesError.message));
      return;
    }

    final result = _calculateValueCorrection.call(
      params: params,
      series: seriesResult.getOrNull() ?? const [],
      type: index.kind,
    );

    result.fold(
      (failure) => emit(
        ValueCorrectionError(
          failure.message.first.message,
        ),
      ),
      (value) => emit(ValueCorrectionCalculated(value)),
    );
  }

  void reset() => emit(ValueCorrectionInitial());

  DateTime? _parseDate(String value, CorrectionIndex index) {
    final parts = value.trim().split('/');
    if (index.granularity.name == 'month') {
      if (parts.length != 2) return null;
      final month = int.tryParse(parts[0]);
      final year = int.tryParse(parts[1]);
      if (month == null || year == null || month < 1 || month > 12) return null;
      return DateTime(year, month, 1);
    }

    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    if (month < 1 || month > 12 || day < 1) return null;

    final parsed = DateTime(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }
    return parsed;
  }

  double _resolvePercentage(CorrectionIndex index, String value) {
    if (index != CorrectionIndex.cdi) return 0;

    final parsed = _parseNumber(value);
    if (parsed == null) return 100;
    return parsed > 0 ? parsed : 100;
  }

  double? _parseNumber(String value) {
    final normalized = value.trim().replaceAll('.', '').replaceAll(',', '.');
    return normalized.isEmpty ? null : double.tryParse(normalized);
  }
}
