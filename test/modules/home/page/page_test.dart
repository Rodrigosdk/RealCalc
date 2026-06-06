import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/routes/app_routes.dart';
import 'package:real_calc/core/widgets/title_widget.dart';
import 'package:real_calc/modules/home/components/highlight_card.dart';
import 'package:real_calc/modules/home/components/menu_card.dart';
import 'package:real_calc/modules/home/page/page.dart';

class MockNavigator extends Mock implements IModularNavigator {}

void main() {
  late MockNavigator mockNavigator;

  setUp(() {
    mockNavigator = MockNavigator();
    Modular.navigatorDelegate = mockNavigator;
  });

  // Helper para construir a HomePage com tamanho de tela customizável
  Widget buildTestableWidget({double width = 360.0, double height = 800.0}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(width, height)),
        child: const HomePage(),
      ),
    );
  }

  group('HomePage Widget Tests', () {
    testWidgets('Deve renderizar os componentes base estruturais e textos principais', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestableWidget());

      // Assert - Header e Títulos
      expect(find.text('RealCalc'), findsOneWidget);
      expect(find.byIcon(Icons.calculate), findsOneWidget);
      expect(find.byType(TitleWidget), findsOneWidget);

      // Assert - Componentes filhos complexos
      expect(find.byType(HighlightCard), findsOneWidget);
      expect(find.byType(MenuCard), findsNWidgets(4));

      expect(find.text('ACESSO RÁPIDO'), findsOneWidget);
      expect(find.text('Último cálculo: Financiamento Imob.'), findsOneWidget);

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('INÍCIO'), findsOneWidget);
      expect(find.text('HISTÓRICO'), findsOneWidget);
      expect(find.text('AJUSTES'), findsOneWidget);
    });

    testWidgets('Deve navegar para a tela de financiamento ao clicar no card correspondente', (WidgetTester tester) async {
      when(() => mockNavigator.pushNamed(any())).thenAnswer((_) async => null);
      await tester.pumpWidget(buildTestableWidget());

      final cardFinanciamento = find.widgetWithText(MenuCard, 'Financiamento');
      expect(cardFinanciamento, findsOneWidget);
      
      await tester.tap(cardFinanciamento);
      await tester.pumpAndSettle();

      verify(() => mockNavigator.pushNamed(AppRoutes.financing)).called(1);
    });

    testWidgets('Deve calcular largura do card para Mobile quando a tela for menor que 600px', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(width: 360.0));

      final gridViewFinder = find.byType(GridView);
      final GridView gridViewWidget = tester.widget(gridViewFinder);
      final delegate = gridViewWidget.gridDelegate as SliverGridDelegateWithMaxCrossAxisExtent;

      expect(delegate.maxCrossAxisExtent, closeTo(98.66, 0.01));
    });

    testWidgets('Deve cravar largura máxima do card em 180px quando for Desktop/Web (width > 600px)', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(width: 1024.0));

      final gridViewFinder = find.byType(GridView);
      final GridView gridViewWidget = tester.widget(gridViewFinder);
      final delegate = gridViewWidget.gridDelegate as SliverGridDelegateWithMaxCrossAxisExtent;

      expect(delegate.maxCrossAxisExtent, 180.0);
    });
  });
}
