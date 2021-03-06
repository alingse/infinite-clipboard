import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:infclip/model.dart';

class ClipCtrl {
  late DatabaseHandler handler;

  ClipCtrl() {
    handler = DatabaseHandler();
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

  Future<List<ContentItem>> queryItems() async {
    List<ContentItem> items = await handler.queryItems();
    return items;
  }
}
