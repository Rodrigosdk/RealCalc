import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_calc/core/themes/calculator_palette.dart';
import 'package:real_calc/core/themes/calculator_scope.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/themes/text_styles.dart';

import 'band_statement.dart';

class CalculatorBand extends StatelessWidget {
  static const double iconTouchSize = 44;
  static const double moneySymbolSize = 22;
  static const double minValueSize = 36;

  static const backLabel = 'Voltar';
  static const helpLabel = 'Como funciona';
  static const clearLabel = 'Limpar campos';

  static const statusBarStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  final String title;
  final BandStatement statement;
  final VoidCallback? onBack;
  final VoidCallback? onHelp;
  final VoidCallback? onClear;

  const CalculatorBand({
    super.key,
    required this.title,
    required this.statement,
    this.onBack,
    this.onHelp,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final palette =
        CalculatorScope.maybeOf(context) ??
        CalculatorPalette(
          solid: Theme.of(context).colorScheme.primary,
          onSolid: Theme.of(context).colorScheme.onPrimary,
          text: Theme.of(context).colorScheme.primary,
        );
    final onSolid = palette.onSolid;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: statusBarStyle,
      child: ColoredBox(
        color: palette.solid,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: [
                    _BandIconButton(
                      icon: Icons.arrow_back,
                      label: backLabel,
                      color: onSolid,
                      onPressed:
                          onBack ?? () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.headerTitle.copyWith(
                          color: onSolid,
                        ),
                      ),
                    ),
                    if (onHelp != null)
                      _BandIconButton(
                        icon: Icons.help_outline,
                        label: helpLabel,
                        color: onSolid,
                        onPressed: onHelp!,
                      ),
                    if (onClear != null)
                      _BandIconButton(
                        icon: Icons.refresh,
                        label: clearLabel,
                        color: onSolid,
                        onPressed: onClear!,
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.sm,
                  AppSpacing.screen,
                  AppSpacing.lg + 4,
                ),
                child: _Statement(statement: statement, color: onSolid),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Statement extends StatelessWidget {
  final BandStatement statement;
  final Color color;

  const _Statement({required this.statement, required this.color});

  @override
  Widget build(BuildContext context) {
    final soft = color.withValues(alpha: 0.82);

    return Semantics(
      container: true,
      liveRegion: true,
      label: statement.semanticsLabel,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (statement.kicker != null)
              Text(
                statement.kicker!,
                style: AppTextStyles.bandKicker.copyWith(color: soft),
              ),
            _StatementValue(statement: statement, color: color),
            if (statement.sub != null)
              Text(
                statement.sub!,
                style: AppTextStyles.bandSub.copyWith(color: soft),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatementValue extends StatelessWidget {
  final BandStatement statement;
  final Color color;

  const _StatementValue({required this.statement, required this.color});

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    final baseStyle = AppTextStyles.bandStatement.copyWith(color: color);
    final symbolStyle = baseStyle.copyWith(
      fontSize: CalculatorBand.moneySymbolSize,
      letterSpacing: -0.4,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final symbolWidth = statement.isMoney
            ? _measure('R\$', symbolStyle, textScaler) + 6
            : 0.0;
        final available = constraints.maxWidth - symbolWidth;
        final naturalWidth = _measure(statement.value, baseStyle, textScaler);
        final baseSize = baseStyle.fontSize!;
        final fontSize = naturalWidth <= available
            ? baseSize
            : math.max(
                CalculatorBand.minValueSize,
                (baseSize * available / naturalWidth).floorToDouble(),
              );

        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (statement.isMoney) ...[
                Text('R\$', style: symbolStyle),
                const SizedBox(width: 6),
              ],
              Text(
                statement.value,
                maxLines: 1,
                softWrap: false,
                style: baseStyle.copyWith(fontSize: fontSize),
              ),
            ],
          ),
        );
      },
    );
  }

  static double _measure(String text, TextStyle style, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }
}

class _BandIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _BandIconButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        label: label,
        child: SizedBox.square(
          dimension: CalculatorBand.iconTouchSize,
          child: IconButton(
            onPressed: onPressed,
            padding: EdgeInsets.zero,
            color: color,
            icon: Icon(icon, size: 22),
          ),
        ),
      ),
    );
  }
}
