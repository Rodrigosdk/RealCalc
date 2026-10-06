import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:real_calc/core/routes/app_routes.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/modules/value_correction/domain/entites/period.dart';
import 'package:real_calc/modules/value_correction/domain/entites/value_correction.dart';
import 'package:real_calc/modules/value_correction/module.dart';
import 'package:real_calc/modules/value_correction/presentation/pages/value_correction_page.dart';
import 'package:real_calc/modules/value_correction/presentation/pages/value_correction_result_page.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  group('ValueCorrectionModule Tests', () {
    setUp(() {
      Modular.init(ValueCorrectionModule());
    });

    tearDown(() {
      Modular.destroy();
    });

    test('Deve garantir que o módulo foi inicializado com sucesso', () {
      expect(Modular.to, isNotNull);
    });

    testWidgets(
      'Deve conseguir resolver e renderizar a ValueCorrectionPage através da rota base',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            theme: AppTheme.darkTheme,
            routerConfig: Modular.routerConfig,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(ValueCorrectionPage), findsOneWidget);
      },
    );

    testWidgets(
      'abre a página de resultado pela rota nomeada com os argumentos',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            theme: AppTheme.darkTheme,
            routerConfig: Modular.routerConfig,
          ),
        );
        await tester.pumpAndSettle();

        final result = ValueCorrection(
          index: 433,
          period: Period(
            initial: DateTime(2024, 1, 1),
            end: DateTime(2024, 12, 1),
          ),
          percentage: 0,
          originalValue: 100,
          factor: 1.015,
          adjustedValue: 101.5,
          variation: 1.5,
        );

        Modular.to.pushNamed(
          '/${AppRoutes.correctionResultSegment}',
          arguments: result,
        );
        await tester.pumpAndSettle();

        expect(find.byType(ValueCorrectionResultPage), findsOneWidget);
        expect(find.textContaining('101,50'), findsOneWidget);
      },
    );
  });
}
