import 'package:flutter/material.dart';
import 'package:real_calc/core/widgets/app_icon.dart';
import 'package:real_calc/core/themes/app_colors.dart';
import 'package:real_calc/core/themes/calculator_palette.dart';
import 'package:real_calc/core/themes/calculator_scope.dart';
import 'package:real_calc/core/themes/radius.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/themes/text_styles.dart';

Future<T?> showAppSheet<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder bodyBuilder,
  WidgetBuilder? footerBuilder,
  CalculatorKind? kind,
  bool scrollable = true,
}) {
  final colors = AppColors.of(context);

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.sheet,
    barrierColor: colors.scrim,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height - AppSheet.topGap,
    ),
    builder: (context) {
      final sheet = AppSheet(
        title: title,
        body: Builder(builder: bodyBuilder),
        footer: footerBuilder == null ? null : Builder(builder: footerBuilder),
        scrollable: scrollable,
      );
      return kind == null ? sheet : CalculatorScope(kind: kind, child: sheet);
    },
  );
}

class AppSheet extends StatelessWidget {
  static const double topGap = 96;
  static const closeLabel = 'Fechar';

  final String title;
  final Widget body;
  final Widget? footer;

  /// Com `false`, o corpo cuida da própria rolagem e do respiro inferior.
  final bool scrollable;

  const AppSheet({
    super.key,
    required this.title,
    required this.body,
    this.footer,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    final sheet = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textHint.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 8, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: AppTextStyles.sheetTitle.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
              MergeSemantics(
                child: Semantics(
                  label: closeLabel,
                  child: SizedBox.square(
                    dimension: 44,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      padding: EdgeInsets.zero,
                      color: colors.textSecondary,
                      icon: const AppIcon(AppIcons.close, size: 22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: scrollable
              ? SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.sm,
                    AppSpacing.screen,
                    footer == null
                        ? AppSpacing.lg + bottomInset
                        : AppSpacing.md,
                  ),
                  child: body,
                )
              : body,
        ),
        if (footer != null)
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              AppSpacing.md + bottomInset,
            ),
            child: footer,
          ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: sheet,
    );
  }
}
