part of 'future_value_cubit.dart';

sealed class FutureValueState {}

final class FutureValueInitial extends FutureValueState {}

class FutureValueCalculated extends FutureValueState {
  final FinancialCalculation value;

  FutureValueCalculated(this.value);
}

class FutureValueLoading extends FutureValueState {}

class FutureValueError extends FutureValueState {
  final String? message;

  FutureValueError(this.message);
}
