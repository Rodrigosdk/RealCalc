import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart'; // Importante importar aqui também
import 'package:real_calc/core/widgets/app_bar_forms.dart';

void main() {
  late String title;
  late Widget sut;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    title = "Título do app";
    sut = MaterialApp(
      home: Scaffold(appBar: AppBarForms(title: title)),
    );
  });

  group("AppBarForms", () {
    testWidgets('Deve conseguir criar uma AppBar', (tester) async {
      await tester.pumpWidget(sut);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets("Deve conter um text no centro da AppBar e com elevation 0", (tester) async {
      await tester.pumpWidget(sut);

      final finder = find.byType(AppBar);
      final AppBar appBar = tester.widget(finder);

      expect(appBar.centerTitle, true);
      expect(appBar.elevation, 0);

      final titleFinder = find.text(title);
      expect(titleFinder, findsOneWidget);
    });

    testWidgets("Deve conter uma fontSize de 18 e fontWeight do tipo bold", (tester) async {
      await tester.pumpWidget(sut);

      final finder = find.text(title);
      final Text text = tester.widget(finder);

      expect(text.style?.fontSize, 18);
      expect(text.style?.fontWeight, FontWeight.bold);
    });

    testWidgets("Deve conter um iconTheme da cor 0xFF1E94F6", (tester) async {
      await tester.pumpWidget(sut);

      final finder = find.byType(AppBar);
      final AppBar appBar = tester.widget(finder);
      
      expect(appBar.iconTheme?.color, const Color(0xFF1E94F6));
    });
    
    testWidgets("Deve conter a cor de fundo 0xFF0B1422", (tester) async {
      await tester.pumpWidget(sut);

      final finder = find.byType(AppBar);
      final AppBar appBar = tester.widget(finder);
      
      expect(appBar.backgroundColor, const Color(0xFF0B1422));
    });
  });
}
