import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infclip/src/core/listview.dart';
import '../db/database_helper.dart';
import '../model/record.dart';

class ItemDetailsView extends StatefulWidget {
  const ItemDetailsView({
    super.key,
    required this.id,
  });
  static const routeName = '/itemdetail';
  final int id;

  @override
  // ignore: library_private_types_in_public_api
  _ItemDetailsViewState createState() => _ItemDetailsViewState(id: id);
}

class _ItemDetailsViewState extends State<ItemDetailsView> {
  _ItemDetailsViewState({required this.id});

  final int id;
  bool edit = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Record?>(
      future: DatabaseProvider.getRecordByID(this.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final data = snapshot.data?.content ?? '';
          final createdAt = snapshot.data?.createdAt ?? '';
          final copyTimes = snapshot.data?.copyTimes ?? 0;
          return Scaffold(
            appBar: AppBar(
              title: Text('ID Details: $id'),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text('Created at:'),
                      VerticalDivider(),
                      Text('$createdAt'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text('Copy Count:'),
                      VerticalDivider(),
                      Text('$copyTimes'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await Future.sync(() async {
                            await Clipboard.setData(ClipboardData(text: data));
                            Navigator.restorablePushNamed(
                                context, ItemListView.routeName);
                          });
                        },
                        child: const Text('Copy'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          edit = true;
                          Navigator.restorablePushNamed(
                              context, ItemListView.routeName);
                        },
                        child: const Text('Edit'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.restorablePushNamed(
                              context, ItemListView.routeName);
                        },
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Text(
                        data,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
