import 'package:flutter/material.dart';

abstract class ColorTokens {
  // Superfícies
  static const Color background = Color(0xFF0A0D12);
  static const Color surface = Color(0xFF0E1116);
  static const Color surfaceVariant = Color(0xFF12161D);

  // Texto
  static const Color textPrimary = Color(0xFFEDEFF2);
  static const Color textSecondary = Color(0xFF8B929C);
  static const Color textHint = Color(0xFF5C636E);

  // Borda
  static const Color border = Color.fromARGB(20, 255, 255, 255);

  static const Color accentAmber = Color(0xFFD4A657);

  // Feedback
  static const Color error = Color(0xFFE24B4A);
  static const Color success = Color(0xFF6FCF97);
  static const Color warning = Color(0xFFFFC107);

  // Container de erro
  static const Color errorContainerBg = Color.fromARGB(25, 226, 75, 74);
  static const Color errorContainerBorder = Color.fromARGB(25, 226, 75, 74);

  // Container de success
  static const Color successContainerBg = Color.fromARGB(25, 111, 207, 151);
  static const Color successContainerBorder = Color.fromARGB(25, 111, 207, 151);

  //icons
  static const Color iconColor = Color(0xFFFFFFFF);
}