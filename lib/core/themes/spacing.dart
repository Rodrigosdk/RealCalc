import 'package:flutter/material.dart';

abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Vibrante minimalista layout tokens.
  static const double screen = 24;
  static const double rowHeight = 58;
  static const double rowHeightWithSecondLine = 64;
  static const double homeRowHeight = 72;
  static const double sectionGap = 26;
  
  // Padding padrão de tela
  static const EdgeInsets screenPadding = EdgeInsets.all(md);
  
  // Padding de conteúdo interno
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
}