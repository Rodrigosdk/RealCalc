import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/home/module.dart';
import 'package:real_calc/modules/home/page/page.dart';

void main() {
  group('HomeModule Tests', () {
        setUp(() {
      Modular.init(HomeModule());
    });

    tearDown(() {
      Modular.destroy();
    });

    test('Deve garantir que o módulo foi inicializado com sucesso', () {
      expect(Modular.to, isNotNull);
    });

    testWidgets('Deve conseguir resolver e renderizar a HomePage através da rota base', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: Modular.routerConfig,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
