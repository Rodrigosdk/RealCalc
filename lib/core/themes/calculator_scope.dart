import 'package:flutter/material.dart';

import 'calculator_palette.dart';

class CalculatorScope extends StatelessWidget {
  final CalculatorKind kind;
  final Widget child;

  const CalculatorScope({required this.kind, required this.child, super.key});

  static CalculatorPalette? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_CalculatorPaletteScope>()
      ?.palette;

  static CalculatorPalette of(BuildContext context) {
    final palette = maybeOf(context);
    assert(
      palette != null,
      'CalculatorScope não encontrado na árvore de widgets.',
    );
    return palette!;
  }

  @override
  Widget build(BuildContext context) {
    final palette = CalculatorPalette.of(
      kind,
      brightness: Theme.of(context).brightness,
    );
    final theme = Theme.of(context);
    final localTheme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(primary: palette.solid),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: palette.solid,
        selectionColor: palette.solid.withValues(alpha: 0.32),
        selectionHandleColor: palette.solid,
      ),
    );

    return Theme(
      data: localTheme,
      child: _CalculatorPaletteScope(palette: palette, child: child),
    );
  }
}

class _CalculatorPaletteScope extends InheritedWidget {
  final CalculatorPalette palette;

  const _CalculatorPaletteScope({required this.palette, required super.child});

  @override
  bool updateShouldNotify(_CalculatorPaletteScope oldWidget) =>
      palette != oldWidget.palette;
}
