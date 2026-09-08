import 'package:flutter/material.dart';
import 'package:real_calc/core/themes/extensions/page_header_theme.dart';

class PageHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;

  const PageHeader({super.key, required this.title, this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<PageHeaderTheme>()!;

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: preferredSize.height,
        child: Container(
          color: theme.backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: theme.iconColor, size: 20),
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(width: 4),
              Text(title, style: theme.titleStyle),
            ],
          ),
        ),
      ),
    );
  }
}