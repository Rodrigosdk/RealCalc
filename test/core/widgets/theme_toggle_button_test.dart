import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/theme_cubit.dart';
import 'package:real_calc/core/widgets/theme_toggle_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ThemeCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    cubit = ThemeCubit(await SharedPreferences.getInstance());
  });

  tearDown(() => cubit.close());

  Widget app() => BlocProvider.value(
    value: cubit,
    child: BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) => MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: mode,
        home: const Scaffold(body: Center(child: ThemeToggleButton())),
      ),
    ),
  );

  group('ThemeToggleButton', () {
    testWidgets('no escuro mostra o sol e o rótulo para o modo claro', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(app());

      expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(ThemeToggleButton)),
        isSemantics(
          label: 'Mudar para o modo claro',
          isButton: true,
          hasTapAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('o toque troca o tema na hora e grava a escolha', (
      tester,
    ) async {
      await tester.pumpWidget(app());

      await tester.tap(find.byType(ThemeToggleButton));
      await tester.pumpAndSettle();

      expect(cubit.state, ThemeMode.light);
      expect(
        Theme.of(tester.element(find.byType(IconButton))).brightness,
        Brightness.light,
      );
      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
      expect(find.bySemanticsLabel('Mudar para o modo escuro'), findsOneWidget);

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString(ThemeCubit.storageKey), 'light');
    });

    testWidgets('tem área de toque de 44x44', (tester) async {
      await tester.pumpWidget(app());

      expect(
        tester.getSize(find.byType(ThemeToggleButton)),
        const Size.square(44),
      );
    });
  });
}
