import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_calc/core/themes/app_theme.dart';
import 'package:real_calc/core/widgets/title_widget.dart';
import 'package:real_calc/modules/future_value/presentation/cubit/future_value_cubit.dart';
import 'package:real_calc/modules/future_value/presentation/pages/page.dart';
import 'package:real_calc/modules/future_value/presentation/widgets/future_value_forms.dart';
import 'package:real_calc/modules/future_value/presentation/widgets/help_card.dart';

class MockFutureValueCubit extends MockCubit<FutureValueState> implements FutureValueCubit {}

void main() {
  late FutureValueCubit mockCubit;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    mockCubit = MockFutureValueCubit();
    when(() => mockCubit.state).thenReturn(FutureValueInitial());
  });

  Widget createSut() {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.dark,
      home: BlocProvider<FutureValueCubit>.value(
        value: mockCubit,
        child: const FutureValuePage(),
      ),
    );
  }

  group('FutureValuePage - Testes de Integração da Tela', () {
    testWidgets('Deve renderizar a árvore de componentes completa com sucesso', (tester) async {
      await tester.pumpWidget(createSut());

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(TitleWidget), findsOneWidget);
      expect(find.byType(HelpCard), findsOneWidget);
      expect(find.byType(FutureValueForms), findsOneWidget);

      expect(find.text('Calculadora de Valor Futuro'), findsOneWidget);
      expect(find.text('Valor Futuro'), findsOneWidget);
    });

    testWidgets('Deve garantir que a página inteira possui um scroll ativado', (tester) async {
      await tester.pumpWidget(createSut());

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group("FutureValuePage - Testes da AppBar", () {
    testWidgets('Deve conseguir criar uma AppBar', (tester) async {
      await tester.pumpWidget(createSut());
      expect(find.byType(AppBar), findsOneWidget);
    });

    test('AppTheme define AppBar centralizada, sem elevação, cores corretas',() {
        final theme = AppTheme.darkTheme;

        expect(theme.appBarTheme.centerTitle, true);
        expect(theme.appBarTheme.elevation, 0);
        expect(theme.appBarTheme.backgroundColor, const Color(0xFF0B1422));
      },
    );

    testWidgets("Deve conter um text no centro da AppBar", (tester) async {
      await tester.pumpWidget(createSut());

      final titleFinder = find.text('Calculadora de Valor Futuro');
      expect(titleFinder, findsOneWidget);

      final Offset appBarCenter = tester.getCenter(find.byType(AppBar));
      final Offset titleCenter = tester.getCenter(titleFinder);
      expect(titleCenter.dx, moreOrLessEquals(appBarCenter.dx, epsilon: 1.0));
    });

    testWidgets("Deve conter uma fontSize de 18 e fontWeight bold", (tester) async {
      await tester.pumpWidget(createSut());

      final textFinder = find.text('Calculadora de Valor Futuro');
      final RenderParagraph renderObject = tester.renderObject<RenderParagraph>(textFinder);

      final TextStyle? resolvedStyle = renderObject.text.style;

      expect(resolvedStyle?.fontSize, 18);
      expect(resolvedStyle?.fontWeight, FontWeight.bold);
    });
  });
}
