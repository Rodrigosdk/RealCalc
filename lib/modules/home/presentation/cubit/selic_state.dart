part of 'selic_cubit.dart';

sealed class SelicState {
  final Metric? metric;
  final SelicPeriod period;

  /// `metric` é de outro período: a taxa vale, mas o gráfico não.
  final bool chartUnavailable;

  const SelicState([
    this.metric,
    this.period = SelicPeriod.months12,
    this.chartUnavailable = false,
  ]);

  bool get offline => this is SelicError || (metric?.offline ?? false);
}

final class SelicInitial extends SelicState {
  const SelicInitial();
}

final class SelicLoading extends SelicState {
  const SelicLoading([super.metric, super.period, super.chartUnavailable]);
}

final class SelicLoaded extends SelicState {
  const SelicLoaded(Metric super.metric, [super.period]);
}

final class SelicError extends SelicState {
  final ErrorMessages error;

  const SelicError(
    this.error, [
    super.metric,
    super.period,
    super.chartUnavailable,
  ]);
}
