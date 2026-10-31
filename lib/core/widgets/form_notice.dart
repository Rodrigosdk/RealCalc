import 'package:flutter/material.dart';
import 'package:real_calc/core/widgets/app_icon.dart';
import 'package:real_calc/core/themes/app_colors.dart';
import 'package:real_calc/core/themes/text_styles.dart';

class FormNotice extends StatelessWidget {
  final String title;
  final String message;
  final bool isError;

  const FormNotice({
    super.key,
    required this.title,
    required this.message,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final accent = isError ? colors.error : colors.textSecondary;

    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: AppIcon(AppIcons.alert, size: 20, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.rowLabel.copyWith(
                    color: isError ? colors.error : colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: AppTextStyles.body.copyWith(
                    color: colors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
