import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<SharedPreferences> preferencesWith(Map<String, Object> values) {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  group('ThemeCubit', () {
    test('sem escolha gravada, segue o tema do sistema', () async {
      final cubit = ThemeCubit(await preferencesWith({}));

      expect(cubit.state, ThemeCubit.initialMode);
      expect(cubit.state, ThemeMode.system);
    });

    test('lê a escolha gravada', () async {
      final cubit = ThemeCubit(
        await preferencesWith({ThemeCubit.storageKey: 'light'}),
      );

      expect(cubit.state, ThemeMode.light);
    });

    test('valor gravado desconhecido volta para o valor inicial', () async {
      final cubit = ThemeCubit(
        await preferencesWith({ThemeCubit.storageKey: 'sepia'}),
      );

      expect(cubit.state, ThemeCubit.initialMode);
    });

    test('grava a escolha e ela continua ao recriar o cubit', () async {
      final preferences = await preferencesWith({});

      await ThemeCubit(preferences).setMode(ThemeMode.system);

      expect(preferences.getString(ThemeCubit.storageKey), 'system');
      expect(ThemeCubit(preferences).state, ThemeMode.system);
    });

    late SharedPreferences preferences;

    blocTest<ThemeCubit, ThemeMode>(
      'toggle no escuro muda para o claro',
      setUp: () async => preferences = await preferencesWith({}),
      build: () => ThemeCubit(preferences),
      act: (cubit) => cubit.toggle(Brightness.dark),
      expect: () => [ThemeMode.light],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'toggle no claro muda para o escuro',
      setUp: () async =>
          preferences = await preferencesWith({ThemeCubit.storageKey: 'light'}),
      build: () => ThemeCubit(preferences),
      act: (cubit) => cubit.toggle(Brightness.light),
      expect: () => [ThemeMode.dark],
    );
  });
}
