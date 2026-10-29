import 'package:flutter/material.dart';
import 'package:real_calc/core/themes/app_colors.dart';
import 'package:real_calc/core/themes/calculator_scope.dart';
import 'package:real_calc/core/themes/text_styles.dart';

/// Deve ficar no `body`, abaixo da rolagem, e não em `bottomNavigationBar`,
/// para subir junto com o teclado.
class BottomActionBar extends StatelessWidget {
  static const double buttonHeight = 56;
  static const EdgeInsets padding = EdgeInsets.fromLTRB(24, 12, 24, 30);
  static const shareLabel = 'Compartilhar resultado';

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool isLoading;

  final ValueChanged<Rect>? onShare;

  const BottomActionBar({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    this.onShare,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final palette = CalculatorScope.maybeOf(context);
    final solid = palette?.solid ?? scheme.primary;
    final onSolid = palette?.onSolid ?? scheme.onPrimary;

    return ColoredBox(
      color: colors.background,
      child: SafeArea(
        top: false,
        minimum: padding,
        child: Row(
          children: [
            Opacity(
              opacity: onShare == null ? 0.4 : 1,
              child: SizedBox.square(
                dimension: buttonHeight,
                child: Tooltip(
                  message: shareLabel,
                  excludeFromSemantics: true,
                  child: Semantics(
                    label: shareLabel,
                    button: true,
                    enabled: onShare != null,
                    child: Builder(
                      builder: (buttonContext) => OutlinedButton(
                        onPressed: onShare == null
                            ? null
                            : () => onShare!(_globalRect(buttonContext)),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: const CircleBorder(),
                          side: BorderSide(color: colors.hairline, width: 1.5),
                          foregroundColor: colors.textPrimary,
                          disabledForegroundColor: colors.textPrimary,
                        ),
                        child: const Icon(Icons.ios_share, size: 22),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: buttonHeight,
                child: FilledButton(
                  onPressed: isLoading ? null : onPrimary,
                  style: FilledButton.styleFrom(
                    backgroundColor: solid,
                    foregroundColor: onSolid,
                    disabledBackgroundColor: isLoading
                        ? solid
                        : solid.withValues(alpha: 0.4),
                    disabledForegroundColor: onSolid,
                    shape: const StadiumBorder(),
                    textStyle: AppTextStyles.button,
                  ),
                  child: isLoading
                      ? Semantics(
                          label: primaryLabel,
                          child: SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: onSolid,
                            ),
                          ),
                        )
                      : Text(primaryLabel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
showFieldsClearedSnackBar(
  BuildContext context, {
  required VoidCallback onUndo,
}) {
  final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
  return messenger.showSnackBar(
    SnackBar(
      content: const Text('Campos limpos'),
      duration: const Duration(seconds: 4),
      // Com ação, o SnackBar não some sozinho por padrão.
      persist: false,
      action: SnackBarAction(label: 'Desfazer', onPressed: onUndo),
    ),
  );
}

Rect _globalRect(BuildContext context) {
  final box = context.findRenderObject()! as RenderBox;
  return box.localToGlobal(Offset.zero) & box.size;
}
