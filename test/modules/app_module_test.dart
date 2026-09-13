import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/routes/app_routes.dart';
import 'package:real_calc/modules/app_widget.dart';
import 'package:real_calc/modules/financial_calculators/presentation/pages/financing_page.dart';
import 'package:real_calc/modules/financial_calculators/presentation/pages/future_value_page.dart';
import 'package:real_calc/modules/financial_calculators/presentation/pages/regular_deposits_page.dart';
import 'package:real_calc/modules/home/presentation/page/page.dart';

import '../test_harness.dart';

void main() {
  late TestHarness harness;

  setUp(() {
    harness = TestHarness()..setUpDefaults();
    Modular.destroy();
  });

  tearDown((){
    harness.dispose();
    Modular.destroy();
  });

  // Helper local para definir a resolução correta da tela usando o tester.
  void resizeScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(450, 900);
    tester.view.devicePixelRatio = 1.0;
  }

  group('AppModule & AppWidget - Testes de Rotas', () {
    testWidgets(
      'Deve inicializar o AppModule e renderizar a rota inicial (HomePage)',
      (tester) async {
        resizeScreen(tester);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ModularApp(module: harness.buildModule(), child: const AppWidget()),
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
          ModularApp(module: harness.buildModule(), child: const AppWidget()),
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
          ModularApp(module: harness.buildModule(), child: const AppWidget()),
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
          ModularApp(module: harness.buildModule(), child: const AppWidget()),
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
          ModularApp(module: harness.buildModule(), child: const AppWidget()),
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