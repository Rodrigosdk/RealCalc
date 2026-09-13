import 'package:mocktail/mocktail.dart';
import 'package:real_calc/modules/financial_calculators/domain/entities/financial_calculation.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/financing/financing_cubit.dart';

class FakeFinancing extends Fake implements FinancingCubit {}

class FakeFinancialCalculation extends Fake implements FinancialCalculation {}