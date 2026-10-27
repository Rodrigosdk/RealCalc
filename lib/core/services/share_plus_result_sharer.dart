import 'dart:ui';

import 'package:share_plus/share_plus.dart';

import 'result_sharer.dart';

class SharePlusResultSharer implements ResultSharer {
  const SharePlusResultSharer();

  @override
  Future<void> share(String text, {Rect? origin}) async {
    await SharePlus.instance.share(
      ShareParams(text: text, sharePositionOrigin: origin),
    );
  }
}
