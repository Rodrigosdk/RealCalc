import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/widgets/app_icon.dart';

Finder findAppIcon(String asset) => find.byWidgetPredicate(
  (widget) => widget is AppIcon && widget.asset == asset,
);
