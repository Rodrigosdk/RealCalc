import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:real_calc/core/routes/app_routes.dart';
import 'package:real_calc/modules/app_module.dart';
import 'package:real_calc/modules/app_widget.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/financing/financing_cubit.dart';
import 'package:real_calc/modules/financial_calculators/presentation/pages/financing_page.dart';
import 'package:real_calc/modules/financial_calculators/presentation/pages/future_value_page.dart';
import 'package:real_calc/modules/financial_calculators/presentation/cubit/future_value/future_value_cubit.dart';
import 'package:real_calc/modules/home/presentation/cubit/greeting_cubit.dart';
import 'package:real_calc/modules/home/presentation/cubit/selic_cubit.dart';
import 'package:real_calc/modules/home/presentation/page/page.dart';
import 'package:real_calc/modules/metrics/domain/entites/metric.dart';
import 'package:real_calc/modules/financial_calculators/presentation/pages/regular_deposits_page.dart';

class MockFinancingCubit extends MockCubit<FinancingState>
    implements FinancingCubit {}

class MockFutureValueCubit extends MockCubit<FutureValueState>
  implements FutureValueCubit {}


class MockSelicCubit extends MockCubit<SelicState> implements SelicCubit {}

class MockGreetingCubit extends MockCubit<String> implements GreetingCubit {}

class AppModuleTest extends AppModule {
  final FinancingCubit customCubit;
  final FutureValueCubit futureValueCubit;
  final SelicCubit selicCubit;
  final GreetingCubit greetingCubit;

  AppModuleTest({
    required this.customCubit,
    required this.futureValueCubit,
    required this.selicCubit,
    required this.greetingCubit,
  });

  @override
  void binds(Injector i) {
    super.binds(i);
    i.addInstance<FinancingCubit>(customCubit);
    i.addInstance<FutureValueCubit>(futureValueCubit);
    i.addInstance<SelicCubit>(selicCubit);
    i.addInstance<GreetingCubit>(greetingCubit);
  }
}

void main() {
  late FinancingCubit mockCubit;
  late FutureValueCubit mockFutureValueCubit;
  late SelicCubit mockSelicCubit;
  late GreetingCubit mockGreetingCubit;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    mockCubit = MockFinancingCubit();
    mockFutureValueCubit = MockFutureValueCubit();
    mockSelicCubit = MockSelicCubit();
    mockGreetingCubit = MockGreetingCubit();

    when(() => mockCubit.state).thenReturn(FinancingInitial());
    when(() => mockFutureValueCubit.state).thenReturn(FutureValueInitial());
    when(() => mockGreetingCubit.state).thenReturn('Olá, usuário!');

    whenListen(
      mockSelicCubit,
      const Stream<SelicState>.empty(),
      initialState: SelicLoaded(
        Metric(
          anualRate: 10.75,
          variationPercent: 0.25,
          sparklineData: const [10.5, 10.6, 10.75],
        ),
      ),
    );

    when(() => mockSelicCubit.load()).thenAnswer((_) async {});

     mockGreetingCubit = MockGreetingCubit();
    whenListen(
      mockGreetingCubit,
      const Stream<String>.empty(),
      initialState: 'Bom dia',
    );
    Modular.destroy();
  });

  AppModuleTest buildModule() => AppModuleTest(
        customCubit: mockCubit,
        futureValueCubit: mockFutureValueCubit,
        selicCubit: mockSelicCubit,
        greetingCubit: mockGreetingCubit,
      );

  group('AppModule & AppWidget - Testes de Rotas', () {
    // Helper local para definir a resolução correta da tela usando o tester
    void resizeScreen(WidgetTester tester) {
      // Define a resolução lógica (ex: 450x900) e multiplica pelo pixelRatio padrão (1.0)
      tester.view.physicalSize = const Size(450, 900);
      tester.view.devicePixelRatio = 1.0;
    }

    testWidgets(
      'Deve inicializar o AppModule e renderizar a rota inicial (HomePage)',
      (tester) async {
        resizeScreen(tester);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ModularApp(
            module: buildModule(),
            child: const AppWidget(),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(HomePage), findsOneWidget);
      },
    );

    testWidgets(
      'Deve garantir que a rota mapeada para AppRoutes.home seja acessível',
      (tester) async {
        resizeScreen(tester);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ModularApp(
            module: buildModule(),
            child: const AppWidget(),
          ),
        );

        await tester.pumpAndSettle();

        Modular.to.navigate(AppRoutes.home);

        await tester.idle();
        await tester.pumpAndSettle();

        expect(find.byType(HomePage), findsOneWidget);
      },
    );

    testWidgets(
      'Deve garantir que a rota mapeada para AppRoutes.futureValue seja acessível',
      (tester) async {
        resizeScreen(tester);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ModularApp(
            module: buildModule(),
            child: const AppWidget(),
          ),
        );

        await tester.pumpAndSettle();

        Modular.to.navigate(AppRoutes.futureValue);

        await tester.idle();
        await tester.pumpAndSettle();

        expect(find.byType(FutureValuePage), findsOneWidget);
      },
    );

    testWidgets(
      'Deve garantir que a rota mapeada para AppRoutes.financing seja acessível',
      (tester) async {
        resizeScreen(tester);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ModularApp(
            module: buildModule(),
            child: const AppWidget(),
          ),
        );

        await tester.pumpAndSettle();

        Modular.to.navigate(AppRoutes.financing);

        await tester.idle();
        await tester.pumpAndSettle();

        expect(find.byType(FinancingPage), findsOneWidget);
      },
    );

    testWidgets(
      'Deve garantir que a rota mapeada para AppRoutes.deposits seja acessível',
      (tester) async {
        resizeScreen(tester);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ModularApp(
            module: buildModule(),
            child: const AppWidget(),
          ),
        );

        await tester.pumpAndSettle();

        Modular.to.navigate(AppRoutes.deposits);

        await tester.idle();
        await tester.pumpAndSettle();

        expect(find.byType(RegularDepositsPage), findsOneWidget);
      },
    );
  });
}