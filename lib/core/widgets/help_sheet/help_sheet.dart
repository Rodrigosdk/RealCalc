import 'package:flutter/material.dart';
import 'package:real_calc/core/themes/app_colors.dart';
import 'package:real_calc/core/themes/calculator_palette.dart';
import 'package:real_calc/core/themes/calculator_scope.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/themes/text_styles.dart';

import '../app_sheet.dart';
import 'help_content.dart';
import 'methodology.dart';

const helpSheetTitle = 'Como funciona';

Future<void> showHelpSheet(BuildContext context, CalculatorKind kind) {
  return showAppSheet<void>(
    context: context,
    title: helpSheetTitle,
    kind: kind,
    bodyBuilder: (_) => HelpSheetBody(
      content: HelpContent.of(kind),
      methodology: Methodology.of(kind),
    ),
    footerBuilder: (context) => const _UnderstoodButton(),
  );
}

class HelpSheetBody extends StatelessWidget {
  final HelpContent content;
  final Methodology? methodology;

  const HelpSheetBody({super.key, required this.content, this.methodology});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final palette = CalculatorScope.of(context);
    final body = AppTextStyles.body.copyWith(color: colors.textPrimary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(content.intro, style: body),
        _Section(title: 'O que cada campo significa', colors: colors),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colors.hairline)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final field in content.fields)
                _FieldDescription(field: field, colors: colors),
            ],
          ),
        ),
        _Section(title: 'Exemplo', colors: colors),
        Text(content.example, style: body),
        const SizedBox(height: AppSpacing.xs),
        Text(
          content.exampleResult,
          style: AppTextStyles.exampleValue.copyWith(color: palette.text),
        ),
        _Section(title: 'Como calculamos', colors: colors),
        Text(
          content.methodology,
          style: AppTextStyles.body.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colors.elevated,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content.formula,
            style: AppTextStyles.detailValue.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
        if (methodology case final methodology?) ...[
          _Section(title: Methodology.title, colors: colors),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colors.hairline)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final item in methodology.items)
                  _MethodologyItem(item: item, colors: colors),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MethodologyItem extends StatelessWidget {
  final MethodologyItem item;
  final AppColors colors;

  const _MethodologyItem({required this.item, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.hairline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              item.title,
              style: AppTextStyles.rowLabel.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.text,
            style: AppTextStyles.body.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final AppColors colors;

  const _Section({required this.title, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.sectionGap,
        bottom: AppSpacing.sm,
      ),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: AppTextStyles.sectionLabel.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _FieldDescription extends StatelessWidget {
  final HelpField field;
  final AppColors colors;

  const _FieldDescription({required this.field, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.hairline)),
      ),
      child: MergeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field.name,
              style: AppTextStyles.rowLabel.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              field.description,
              style: AppTextStyles.listDesc.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnderstoodButton extends StatelessWidget {
  const _UnderstoodButton();

  @override
  Widget build(BuildContext context) {
    final palette = CalculatorScope.of(context);

    return SizedBox(
      height: 56,
      child: FilledButton(
        onPressed: () => Navigator.of(context).pop(),
        style: FilledButton.styleFrom(
          backgroundColor: palette.solid,
          foregroundColor: palette.onSolid,
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.button,
        ),
        child: const Text('Entendi'),
      ),
    );
  }
}
