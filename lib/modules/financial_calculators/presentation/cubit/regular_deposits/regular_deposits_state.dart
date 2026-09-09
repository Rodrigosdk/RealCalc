part of 'regular_deposits_cubit.dart';

sealed class RegularDepositsState {}

final class RegularDepositsInitial extends RegularDepositsState {}

class RegularDepositsCalculated extends RegularDepositsState {
  final FinancialCalculation value;

  RegularDepositsCalculated(this.value);
}

class RegularDepositsLoading extends RegularDepositsState {}

class RegularDepositsError extends RegularDepositsState {
  final String? message;

  RegularDepositsError(this.message);
}
