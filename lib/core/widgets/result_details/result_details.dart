import 'package:flutter/material.dart';
import 'package:real_calc/core/themes/app_colors.dart';
import 'package:real_calc/core/themes/calculator_scope.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/themes/text_styles.dart';

import 'result_summary.dart';

/// Detalhes do resultado, abaixo da lista de campos: título, barra de
/// composição com legenda e linhas de detalhe. Sem cartão, sombra ou borda.
///
/// A cor de juros, rendimento ou correção vem do [CalculatorScope].
class ResultDetails extends StatelessWidget {
  static const double barHeight = 6;
  static const double lineHeight = 32;

  final ResultSummary summary;

  const ResultDetails({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final otherColor =
        CalculatorScope.maybeOf(context)?.solid ??
        Theme.of(context).colorScheme.primary;
    final composition = summary.composition;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            summary.title,
            style: AppTextStyles.sectionLabel.copyWith(
              color: colors.textSecondary,
            ),
          ),
          if (composition != null) ...[
            const SizedBox(height: 12),
            _CompositionBar(
              composition: composition,
              ownColor: colors.textPrimary,
              otherColor: otherColor,
              trackColor: colors.hairline,
            ),
            const SizedBox(height: 10),
            ExcludeSemantics(
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  _LegendItem(
                    segment: composition.own,
                    color: colors.textPrimary,
                    textColor: colors.textSecondary,
                  ),
                  _LegendItem(
                    segment: composition.other,
                    color: otherColor,
                    textColor: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          for (final line in summary.lines)
            _DetailRow(line: line, colors: colors),
        ],
      ),
    );
  }
}

class _CompositionBar extends StatelessWidget {
  final ResultComposition composition;
  final Color ownColor;
  final Color otherColor;
  final Color trackColor;

  const _CompositionBar({
    required this.composition,
    required this.ownColor,
    required this.otherColor,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    final own = composition.own.percent;
    final other = composition.other.percent;

    return Semantics(
      container: true,
      label: composition.semanticsLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ResultDetails.barHeight / 2),
        child: SizedBox(
          height: ResultDetails.barHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (own > 0)
                Expanded(
                  flex: own,
                  child: ColoredBox(color: ownColor),
                ),
              if (own > 0 && other > 0) const SizedBox(width: 2),
              if (other > 0)
                Expanded(
                  flex: other,
                  child: ColoredBox(color: otherColor),
                ),
              if (own == 0 && other == 0)
                Expanded(child: ColoredBox(color: trackColor)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final ResultSegment segment;
  final Color color;
  final Color textColor;

  const _LegendItem({
    required this.segment,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '${segment.label} ${segment.percent}%',
          style: AppTextStyles.caption.copyWith(color: textColor),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final ResultDetailLine line;
  final AppColors colors;

  const _DetailRow({required this.line, required this.colors});

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: ResultDetails.lineHeight),
        child: Row(
          children: [
            Expanded(
              child: Text(
                line.label,
                style: AppTextStyles.detailLabel.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              line.value,
              softWrap: false,
              style: AppTextStyles.detailValue.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
