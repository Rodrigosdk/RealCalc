import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/themes/color_tokens.dart';
import '../../../../core/themes/extensions/index_picker_theme.dart';
import '../../domain/enum/correction_group.dart';
import '../../domain/enum/correction_index.dart';

extension CorrectionGroupLabel on CorrectionGroup {
  String get label => switch (this) {
    CorrectionGroup.inflation => 'Inflação',
    CorrectionGroup.interest => 'Juros',
    CorrectionGroup.savings => 'Poupança',
  };
}

class CorrectionIndexPicker extends StatelessWidget {
  final List<CorrectionIndex> indices;
  final CorrectionIndex? selectedIndex;
  final ValueChanged<CorrectionIndex>? onSelected;

  const CorrectionIndexPicker({
    super.key,
    this.indices = CorrectionIndex.values,
    this.selectedIndex,
    this.onSelected,
  });

  Map<CorrectionGroup, List<CorrectionIndex>> get _groupedIndices {
    return {
      CorrectionGroup.inflation: indices
          .where((index) => index.group == CorrectionGroup.inflation)
          .toList(),
      CorrectionGroup.interest: indices
          .where((index) => index.group == CorrectionGroup.interest)
          .toList(),
      CorrectionGroup.savings: indices
          .where((index) => index.group == CorrectionGroup.savings)
          .toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<IndexPickerTheme>() ??
        const IndexPickerTheme(
          backgroundColor: ColorTokens.surface,
          surfaceColor: ColorTokens.background,
          dividerColor: ColorTokens.border,
          selectedColor: ColorTokens.accentAmber,
          selectedBorderColor: ColorTokens.accentAmber,
          titleColor: ColorTokens.textPrimary,
          subtitleColor: ColorTokens.textSecondary,
          checkColor: ColorTokens.accentAmber,
          sectionTitleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: ColorTokens.textSecondary,
          ),
          itemTitleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorTokens.textPrimary,
          ),
          itemSubtitleStyle: TextStyle(
            fontSize: 12,
            color: ColorTokens.textSecondary,
          ),
        );

    final groupedIndices = _groupedIndices;
    final sections = CorrectionGroup.values
        .map((group) {
          final items = groupedIndices[group] ?? const <CorrectionIndex>[];
          if (items.isEmpty) return null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Text(
                  group.label.toUpperCase(),
                  style: theme.sectionTitleStyle,
                ),
              ),
              ...items.map((index) {
                final isSelected = selectedIndex == index;
                final dateText = DateFormat('dd/MM/yyyy').format(
                  index.availableFrom,
                );

                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: isSelected ? theme.selectedColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? theme.selectedBorderColor
                          : Colors.transparent,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      key: ValueKey(index.name),
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      title: Text(
                        index.label,
                        style: theme.itemTitleStyle.copyWith(
                          color: isSelected ? theme.titleColor : theme.titleColor,
                        ),
                      ),
                      subtitle: Text(
                        'desde $dateText',
                        style: theme.itemSubtitleStyle,
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: theme.checkColor)
                          : null,
                      onTap: () {
                        onSelected?.call(index);
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                );
              }),
            ],
          );
        })
        .whereType<Column>()
        .toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Selecione um índice',
                style: theme.itemTitleStyle.copyWith(fontSize: 24),
              ),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 16),
              children: sections,
            ),
          ),
        ],
      ),
    );
  }
}
