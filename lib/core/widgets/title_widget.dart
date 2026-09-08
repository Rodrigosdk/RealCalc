import 'package:flutter/material.dart';
import 'package:real_calc/core/themes/extensions/title_widget_theme.dart';
import 'package:real_calc/core/themes/spacing.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool? invert;

  const TitleWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.invert = false,
  });

  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).extension<TitleWidgetTheme>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        Text(
          title,
          style: invert == false ? styles.titleStyle : styles.subtitleStyle,
        ),
        Text(
          subtitle,
          style: invert == false ? styles.subtitleStyle : styles.titleStyle,
        ),
      ],
    );
  }
}
