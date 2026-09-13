part of 'financing_cubit.dart';

sealed class FinancingState {}

final class FinancingInitial extends FinancingState {}

class FinancingCalculated extends FinancingState {
  final FinancialCalculation value;
  final FinancialCalculationTarget calculatedField;

  FinancingCalculated(this.value, this.calculatedField);
}

class FinancingLoading extends FinancingState {
}

class FinancingError extends FinancingState {
  final String? message;

  FinancingError(this.message);
}