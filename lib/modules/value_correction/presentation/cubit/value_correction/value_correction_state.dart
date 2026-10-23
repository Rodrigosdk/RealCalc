import 'package:real_calc/modules/value_correction/domain/entites/value_correction.dart';

sealed class ValueCorrectionState {
  const ValueCorrectionState();
}

final class ValueCorrectionInitial extends ValueCorrectionState {}

final class ValueCorrectionLoading extends ValueCorrectionState {}

final class ValueCorrectionCalculated extends ValueCorrectionState {
  final ValueCorrection result;

  const ValueCorrectionCalculated(this.result);
}

final class ValueCorrectionError extends ValueCorrectionState {
  final String message;

  const ValueCorrectionError(this.message);
}
