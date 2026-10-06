import 'package:share_plus/share_plus.dart';

import '../../domain/services/value_correction_sharer.dart';


class SharePlusValueCorrectionSharer implements ValueCorrectionSharer {
  @override
  Future<void> share(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }
}
