import 'package:flutter/material.dart';

class AppTextStyles {
  static const String manropeFamily = 'Manrope';
  static const String bricolageGrotesqueFamily = 'Bricolage Grotesque';

  // Estilos de destaque e componentes da direção Vibrante minimalista.
  // As cores são definidas pelo componente ou tema que utiliza cada estilo.
  static final TextStyle bandStatement = const TextStyle(
    fontFamily: bricolageGrotesqueFamily,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.8,
  );
  static final TextStyle screenTitle = const TextStyle(
    fontFamily: bricolageGrotesqueFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.9,
  );
  static final TextStyle sheetTitle = const TextStyle(
    fontFamily: bricolageGrotesqueFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
  );
  static final TextStyle exampleValue = const TextStyle(
    fontFamily: bricolageGrotesqueFamily,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
  );
  static final TextStyle wordmark = const TextStyle(
    fontFamily: bricolageGrotesqueFamily,
    fontSize: 21,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static final TextStyle bandKicker = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle bandSub = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle headerTitle = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
  static final TextStyle rowLabel = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle rowValue = TextStyle(
    fontFamily: manropeFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  static final TextStyle rowUnit = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle rowState = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
  static final TextStyle listTitle = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
  );
  static final TextStyle listDesc = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle sectionLabel = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle detailLabel = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle detailValue = TextStyle(
    fontFamily: manropeFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  static final TextStyle button = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 16,
    fontWeight: FontWeight.w800,
  );
  static final TextStyle pill = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );
  static final TextStyle body = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
  static final TextStyle caption = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}
