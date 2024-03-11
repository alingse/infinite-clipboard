import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class SampleItemDetailsView extends StatelessWidget {
  const SampleItemDetailsView({
    super.key,
    required this.id,
  });

  final int id;
  static const routeName = '/sample_item';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: DatabaseHelper.getItemById(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final data = snapshot.data?['data'];
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
