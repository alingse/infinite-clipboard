import 'dart:async';

import 'package:flutter/services.dart';
import 'package:infclip/model.dart';

class ClipCtrl {
  late DatabaseHandler handler;
  Timer? timer;

  ClipCtrl() {
    handler = DatabaseHandler();
    timer = Timer.periodic(
        const Duration(milliseconds: 50), (Timer t) => {loadAndSave()});
  }

  Future<ContentItem?> getClipBoardData() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      String content = data.text!;
      return ContentItem(null, content, contentTypeEnumText);
    }
    return null;
  }

  Future<void> loadAndSave() async {
    ContentItem? item = await getClipBoardData();
    if (item == null || item.content == "") {
      return;
    }
    handler.saveItem(item);
  }
}
