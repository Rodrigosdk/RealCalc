import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_calc/core/widgets/title_widget.dart';

void main() {
  late String title;
  late String subtitle;
  late Widget sut;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    title = "Título do app";
    subtitle = "subtítulo do app";
    sut = MaterialApp(
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
      "Deve conter um Column com spacing 8 e crossAxisAlignment start ",
      (tester) async {
        await tester.pumpWidget(sut);

        final finder = find.byType(Column);
        final Column column = tester.widget(finder);

        expect(column.spacing, 8);
        expect(column.crossAxisAlignment, CrossAxisAlignment.start);
      },
    );

    testWidgets("Deve conter duas string dentro de Column", (tester) async {
      await tester.pumpWidget(sut);

      final finder = find.byType(Column);

      final textsInsideColumnFinder = find.descendant(
        of: finder,
        matching: find.byType(Text),
      );

      expect(textsInsideColumnFinder, findsNWidgets(2));
    });

    testWidgets("Deve coseguir mostra o title e o subtitle", (tester) async {
      await tester.pumpWidget(sut);

      expect(find.text(title), findsOneWidget);
      expect(find.text(subtitle), findsOneWidget);
    });

    testWidgets("O title deve conter uma fontSize de 24, fontWeight bold e a cor do texto deve ser branco", (tester) async {
      await tester.pumpWidget(sut);

      final finder = find.text(title);
      final Text text = tester.widget(finder);

      expect(text.style?.color, Colors.white);
      expect(text.style?.fontSize, 24);
      expect(text.style?.fontWeight, FontWeight.bold);
    });

    testWidgets("O subtitle deve conter uma fontSize de 14, fontWeight medium e a cor do texto deve ser 0xFF94A3B8", (tester) async {
      await tester.pumpWidget(sut);

      final finder = find.text(subtitle);
      final Text text = tester.widget(finder);

      expect(text.style?.color, Color(0xFF94A3B8));
      expect(text.style?.fontSize, 14);
      expect(text.style?.fontWeight, FontWeight.w500);
    });
  });
}
