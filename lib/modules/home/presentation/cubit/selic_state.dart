part of 'selic_cubit.dart';

sealed class SelicState {
  final Metric? metric;

  const SelicState([this.metric]);
}

final class SelicInitial extends SelicState {
  const SelicInitial();
}

final class SelicLoading extends SelicState {
  const SelicLoading([super.metric]);
}

final class SelicLoaded extends SelicState {
  const SelicLoaded(super.metric);
}

final class SelicError extends SelicState {
  final ErrorMessages error;

  const SelicError(this.error, [super.metric]);
}