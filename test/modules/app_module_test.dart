import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:real_calc/core/routes/app_routes.dart';
import 'package:real_calc/modules/app_module.dart';
import 'package:real_calc/modules/app_widget.dart';
import 'package:real_calc/modules/financing/presentation/cubit/financing_cubit.dart';
import 'package:real_calc/modules/financing/presentation/pages/page.dart';
import 'package:real_calc/modules/future_value/presentation/pages/page.dart';
import 'package:real_calc/modules/future_value/presentation/cubit/future_value_cubit.dart';
import 'package:real_calc/modules/home/presentation/page/page.dart';
import 'package:real_calc/modules/regular_deposits/presentation/pages/page.dart';

class MockFinancingCubit extends MockCubit<FinancingState>
    implements FinancingCubit {}

class MockFutureValueCubit extends MockCubit<FutureValueState>
  implements FutureValueCubit {}

class AppModuleTest extends AppModule {
  final FinancingCubit customCubit;
  final FutureValueCubit futureValueCubit;

  AppModuleTest({required this.customCubit, required this.futureValueCubit});

  @override
  void binds(Injector i) {
    super.binds(i);
    i.addInstance<FinancingCubit>(customCubit);
    i.addInstance<FutureValueCubit>(futureValueCubit);
  }
}

void main() {
  late FinancingCubit mockCubit;
  late FutureValueCubit mockFutureValueCubit;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    mockCubit = MockFinancingCubit();
    mockFutureValueCubit = MockFutureValueCubit();
    when(() => mockCubit.state).thenReturn(FinancingInitial());
    when(() => mockFutureValueCubit.state).thenReturn(FutureValueInitial());
    Modular.destroy();
  });

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
            module: AppModuleTest(customCubit: mockCubit, futureValueCubit: mockFutureValueCubit),
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
            module: AppModuleTest(customCubit: mockCubit, futureValueCubit: mockFutureValueCubit),
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
            module: AppModuleTest(customCubit: mockCubit, futureValueCubit: mockFutureValueCubit),
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
            module: AppModuleTest(customCubit: mockCubit, futureValueCubit: mockFutureValueCubit),
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
            module: AppModuleTest(customCubit: mockCubit, futureValueCubit: mockFutureValueCubit),
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
