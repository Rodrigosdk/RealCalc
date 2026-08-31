import 'package:flutter/material.dart';
import 'package:real_calc/core/themes/extensions/help_card_theme.dart';

class HelpCard extends StatelessWidget {
  final String menssage;

  const HelpCard({super.key, required this.menssage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<HelpCardTheme>()!;

    return Container(
      width: double.infinity,
      padding: theme.padding,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(theme.borderRadius),
        border: Border.all(
          color: theme.borderColor.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: theme.iconBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lightbulb,
              color: theme.iconColor,
              size: theme.iconSize,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(menssage, style: theme.messageStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
