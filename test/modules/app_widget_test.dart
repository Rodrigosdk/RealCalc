import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/theme_cubit.dart';
import 'package:real_calc/modules/app_module.dart';
import 'package:real_calc/modules/app_widget.dart';
import 'package:real_calc/modules/home/presentation/page/page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ThemeCubit themeCubit;

  Future<Widget> buildApp() async {
    SharedPreferences.setMockInitialValues({});
    themeCubit = ThemeCubit(await SharedPreferences.getInstance());
    return BlocProvider.value(
      value: themeCubit,
      child: ModularApp(module: AppModule(), child: const AppWidget()),
    );
  }

  tearDown(() {
    Modular.destroy();
    themeCubit.close();
  });

  group('AppWidget & AppModule - Integração de Rotas', () {
    testWidgets(
      'Deve inicializar o AppWidget e carregar a HomePage na rota padrão',
      (tester) async {
        await tester.pumpWidget(await buildApp());

        // Aguarda a resolução assíncrona das rotas e animações iniciais
        await tester.pumpAndSettle();

        expect(find.byType(HomePage), findsOneWidget);

        // O tema fica no mesmo teste: o Modular não reinicializa bem dois
        // ModularApp no mesmo arquivo.
        ThemeMode appThemeMode() =>
            tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;

        expect(appThemeMode(), ThemeMode.dark);

        await themeCubit.setMode(ThemeMode.light);
        await tester.pumpAndSettle();

        expect(appThemeMode(), ThemeMode.light);
        expect(
          Theme.of(tester.element(find.byType(HomePage))).brightness,
          Brightness.light,
        );
      },
    );
  });
}
