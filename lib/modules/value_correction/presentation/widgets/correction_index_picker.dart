import 'package:flutter/material.dart';
import 'package:real_calc/core/widgets/app_icon.dart';
import 'package:real_calc/core/themes/app_colors.dart';
import 'package:real_calc/core/themes/calculator_palette.dart';
import 'package:real_calc/core/themes/calculator_scope.dart';
import 'package:real_calc/core/themes/radius.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/themes/text_styles.dart';
import 'package:real_calc/core/widgets/app_sheet.dart';

import '../../domain/enum/correction_group.dart';
import '../../domain/enum/correction_index.dart';

const correctionIndexPickerTitle = 'Escolha o índice';
const correctionIndexSearchHint = 'Buscar índice';
const correctionIndexAllLabel = 'Todos';
const correctionIndexNoResults = 'Nenhum índice encontrado';

extension CorrectionGroupLabel on CorrectionGroup {
  String get label => switch (this) {
    CorrectionGroup.inflation => 'Inflação',
    CorrectionGroup.interest => 'Juros',
    CorrectionGroup.savings => 'Poupança',
  };
}

Future<void> showCorrectionIndexPicker(
  BuildContext context, {
  CorrectionIndex? selectedIndex,
  ValueChanged<CorrectionIndex>? onSelected,
}) {
  return showAppSheet<void>(
    context: context,
    title: correctionIndexPickerTitle,
    kind: CalculatorKind.correction,
    scrollable: false,
    bodyBuilder: (_) => CorrectionIndexPicker(
      selectedIndex: selectedIndex,
      onSelected: onSelected,
    ),
  );
}

String foldForSearch(String text) {
  const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const to = 'aaaaaeeeeiiiiooooouuuucn';
  final lower = text.toLowerCase();
  final buffer = StringBuffer();
  for (final char in lower.split('')) {
    final i = from.indexOf(char);
    buffer.write(i == -1 ? char : to[i]);
  }
  return buffer.toString();
}

class CorrectionIndexPicker extends StatefulWidget {
  final List<CorrectionIndex> indices;
  final CorrectionIndex? selectedIndex;
  final ValueChanged<CorrectionIndex>? onSelected;

  const CorrectionIndexPicker({
    super.key,
    this.indices = CorrectionIndex.values,
    this.selectedIndex,
    this.onSelected,
  });

  @override
  State<CorrectionIndexPicker> createState() => _CorrectionIndexPickerState();
}

class _CorrectionIndexPickerState extends State<CorrectionIndexPicker> {
  final _query = TextEditingController();
  final _searchFocus = FocusNode();
  CorrectionGroup? _group;

  @override
  void initState() {
    super.initState();
    _query.addListener(() => setState(() {}));
    _searchFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _query.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  bool _matches(CorrectionIndex index, String query) =>
      query.isEmpty ||
      foldForSearch(index.label).contains(query) ||
      foldForSearch(index.source).contains(query);

  void _select(CorrectionIndex index) {
    widget.onSelected?.call(index);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final palette =
        CalculatorScope.maybeOf(context) ??
        CalculatorPalette.of(
          CalculatorKind.correction,
          brightness: Theme.of(context).brightness,
        );
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final query = foldForSearch(_query.text.trim());
    final expanded = _searchFocus.hasFocus;

    final groups = [
      for (final group in CorrectionGroup.values)
        if (_group == null || _group == group)
          (
            group,
            widget.indices
                .where((i) => i.group == group && _matches(i, query))
                .toList(),
          ),
    ].where((entry) => entry.$2.isNotEmpty).toList();

    final list = groups.isEmpty
        ? Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.lg,
              AppSpacing.screen,
              AppSpacing.lg + bottomInset,
            ),
            child: Text(
              correctionIndexNoResults,
              style: AppTextStyles.body.copyWith(color: colors.textSecondary),
            ),
          )
        : ListView(
            shrinkWrap: !expanded,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screen,
              0,
              AppSpacing.screen,
              AppSpacing.lg + bottomInset,
            ),
            children: [
              for (final (group, items) in groups) ...[
                if (_group == null) _GroupHeader(group: group, colors: colors),
                for (final index in items)
                  _IndexRow(
                    index: index,
                    selected: index == widget.selectedIndex,
                    colors: colors,
                    palette: palette,
                    onTap: () => _select(index),
                  ),
              ],
            ],
          );

    return Column(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.sm,
            AppSpacing.screen,
            0,
          ),
          child: _SearchField(
            controller: _query,
            focusNode: _searchFocus,
            colors: colors,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.xs,
            AppSpacing.screen,
            0,
          ),
          child: _GroupTabs(
            active: _group,
            colors: colors,
            palette: palette,
            onChanged: (group) => setState(() => _group = group),
          ),
        ),
        Flexible(fit: expanded ? FlexFit.tight : FlexFit.loose, child: list),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final AppColors colors;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.search),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.rowLabel.copyWith(color: colors.textPrimary),
        decoration: InputDecoration(
          hintText: correctionIndexSearchHint,
          hintStyle: AppTextStyles.rowLabel.copyWith(color: colors.textHint),
          prefixIcon: AppIcon(
            AppIcons.search,
            color: colors.textHint,
            size: 22,
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpar busca',
                  onPressed: controller.clear,
                  color: colors.textSecondary,
                  icon: const AppIcon(AppIcons.close, size: 20),
                ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _GroupTabs extends StatelessWidget {
  final CorrectionGroup? active;
  final AppColors colors;
  final CalculatorPalette palette;
  final ValueChanged<CorrectionGroup?> onChanged;

  const _GroupTabs({
    required this.active,
    required this.colors,
    required this.palette,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = <(CorrectionGroup?, String)>[
      (null, correctionIndexAllLabel),
      for (final group in CorrectionGroup.values) (group, group.label),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.hairline)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final (group, label) in tabs)
              _Tab(
                label: label,
                selected: group == active,
                colors: colors,
                palette: palette,
                onTap: () => onChanged(group),
              ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final AppColors colors;
  final CalculatorPalette palette;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.selected,
    required this.colors,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        key: ValueKey('tab-$label'),
        onTap: onTap,
        child: Container(
          height: 44,
          margin: const EdgeInsets.only(right: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? palette.text : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.sectionLabel.copyWith(
              fontSize: 15,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? colors.textPrimary : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final CorrectionGroup group;
  final AppColors colors;

  const _GroupHeader({required this.group, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: AppSpacing.xs),
      child: Semantics(
        header: true,
        child: Text(
          group.label.toUpperCase(),
          style: AppTextStyles.sectionLabel.copyWith(
            color: colors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _IndexRow extends StatelessWidget {
  final CorrectionIndex index;
  final bool selected;
  final AppColors colors;
  final CalculatorPalette palette;
  final VoidCallback onTap;

  const _IndexRow({
    required this.index,
    required this.selected,
    required this.colors,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          key: ValueKey(index.name),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.rowHeightWithSecondLine,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.hairline)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        index.label,
                        style: AppTextStyles.rowLabel.copyWith(
                          color: colors.textPrimary,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${index.source}, desde ${index.sinceMonthLabel}',
                        style: AppTextStyles.listDesc.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: AppIcon(
                      AppIcons.check,
                      color: palette.text,
                      size: 22,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
