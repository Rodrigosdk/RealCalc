import 'package:flutter_modular/flutter_modular.dart';
import 'package:real_calc/modules/app_module.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/financing/financing_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/forms/financing_form_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/future_value/future_value_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/regular_deposits/regular_deposits_cubit.dart';
import 'package:real_calc/modules/home/presentation/cubit/greeting_cubit.dart';
import 'package:real_calc/modules/home/presentation/cubit/selic_cubit.dart';

class AppModuleTest extends AppModule {
  final FinancingCubit financingCubit;
  final FutureValueCubit futureValueCubit;
  final SelicCubit selicCubit;
  final GreetingCubit greetingCubit;
  final FinancingFormCubit financingFormCubit;
  final RegularDepositsCubit regularDepositsCubit;

  AppModuleTest({
    required this.financingCubit,
    required this.futureValueCubit,
    required this.selicCubit,
    required this.greetingCubit,
    required this.financingFormCubit,
    required this.regularDepositsCubit
  });

  @override
  void binds(Injector i) {
    super.binds(i);
    i.addInstance<FinancingCubit>(financingCubit);
    i.addInstance<FutureValueCubit>(futureValueCubit);
    i.addInstance<SelicCubit>(selicCubit);
    i.addInstance<GreetingCubit>(greetingCubit);
    i.addInstance<FinancingFormCubit>(financingFormCubit);
    i.addInstance<RegularDepositsCubit>(regularDepositsCubit);
  }
}