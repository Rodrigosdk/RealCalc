import 'dart:ui';

abstract interface class ResultSharer {
  /// [origin] ancora o popover no iPad.
  Future<void> share(String text, {Rect? origin});
}
