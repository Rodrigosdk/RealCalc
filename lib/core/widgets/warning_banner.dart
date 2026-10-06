import 'package:flutter/material.dart';

import '../themes/extensions/warning_banner_theme.dart';

class WarningBanner extends StatelessWidget {
  final String message;

  const WarningBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<WarningBannerTheme>()!;

    return Container(
      width: double.infinity,
      padding: theme.padding,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(theme.borderRadius),
        border: Border.all(color: theme.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: theme.iconColor,
            size: theme.iconSize,
          ),
          SizedBox(width: theme.iconTextSpacing),
          Expanded(child: Text(message, style: theme.textStyle)),
        ],
      ),
    );
  }
}
