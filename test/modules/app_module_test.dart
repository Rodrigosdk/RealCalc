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
import 'package:real_calc/modules/home/page/page.dart';
import 'package:real_calc/modules/regular_deposits/presentation/pages/page.dart';

class MockFinancingCubit extends MockCubit<FinancingState>
    implements FinancingCubit {}

class AppModuleTest extends AppModule {
  final FinancingCubit customCubit;

  AppModuleTest({required this.customCubit});

  @override
  void binds(Injector i) {
    super.binds(i);
    i.addInstance<FinancingCubit>(customCubit);
  }
}

void main() {
  late FinancingCubit mockCubit;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    mockCubit = MockFinancingCubit();
    when(() => mockCubit.state).thenReturn(FinancingInitial());
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
            module: AppModuleTest(customCubit: mockCubit),
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
            module: AppModuleTest(customCubit: mockCubit),
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
      'Deve garantir que a rota mapeada para AppRoutes.financing seja acessível',
      (tester) async {
        resizeScreen(tester);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ModularApp(
            module: AppModuleTest(customCubit: mockCubit),
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
            module: AppModuleTest(customCubit: mockCubit),
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
