import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../settings/settings_view.dart';
import 'detailview.dart';
import '../model/record.dart';

class ItemListView extends StatefulWidget {
  const ItemListView({
    super.key,
  });
  static const routeName = '/itemlist';

  @override
  // ignore: library_private_types_in_public_api
  _ItemListViewState createState() => _ItemListViewState();
}

class _ItemListViewState extends State<ItemListView> {
  List<Record> items = [];
  int page = 0;
  int pageSize = 10;
  // ignore: prefer_final_fields
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadMoreItems();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void loadMoreItems() {
    Future.sync(() async {
      var records = await DatabaseProvider.getRecords(page, pageSize);
      if (records.isEmpty) {
        return;
      }

      setState(() {
        items.addAll(records);
        page += 1;
      });
    });
  }

  Future<void> refreshItems() async {
    setState(() {
      page = 0;
      items = [];
      loadMoreItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshItems,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: items.length,
          itemBuilder: (context, index) {
            if (index == items.length - 1) {
              // 当滚动到列表的最后一行时触发加载更多
              loadMoreItems();
            }
            var item = items[index];
            return ListTile(
              title: Text('Item ${index + 1} ${item.id}'),
              subtitle: Text(items[index].content),
              onTap: () {
                Navigator.restorablePushNamed(
                    context, ItemDetailsView.routeName,
                    arguments: {
                      'id': item.id,
                    });
              },
            );
          },
        ),
      ),
    );
  }
}
