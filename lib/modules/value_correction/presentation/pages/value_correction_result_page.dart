import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_calc/core/themes/extensions/value_correction_result_theme.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/widgets/options_bottom_forms.dart';
import 'package:real_calc/core/widgets/page_header.dart';
import 'package:real_calc/modules/value_correction/domain/entites/value_correction.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';

class ValueCorrectionResultPage extends StatelessWidget {
  final ValueCorrection result;
  final VoidCallback onEdit;
  final VoidCallback? onShare;

  const ValueCorrectionResultPage({
    super.key,
    required this.result,
    required this.onEdit,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<ValueCorrectionResultTheme>()!;
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final factorFormat = NumberFormat('#,##0.0000000', 'pt_BR');
    final decimalFormat = NumberFormat('#,##0.00', 'pt_BR');
    final index = _indexFor(result.index);
    final consideredMonths = _monthsBetween(result.period.initial, result.period.end);

    return Scaffold(
      appBar: PageHeader(title: 'Correção de Valores', onBack: onEdit),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            spacing: AppSpacing.md,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${index.label} — ${DateFormat('MM/yyyy', 'pt_BR').format(result.period.initial)} a ${DateFormat('MM/yyyy', 'pt_BR').format(result.period.end)}',
                style: theme.subtitleStyle,
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.spotlightBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.spotlightBorderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Text(valueLabel, style: theme.spotlightLabelStyle),
                        if (hasAdjustedValue)
                          _SpotlightBadge(theme: theme),
                      ],
                    ),
                    Text(
                      displayedValue,
                      style: theme.spotlightValueStyle,
                    ),
                    Text(
                      supportingMessage(decimalFormat),
                      style: theme.spotlightVariationStyle.copyWith(
                        color: theme.variationPositiveColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardBackgroundColor,
                  border: Border.all(color: theme.cardBorderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ..._detailRows(currencyFormat, factorFormat, index, consideredMonths, theme),
                  ],
                ),
              ),
              OptionsBottomForms(
                onCalculate: onShare ?? () {},
                onClear: onEdit,
                calculateLabel: 'Compartilhar',
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get hasAdjustedValue => result.adjustedValue != null;

  String get valueLabel => hasAdjustedValue ? 'Valor corrigido' : 'Fator de correção';

  String get displayedValue {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final factorFormat = NumberFormat('#,##0.0000000', 'pt_BR');

    if (hasAdjustedValue) {
      return currencyFormat.format(result.adjustedValue!);
    }

    return factorFormat.format(result.factor);
  }

  String supportingMessage(NumberFormat decimalFormat) {
    final variationText =
        '${result.variation >= 0 ? '+' : ''}${decimalFormat.format(result.variation)}%';

    return hasAdjustedValue ? '$variationText no período' : 'fator acumulado';
  }

  List<_DetailRow> _detailRows(
    NumberFormat currencyFormat,
    NumberFormat factorFormat,
    CorrectionIndex index,
    int consideredMonths,
    ValueCorrectionResultTheme theme,
  ) {
    final rows = <_DetailRow>[];

    if (result.originalValue != null && hasAdjustedValue) {
      rows.add(
        _DetailRow(
          label: 'Valor original',
          value: currencyFormat.format(result.originalValue!),
          theme: theme,
        ),
      );
    }

    rows.addAll([
      _DetailRow(
        label: 'Fator de correção',
        value: factorFormat.format(result.factor),
        theme: theme,
      ),
      _DetailRow(
        label: 'Meses considerados',
        value: '$consideredMonths',
        theme: theme,
      ),
      _DetailRow(
        label: 'Índice',
        value: index.label,
        theme: theme,
      ),
    ]);

    return rows;
  }

  CorrectionIndex _indexFor(int value) {
    return CorrectionIndex.values.firstWhere(
      (index) => index.sgsCode == value,
      orElse: () => CorrectionIndex.ipca,
    );
  }

  int _monthsBetween(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + (end.month - start.month) + 1;
  }
}

class _SpotlightBadge extends StatelessWidget {
  final ValueCorrectionResultTheme theme;

  const _SpotlightBadge({
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: theme.spotlightBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'calculado',
        style: theme.spotlightVariationStyle.copyWith(
          fontSize: 10,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final ValueCorrectionResultTheme theme;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.detailLabelStyle),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.detailValueStyle,
            ),
          ),
        ],
      ),
    );
  }
}
