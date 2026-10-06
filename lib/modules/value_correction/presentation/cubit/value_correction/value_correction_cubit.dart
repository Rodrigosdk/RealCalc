import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/enum/correction_index.dart';
import '../../../domain/repositories/i_correction_series_repository.dart';
import '../../../use_cases/i_calculate_value_correction.dart';
import 'request_parsing/i_value_correction_request_parser.dart';
import 'request_validation/i_value_correction_request_validator.dart';
import 'value_correction_state.dart';

class ValueCorrectionCubit extends Cubit<ValueCorrectionState> {
  final ICorrectionSeriesRepository _seriesRepository;
  final ICalculateValueCorrection _calculateValueCorrection;
  final IValueCorrectionRequestParser _requestParser;
  final IValueCorrectionRequestValidator _requestValidator;

  ValueCorrectionCubit(
    this._seriesRepository,
    this._calculateValueCorrection,
    this._requestParser,
    this._requestValidator,
  ) : super(ValueCorrectionInitial());

  Future<void> calculate({
    required CorrectionIndex index,
    required String initialDate,
    required String finalDate,
    required String percentage,
    required String value,
  }) async {
    emit(ValueCorrectionLoading());

    final params = _requestParser.parse(
      index: index,
      initialDate: initialDate,
      finalDate: finalDate,
      percentage: percentage,
      value: value,
    );
    if (params == null) {
      emit(const ValueCorrectionError('Informe um período válido.'));
      return;
    }

    final validationMessage = _requestValidator.validate(
      index: index,
      params: params,
    );
    if (validationMessage != null) {
      emit(ValueCorrectionError(validationMessage));
      return;
    }

    final seriesResult = await _seriesRepository.getSeries(
      index: index,
      start: params.period.initial,
      end: params.period.end,
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
      (failure) => emit(ValueCorrectionError(failure.message.first.message)),
      (value) => emit(ValueCorrectionCalculated(value)),
    );
  }

  void reset() => emit(ValueCorrectionInitial());
}
