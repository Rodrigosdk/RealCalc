import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/extensions/title_widget_theme.dart';
import 'package:real_calc/core/widgets/title_widget.dart';

void main() {
  late String title;
  late String subtitle;
  late Widget sut;

  setUpAll(() {});

  setUp(() {
    title = "Título do app";
    subtitle = "subtítulo do app";

    sut = MaterialApp(
      theme: ThemeData(
        extensions: const [
          TitleWidgetTheme(
            titleStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            subtitleStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
      home: Scaffold(
        body: TitleWidget(title: title, subtitle: subtitle),
      ),
    );
  });

  group("TitleWidget", () {
    testWidgets("Deve conter uma Column no TitleWidget", (tester) async {
      await tester.pumpWidget(sut);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets(
      "Deve conter um Column com spacing 8 e crossAxisAlignment start",
      (tester) async {
        await tester.pumpWidget(sut);
        final column = tester.widget<Column>(find.byType(Column));
        expect(column.spacing, 8);
        expect(column.crossAxisAlignment, CrossAxisAlignment.start);
      },
    );

    testWidgets("Deve conter duas strings dentro de Column", (tester) async {
      await tester.pumpWidget(sut);
      expect(
        find.descendant(
          of: find.byType(Column),
          matching: find.byType(Text),
        ),
        findsNWidgets(2),
      );
    });

    testWidgets("Deve mostrar o title e o subtitle", (tester) async {
      await tester.pumpWidget(sut);
      expect(find.text(title), findsOneWidget);
      expect(find.text(subtitle), findsOneWidget);
    });

    testWidgets(
      "O title deve conter estilo correto (fontSize 24, bold, branco)",
      (tester) async {
        await tester.pumpWidget(sut);

        final textWidget = tester.widget<Text>(find.text(title));
        expect(textWidget.style?.fontSize, 24);
        expect(textWidget.style?.fontWeight, FontWeight.bold);
        expect(textWidget.style?.color, Colors.white);
      },
    );

    testWidgets(
      "O subtitle deve conter estilo correto (fontSize 14, w500, cor #94A3B8)",
      (tester) async {
        await tester.pumpWidget(sut);

        final textWidget = tester.widget<Text>(find.text(subtitle));
        expect(textWidget.style?.fontSize, 14);
        expect(textWidget.style?.fontWeight, FontWeight.w500);
        expect(textWidget.style?.color, const Color(0xFF94A3B8));
      },
    );
  });
}