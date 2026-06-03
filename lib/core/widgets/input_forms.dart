import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputForms extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final Widget prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final GestureTapCallback? onTap;
  final String? Function(String?)? validator;

  const InputForms({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.textInputAction,
    this.keyboardType = TextInputType.number, 
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextFormField(
          validator: validator,
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onTap: onTap,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF5B6874)),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFF111B27),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF1E293B), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF1E94F6), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ],
    );
  }
}
