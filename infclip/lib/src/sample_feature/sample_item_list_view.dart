import 'package:flutter/material.dart';

import '../settings/settings_view.dart';
import 'sample_item.dart';
import 'sample_item_details_view.dart';

class SampleItemListView extends StatefulWidget {
  const SampleItemListView({
    super.key,
  });
  static const routeName = '/sample_list';

  @override
  // ignore: library_private_types_in_public_api
  _SampleItemListViewState createState() => _SampleItemListViewState();
}

class _SampleItemListViewState extends State<SampleItemListView> {
  List<String> items = [];
  int itemCount = 20; // 初始显示的行数
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
    // 模拟加载更多数据
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        itemCount += 20; // 每次加载20行
        items.addAll(
            List.generate(20, (index) => 'Item ${index + items.length}'));
      });
    });
  }

  Future<void> refreshItems() async {
    // 模拟下拉刷新
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      itemCount = 20; // 刷新后只显示20行
      items = List.generate(20, (index) => 'Item ${index + 1}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ListView Example'),
      ),
      body: RefreshIndicator(
        onRefresh: refreshItems,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (index == itemCount - 1) {
              // 当滚动到列表的最后一行时触发加载更多
              loadMoreItems();
            }
            return ListTile(
              title: Text('Item ${index + 1}'),
              subtitle: const Text('Hello'),
            );
          },
        ),
      ),
    );
  }
}
