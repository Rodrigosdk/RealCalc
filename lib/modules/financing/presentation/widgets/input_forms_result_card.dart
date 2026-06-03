import 'package:flutter/material.dart';
import 'package:real_calc/core/widgets/input_forms.dart';

class InputFormsResultCard extends StatelessWidget {
  final String label;
  final String hint;

  final Widget prefixIcon;

  final VoidCallback? onTap;

  final TextEditingController controller;

  const InputFormsResultCard({
    super.key,
    required this.controller,
    this.onTap,
    required this.label,
    required this.hint,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputForms(
          label: label,
          hint: hint,
          controller: controller,
          onTap: onTap,
          textInputAction: TextInputAction.done,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixIcon: prefixIcon,
          suffixIcon: const Padding(
                    padding: EdgeInsets.only(right: 14),
                    child: Icon(Icons.chevron_right, color: Color(0xFF5B6874)),
                  ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Toque para calcular automaticamente',
          style: TextStyle(color: Color(0xFF5B6874), fontSize: 12),
        ),
      ],
    );
  }
}
