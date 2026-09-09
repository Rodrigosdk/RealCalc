import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:real_calc/modules/app_module.dart';
import 'package:real_calc/modules/financial_calculators/presentation/pages/future_value_page.dart';
import 'package:real_calc/modules/financial_calculators/use_case/future_value/i_calculate_future_value.dart';
import 'package:real_calc/modules/financial_calculators/use_case/regular_deposits/i_calculate_deposit.dart';

import '../../core/routes/app_routes.dart';
import 'presentation/cubit/financing/financing_cubit.dart';
import 'presentation/cubit/future_value/future_value_cubit.dart';
import 'presentation/cubit/regular_deposits/regular_deposits_cubit.dart';
import 'presentation/pages/financing_page.dart';
import 'presentation/pages/regular_deposits_page.dart';
import 'use_case/financing/calculate_financing.dart';
import 'use_case/financing/i_calculate_financing.dart';
import 'use_case/future_value/calculate_future_value.dart';
import 'use_case/regular_deposits/calculate_deposit.dart';

class FinancialCalculatorsModule extends AppModule{
  @override
  void binds(i) {
    i.addLazySingleton<ICalculateFinancing>(CalculateFinancing.new);
    i.addLazySingleton<ICalculateDeposit>(CalculateDeposit.new);
    i.addLazySingleton<ICalculateFutureValue>(CalculateFutureValue.new);

    i.add(FutureValueCubit.new);
    i.add(RegularDepositsCubit.new);
    i.add(FinancingCubit.new);
  }

  @override
  void routes(r) {
    r.child(
      AppRoutes.base,
      child: (_) => BlocProvider(
        create: (_) => Modular.get<FinancingCubit>(),
        child: const FinancingPage(),
      ),
    );
    r.child(
      '/${AppRoutes.depositsSegment}',
      child: (_) => BlocProvider(
        create: (_) => Modular.get<RegularDepositsCubit>(),
        child: const RegularDepositsPage(),
      ),
    );
    r.child(
      '/${AppRoutes.futureValueSegment}',
      child: (_) => BlocProvider(
        create: (_) => Modular.get<FutureValueCubit>(),
        child: const FutureValuePage(),
      ),
    );
    
  }
}

