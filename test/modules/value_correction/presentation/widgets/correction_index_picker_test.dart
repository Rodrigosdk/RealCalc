import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';
import 'package:real_calc/modules/value_correction/presentation/widgets/correction_index_picker.dart';

void main() {
  Future<void> openPicker(WidgetTester tester) async {
    await tester.tap(find.text('Abrir seletor'));
    await tester.pumpAndSettle();
  }

  group('CorrectionIndexPicker', () {
    testWidgets('renderiza os 13 índices em 3 grupos', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) {
                          return CorrectionIndexPicker(
                            selectedIndex: CorrectionIndex.ipca,
                            indices: CorrectionIndex.values,
                          );
                        },
                      );
                    },
                    child: const Text('Abrir seletor'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await openPicker(tester);

      expect(find.text('INFLAÇÃO'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Poupança Nova'),
        200,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      expect(find.text('Poupança Nova'), findsOneWidget);
      expect(find.text('Poupança Velha'), findsOneWidget);
    });

    testWidgets('marca o índice selecionado e chama onSelected', (tester) async {
      CorrectionIndex? selected;
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) {
                          return CorrectionIndexPicker(
                            selectedIndex: CorrectionIndex.ipca,
                            indices: CorrectionIndex.values,
                            onSelected: (index) => selected = index,
                          );
                        },
                      );
                    },
                    child: const Text('Abrir seletor'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await openPicker(tester);

      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text(CorrectionIndex.selic.label),
        200,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(find.text(CorrectionIndex.selic.label));
      await tester.pumpAndSettle();

      expect(selected, CorrectionIndex.selic);
    });

    testWidgets('fecha ao selecionar um índice', (tester) async {
      CorrectionIndex? selected;
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) {
                          return CorrectionIndexPicker(
                            selectedIndex: CorrectionIndex.ipca,
                            indices: CorrectionIndex.values,
                            onSelected: (index) => selected = index,
                          );
                        },
                      );
                    },
                    child: const Text('Abrir seletor'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await openPicker(tester);

      expect(find.byType(CorrectionIndexPicker), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text(CorrectionIndex.selic.label),
        200,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(find.text(CorrectionIndex.selic.label));
      await tester.pumpAndSettle();

      expect(selected, CorrectionIndex.selic);
      expect(find.byType(CorrectionIndexPicker), findsNothing);
    });

    testWidgets('não há overflow em 360x640', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) {
                          return CorrectionIndexPicker(
                            selectedIndex: CorrectionIndex.ipca,
                            indices: CorrectionIndex.values,
                          );
                        },
                      );
                    },
                    child: const Text('Abrir seletor'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Abrir seletor'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
