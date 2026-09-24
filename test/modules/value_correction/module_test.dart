import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/modules/value_correction/module.dart';
import 'package:real_calc/modules/value_correction/presentation/pages/value_correction_page.dart';

void main() {
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

    testWidgets('Deve conseguir resolver e renderizar a ValueCorrectionPage através da rota base', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.darkTheme,
          routerConfig: Modular.routerConfig,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ValueCorrectionPage), findsOneWidget);
    });
  });
}