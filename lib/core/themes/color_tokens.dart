import 'package:flutter/material.dart';

abstract class ColorTokens {
  // Primárias
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryVariant = Color(0xFF5A52D5);

  // Superfícies
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF0B1422);
  static const Color surfaceVariant = Color(0xFF2C2C2C);
  static const Color surfaceDark = Color(0xFF111B27);

  // Texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textHint = Color(0xFF5B6874);

  // Borda
  static const Color border = Color(0xFF1E293B);

  // Acento (azul destaque)
  static const Color accent = Color(0xFF1E94F6);

  // Feedback
  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);

  // Container de erro
  static const Color errorContainerBg = Color(0x26FF0000);
  static const Color errorContainerBorder = Color(0x80FF5252);

  // Gradientes
  static const Color gradientStart = Color(0xFF1E70F6);
  static const Color gradientEnd = Color(0xFF1E94F6);

  // Home
  static const Color homeScaffoldBackground = Color(0xFF0D1520);
  static const Color homeCard = Color(0xFF16222F);
  static const Color homeIconContainer = Color(0xFF1A2A3D);
  static const Color bottomNavBackground = Color(0xFF090D14);

  // Cards
  static const Color helpCardBackground = Color(0xFF101A24);
  static const Color menuCardIconContainer = Color(0xFF1A2A3D);

  // Botão
  static const Color buttonDark = Color(0xFF1A222D);
}