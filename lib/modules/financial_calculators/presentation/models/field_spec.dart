import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class FieldSpec<T> {
  final T field;
  final String label;
  final String hint;
  final IconData icon;
  final List<TextInputFormatter> formatters;

  const FieldSpec({
    required this.field,
    required this.label,
    required this.hint,
    required this.icon,
    required this.formatters,
  });
}
