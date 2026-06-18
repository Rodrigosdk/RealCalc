import 'package:flutter/material.dart';
import 'package:real_calc/core/themes/extensions/menu_card_theme.dart';
import 'package:real_calc/core/themes/text_styles.dart';

class MenuCard extends StatelessWidget {
  final IconData icon;
  final Color cardColor;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const MenuCard({
    super.key,
    required this.icon,
    required this.cardColor,
    required this.iconColor,
    required this.title,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final menuTheme = Theme.of(context).extension<MenuCardTheme>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(menuTheme.borderRadius),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool telaMuitoPequena =
              constraints.maxHeight < menuTheme.heightThreshold;

          return Container(
            padding: telaMuitoPequena
                ? menuTheme.compactPadding
                : menuTheme.padding,
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(menuTheme.borderRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: menuTheme.iconContainerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: telaMuitoPequena ? 20 : 26,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        title,
                        style: telaMuitoPequena
                            ? menuTheme.titleStyle.copyWith(
                                fontSize:
                                    AppTextStyles.menuCardTitleCompact.fontSize,
                              )
                            : menuTheme.titleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                      ),
                      Text(
                        description,
                        style: telaMuitoPequena
                            ? menuTheme.descriptionStyle.copyWith(
                                fontSize: AppTextStyles
                                    .menuCardDescriptionCompact
                                    .fontSize,
                              )
                            : menuTheme.descriptionStyle.copyWith(
                                color: menuTheme.descriptionStyle.color
                                    ?.withValues(alpha: 0.5),
                              ),
                        maxLines: telaMuitoPequena ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
