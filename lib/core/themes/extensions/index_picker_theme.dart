import 'package:flutter/material.dart';

class IndexPickerTheme extends ThemeExtension<IndexPickerTheme> {
  final Color backgroundColor;
  final Color surfaceColor;
  final Color dividerColor;
  final Color selectedColor;
  final Color selectedBorderColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color checkColor;
  final TextStyle sectionTitleStyle;
  final TextStyle itemTitleStyle;
  final TextStyle itemSubtitleStyle;

  const IndexPickerTheme({
    required this.backgroundColor,
    required this.surfaceColor,
    required this.dividerColor,
    required this.selectedColor,
    required this.selectedBorderColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.checkColor,
    required this.sectionTitleStyle,
    required this.itemTitleStyle,
    required this.itemSubtitleStyle,
  });

  @override
  IndexPickerTheme copyWith({
    Color? backgroundColor,
    Color? surfaceColor,
    Color? dividerColor,
    Color? selectedColor,
    Color? selectedBorderColor,
    Color? titleColor,
    Color? subtitleColor,
    Color? checkColor,
    TextStyle? sectionTitleStyle,
    TextStyle? itemTitleStyle,
    TextStyle? itemSubtitleStyle,
  }) {
    return IndexPickerTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      dividerColor: dividerColor ?? this.dividerColor,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedBorderColor: selectedBorderColor ?? this.selectedBorderColor,
      titleColor: titleColor ?? this.titleColor,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      checkColor: checkColor ?? this.checkColor,
      sectionTitleStyle: sectionTitleStyle ?? this.sectionTitleStyle,
      itemTitleStyle: itemTitleStyle ?? this.itemTitleStyle,
      itemSubtitleStyle: itemSubtitleStyle ?? this.itemSubtitleStyle,
    );
  }

  @override
  IndexPickerTheme lerp(ThemeExtension<IndexPickerTheme>? other, double t) {
    if (other is! IndexPickerTheme) return this;

    return IndexPickerTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      selectedColor: Color.lerp(selectedColor, other.selectedColor, t)!,
      selectedBorderColor:
          Color.lerp(selectedBorderColor, other.selectedBorderColor, t)!,
      titleColor: Color.lerp(titleColor, other.titleColor, t)!,
      subtitleColor: Color.lerp(subtitleColor, other.subtitleColor, t)!,
      checkColor: Color.lerp(checkColor, other.checkColor, t)!,
      sectionTitleStyle:
          TextStyle.lerp(sectionTitleStyle, other.sectionTitleStyle, t)!,
      itemTitleStyle: TextStyle.lerp(itemTitleStyle, other.itemTitleStyle, t)!,
      itemSubtitleStyle:
          TextStyle.lerp(itemSubtitleStyle, other.itemSubtitleStyle, t)!,
    );
  }
}
