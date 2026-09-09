part of 'financing_cubit.dart';

sealed class FinancingState {}

final class FinancingInitial extends FinancingState {}

class FinancingCalculated extends FinancingState {
  final FinancialCalculation value;

  FinancingCalculated(this.value);
}

class FinancingLoading extends FinancingState {
}

class FinancingError extends FinancingState {
  final String? message;

  FinancingError(this.message);
}