import 'package:bloc_test/bloc_test.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/financing/financing_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/forms/financing_form_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/forms/financing_form_state.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/future_value/future_value_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/regular_deposits/regular_deposits_cubit.dart';
import 'package:real_calc/modules/home/presentation/cubit/greeting_cubit.dart';
import 'package:real_calc/modules/home/presentation/cubit/selic_cubit.dart';

class MockFinancingCubit extends MockCubit<FinancingState> implements FinancingCubit {}

class MockFutureValueCubit extends MockCubit<FutureValueState> implements FutureValueCubit {}

class MockSelicCubit extends MockCubit<SelicState> implements SelicCubit {}

class MockGreetingCubit extends MockCubit<String> implements GreetingCubit {}

class MockFinancingFormCubit extends MockCubit<FinancingFormState> implements FinancingFormCubit {}

class MockRegularDepositsCubit extends MockCubit<RegularDepositsState> implements RegularDepositsCubit {}