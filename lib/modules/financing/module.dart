import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:real_calc/modules/financing/presentation/pages/page.dart';

import '../../core/routes/app_routes.dart';
import 'domain/usecases/calculate_compound_interest_use_case.dart';
import 'domain/validation/financing_validator.dart';
import 'presentation/cubit/financing_cubit.dart';

class FinancingModule extends Module {
  @override
  void binds(i) {
    // i.addLazySingleton(FinancingRepository.new);
    i.addLazySingleton(FinancingValidator.new);
    i.addLazySingleton(CalculateCompoundInterestUseCase.new);
    i.add(FinancingCubit.new);
  }

  @override
  void routes(r) {
    r.child(
      AppRoutes.home,
      child: (_) => BlocProvider(
        create: (_) => Modular.get<FinancingCubit>(),
        child: const FinancingPage(),
      ),
    );
  }
}
