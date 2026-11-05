import 'package:flutter/material.dart';

enum CalculatorKind { financing, deposits, futureValue, correction }

class CalculatorPalette {
  final Color solid;
  final Color onSolid;
  final Color text;

  const CalculatorPalette({
    required this.solid,
    required this.onSolid,
    required this.text,
  });

  static CalculatorPalette of(
    CalculatorKind kind, {
    Brightness brightness = Brightness.light,
  }) {
    final isDark = brightness == Brightness.dark;
    return switch (kind) {
      CalculatorKind.financing => CalculatorPalette(
        solid: const Color(0xFF364FC7),
        onSolid: Colors.white,
        text: Color(isDark ? 0xFF91A7FF : 0xFF364FC7),
      ),
      CalculatorKind.deposits => CalculatorPalette(
        solid: const Color(0xFF087F5B),
        onSolid: Colors.white,
        text: Color(isDark ? 0xFF63E6BE : 0xFF0A6E50),
      ),
      CalculatorKind.futureValue => CalculatorPalette(
        solid: const Color(0xFF6741D9),
        onSolid: Colors.white,
        text: Color(isDark ? 0xFFB197FC : 0xFF6741D9),
      ),
      CalculatorKind.correction => CalculatorPalette(
        solid: const Color(0xFFB85300),
        onSolid: Colors.white,
        text: Color(isDark ? 0xFFFFA94D : 0xFFA04600),
      ),
    };
  }

  @override
  bool operator ==(Object other) =>
      other is CalculatorPalette &&
      other.solid == solid &&
      other.onSolid == onSolid &&
      other.text == text;

  @override
  int get hashCode => Object.hash(solid, onSolid, text);
}
