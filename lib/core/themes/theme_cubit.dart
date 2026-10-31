import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda e persiste o [ThemeMode] escolhido pelo usuário.
class ThemeCubit extends Cubit<ThemeMode> {
  static const storageKey = 'theme_mode';

  static const initialMode = ThemeMode.system;

  final SharedPreferences _preferences;

  ThemeCubit(this._preferences) : super(_read(_preferences));

  static ThemeMode _read(SharedPreferences preferences) {
    final stored = preferences.getString(storageKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => initialMode,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await _preferences.setString(storageKey, mode.name);
  }

  /// Alterna entre claro e escuro a partir do brilho que está na tela.
  Future<void> toggle(Brightness current) =>
      setMode(current == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
}
