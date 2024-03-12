import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../model/record.dart';

class ItemDetailsView extends StatelessWidget {
  const ItemDetailsView({
    super.key,
    required this.id,
  });

  final int id;
  static const routeName = '/itemdetail';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Record?>(
      future: DatabaseProvider.getRecordByID(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final data = snapshot.data?.content ?? '';
          return Scaffold(
            appBar: AppBar(
              title: Text('ID Details: $id'),
            ),
            body: Center(
              child: Text('Data: $data'),
            ),
          );
        }
      },
    );
  }
}
