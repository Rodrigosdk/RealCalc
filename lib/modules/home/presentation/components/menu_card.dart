import 'package:flutter/material.dart';
import 'package:real_calc/core/themes/extensions/menu_card_theme.dart';
import 'package:real_calc/modules/home/domain/enum/menu_card_variant.dart';

class MenuCard extends StatelessWidget {
  final IconData icon;
  final Color cardColor;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final MenuCardVariant variant;

  const MenuCard({
    super.key,
    required this.icon,
    required this.cardColor,
    required this.iconColor,
    required this.title,
    required this.description,
    this.onTap,
    this.variant = MenuCardVariant.standard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MenuCardTheme>()!;

    switch (variant) {
      case MenuCardVariant.featured:
        return _FeaturedMenuCard(
          icon: icon,
          cardColor: cardColor,
          iconColor: iconColor,
          title: title,
          description: description,
          onTap: onTap,
          theme: theme,
        );
      case MenuCardVariant.disabled:
        return _DisabledMenuCard(icon: icon, title: title, theme: theme);
      case MenuCardVariant.standard:
        return _StandardMenuCard(
          icon: icon,
          cardColor: cardColor,
          iconColor: iconColor,
          title: title,
          description: description,
          onTap: onTap,
          theme: theme,
        );
    }
  }
}

/// Card quadrado usado no grid 2 colunas.
class _StandardMenuCard extends StatelessWidget {
  final IconData icon;
  final Color cardColor;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final MenuCardTheme theme;

  const _StandardMenuCard({
    required this.icon,
    required this.cardColor,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.theme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(theme.borderRadius),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool telaMuitoPequena =
              constraints.maxHeight < theme.heightThreshold;

          return Container(
            key: const Key('menu_card_container'),
            padding: telaMuitoPequena ? theme.compactPadding : theme.padding,
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: telaMuitoPequena
                      ? theme.iconSizeCompact
                      : theme.iconSize,
                ),
                SizedBox(height: telaMuitoPequena ? 4 : 12),
                Text(
                  title,
                  style: telaMuitoPequena
                      ? theme.titleStyleCompact
                      : theme.titleStyle,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  description,
                  style: telaMuitoPequena
                      ? theme.descriptionStyleCompact
                      : theme.descriptionStyle,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Card full-width horizontal com borda de destaque, pra UMA ação principal.
class _FeaturedMenuCard extends StatelessWidget {
  final IconData icon;
  final Color cardColor;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final MenuCardTheme theme;

  const _FeaturedMenuCard({
    required this.icon,
    required this.cardColor,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.theme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(theme.borderRadius),
      child: Container(
        key: const Key('menu_card_container'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(theme.borderRadius),
          border: Border(
            left: BorderSide(color: theme.featuredBorderColor, width: 2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: theme.iconSize),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.titleStyleFeatured,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.descriptionStyleFeatured,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.descriptionStyleFeatured.color?.withValues(alpha: 0.6),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

/// Card full-width horizontal, sem interação, indicando indisponibilidade.
class _DisabledMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final MenuCardTheme theme;

  const _DisabledMenuCard({
    required this.icon,
    required this.title,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('menu_card_container'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.disabledLabelColor.withValues(alpha: 0.15),
        ),
        borderRadius: BorderRadius.circular(theme.borderRadius),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.disabledLabelColor, size: theme.iconSizeCompact),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$title · em breve',
              style: theme.disabledTextStyle.copyWith(
                color: theme.disabledLabelColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}