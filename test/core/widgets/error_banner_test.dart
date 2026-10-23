import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/extensions/error_banner_theme.dart';
import 'package:real_calc/core/widgets/error_banner.dart';

void main() {
  const errorTheme = ErrorBannerTheme(
    backgroundColor: Color(0x33224466),
    borderColor: Color(0xFF224466),
    iconColor: Color(0xFFFFAA00),
    retryTextColor: Colors.white,
    messageStyle: TextStyle(fontSize: 14, color: Colors.red),
    padding: EdgeInsets.all(16),
    borderRadius: 10,
    iconSize: 20,
    iconMessageSpacing: 8,
    retrySpacing: 6,
  );

  Widget buildSut({VoidCallback? onRetry}) {
    return MaterialApp(
      theme: ThemeData(extensions: [errorTheme]),
      home: Scaffold(
        body: ErrorBanner(message: 'Falha ao carregar dados', onRetry: onRetry),
      ),
    );
  }

  group('ErrorBanner', () {
    testWidgets('exibe a mensagem, o ícone e a ação de retry', (tester) async {
      await tester.pumpWidget(buildSut(onRetry: () {}));

      expect(find.text('Falha ao carregar dados'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('esconde a ação de retry quando não há callback', (
      tester,
    ) async {
      await tester.pumpWidget(buildSut());

      expect(find.text('Falha ao carregar dados'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsNothing);
    });

    testWidgets('aciona o callback ao tocar em tentar novamente', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpWidget(buildSut(onRetry: () => retried = true));

      await tester.tap(find.text('Tentar novamente'));

      expect(retried, isTrue);
    });

    testWidgets('aplica as cores, dimensões e estilos definidos no tema', (
      tester,
    ) async {
      await tester.pumpWidget(buildSut(onRetry: () {}));

      final container = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('Falha ao carregar dados'),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration! as BoxDecoration;
      final icon = tester.widget<Icon>(
        find.byIcon(Icons.warning_amber_rounded),
      );
      final message = tester.widget<Text>(find.text('Falha ao carregar dados'));
      final retry = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Tentar novamente'),
      );

      expect(container.padding, const EdgeInsets.all(16));
      expect(decoration.color, errorTheme.backgroundColor);
      expect(decoration.borderRadius, BorderRadius.circular(10));
      expect((decoration.border! as Border).top.color, errorTheme.borderColor);
      expect(icon.color, errorTheme.iconColor);
      expect(icon.size, 20);
      expect(message.style, errorTheme.messageStyle);
      expect(retry.style?.foregroundColor?.resolve({}), Colors.white);
    });

    test('ErrorBannerTheme suporta copyWith e interpolação', () {
      final copied = errorTheme.copyWith(borderRadius: 14);
      final interpolated = errorTheme.lerp(copied, 0.5);

      expect(copied.borderRadius, 14);
      expect(interpolated.borderRadius, 12);
    });
  });
}
