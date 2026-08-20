import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:real_calc/core/routes/app_routes.dart';
import 'package:real_calc/modules/regular_deposits/domain/usecase/deposit_calculator.dart';
import 'package:real_calc/modules/regular_deposits/domain/validation/regular_deposits_validator.dart';
import 'package:real_calc/modules/regular_deposits/presentation/cubit/regular_deposits_cubit.dart';
import 'package:real_calc/modules/regular_deposits/presentation/pages/page.dart';

class RegularDepositsModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton(RegularDepositsValidator.new);
    i.addLazySingleton(DepositCalculatorUseCase.new);
    i.add(RegularDepositsCubit.new);
  }

  @override
  void routes(r) {
    r.child(
      AppRoutes.base,
      child: (_) => BlocProvider(
        create: (_) => Modular.get<RegularDepositsCubit>(),
        child: const RegularDepositsPage(),
      ),
    );
  }
}
