part of 'regular_deposits_cubit.dart';

sealed class RegularDepositsState {}

final class RegularDepositsInitial extends RegularDepositsState {}

class RegularDepositsCalculated extends RegularDepositsState {
  final FinancialCalculation value;
  final FinancialCalculationTarget calculatedField;

  RegularDepositsCalculated(this.value, this.calculatedField);
}

class RegularDepositsLoading extends RegularDepositsState {}

class RegularDepositsError extends RegularDepositsState {
  final String? message;

  RegularDepositsError(this.message);
}
