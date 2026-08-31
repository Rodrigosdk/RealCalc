import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:real_calc/modules/future_value/presentation/pages/page.dart';

import '../../core/routes/app_routes.dart';
import 'domain/usecase/calculate_compound_interest_use_case.dart';
import 'domain/validation/future_value_validator.dart';
import 'presentation/cubit/future_value_cubit.dart';

class FutureValueModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton(FutureValueValidator.new);
    i.addLazySingleton(CalculateCompoundInterestUseCase.new);
    i.add(FutureValueCubit.new);
  }

  @override
  void routes(r) {
    r.child(
      AppRoutes.base,
      child: (_) => BlocProvider(
        create: (_) => Modular.get<FutureValueCubit>(),
        child: const FutureValuePage(),
      ),
    );
  }
}
