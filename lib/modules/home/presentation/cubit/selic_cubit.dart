import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/modules/metrics/domain/entites/metric.dart';
import 'package:real_calc/modules/metrics/use_cases/selic/i_selic_use_case.dart';

part 'selic_state.dart';

class SelicCubit extends Cubit<SelicState> {
  final ISelicUseCase _useCase;

  SelicCubit(this._useCase) : super(SelicInitial());

  Future<void> load() async {
    final previousMetric = state.metric;
    emit(SelicLoading(previousMetric));

    final result = await _useCase.getSelicRate();
    result.fold(
      (error) => emit(SelicError(error, previousMetric)),
      (metric) => emit(SelicLoaded(metric)),
    );
  }

  Future<void> retry() => load();
}
