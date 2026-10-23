import 'package:flutter/material.dart';
import 'package:real_calc/core/themes/extensions/financing_forms_theme.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/widgets/types/input_field_state.dart';
import 'package:real_calc/core/widgets/options_bottom_forms.dart';
import '../models/field_spec.dart';
import '../../../../core/widgets/input_forms_result_card.dart';

class FormsView<T> extends StatelessWidget {
  final List<FieldSpec<T>> fieldSpecs;
  final TextEditingController Function(T field) controllerFor;
  final InputFieldState Function(T field) stateOf;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onCalculate;
  final VoidCallback? onClear;
  final ValueChanged<T>? onFieldTap;

  const FormsView({
    required this.fieldSpecs,
    required this.controllerFor,
    required this.stateOf,
    this.isLoading = false,
    this.errorMessage,
    this.onCalculate,
    this.onClear,
    this.onFieldTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).extension<FinancingFormsTheme>()!;

    return Form(
      child: Column(
        children: [
          if (errorMessage != null) ...[
            _ErrorBanner(message: errorMessage!, styles: styles),
            SizedBox(height: AppSpacing.md),
          ],
          if (isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: LinearProgressIndicator(
                color: styles.progressIndicatorColor,
              ),
            ),
          for (final spec in fieldSpecs) ...[
            InputFormsResultCard(
              label: spec.label,
              hint: spec.hint,
              icon: spec.icon,
              controller: controllerFor(spec.field),
              inputFormatters: spec.formatters,
              state: stateOf(spec.field),
              onTap: () => onFieldTap?.call(spec.field),
            ),
            SizedBox(height: AppSpacing.md),
          ],
          SizedBox(height: AppSpacing.sm),
          OptionsBottomForms(onCalculate: onCalculate, onClear: onClear),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final FinancingFormsTheme styles;

  const _ErrorBanner({required this.message, required this.styles});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: styles.errorContainerPadding,
      decoration: BoxDecoration(
        color: styles.errorBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: styles.errorBorderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: styles.errorBorderColor,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: styles.errorTextStyle)),
        ],
      ),
    );
  }
}
