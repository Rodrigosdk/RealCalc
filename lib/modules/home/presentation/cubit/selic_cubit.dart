import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/modules/metrics/domain/entites/metric.dart';
import 'package:real_calc/modules/metrics/domain/enum/selic_period.dart';
import 'package:real_calc/modules/metrics/use_cases/selic/i_selic_use_case.dart';

part 'selic_state.dart';

class SelicCubit extends Cubit<SelicState> {
  final ISelicUseCase _useCase;
  final _metrics = <SelicPeriod, Metric>{};
  var _request = 0;

  SelicCubit(this._useCase) : super(const SelicInitial());

  Future<void> load() => _fetch(state.period);

  Future<void> retry() => load();

  Future<void> changePeriod(SelicPeriod period) async {
    if (period == state.period) return;
    await _fetch(period);
  }

  Future<void> _fetch(SelicPeriod period) async {
    final request = ++_request;
    final own = _metrics[period];
    final shown = own ?? state.metric;
    final foreign = own == null && shown != null;
    emit(SelicLoading(shown, period, foreign));

    final result = await _useCase.getSelic(period);
    // Uma troca de período mais recente já está a caminho.
    if (isClosed || request != _request) return;

    result.fold((error) => emit(SelicError(error, shown, period, foreign)), (
      metric,
    ) {
      _metrics[period] = metric;
      emit(SelicLoaded(metric, period));
    });
  }
}
