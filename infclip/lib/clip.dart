import 'package:flutter/services.dart';
import 'package:infclip/model.dart';

class ClipCtrl {
  Future<ContentItem?> getClipBoardData() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      String content = data.text!;
      return ContentItem(content: content, contentType: contentTypeEnumText);
    }
    return null;
  }
}
