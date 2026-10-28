import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:real_calc/core/themes/app_colors.dart';
import 'package:real_calc/core/themes/app_image.dart';
import 'package:real_calc/core/themes/text_styles.dart';

class AppLogo extends StatelessWidget {
  static const double smallSymbolMaxHeight = 24;

  final double symbolHeight;
  final bool showWordmark;

  const AppLogo({super.key, this.symbolHeight = 26, this.showWordmark = true});

  @override
  Widget build(BuildContext context) {
    final amber = AppColors.of(context).brandAmber;
    final symbol = SvgPicture.asset(
      symbolHeight <= smallSymbolMaxHeight
          ? AppImage.appLogoSmall
          : AppImage.appLogo,
      height: symbolHeight,
      colorFilter: ColorFilter.mode(amber, BlendMode.srcIn),
    );

    return Semantics(
      label: 'RealCalc',
      image: true,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          symbol,
          if (showWordmark) ...[
            const SizedBox(width: 10),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Real',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextSpan(
                    text: 'Calc',
                    style: TextStyle(color: amber),
                  ),
                ],
              ),
              style: AppTextStyles.wordmark,
            ),
          ],
        ],
      ),
    );
  }
}
