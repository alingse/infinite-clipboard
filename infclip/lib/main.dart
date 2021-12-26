import 'package:flutter/material.dart';

void main() {
  runApp(const ClipApp());
}

class ClipApp extends StatelessWidget {
  const ClipApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinite Clipboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Infinite Clipboard Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _count = 0;

  void onResult(int count) {
    setState(() {
      _count = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _buildItems(),
    );
  }

  Widget _buildItems() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _count,
        itemBuilder: (context, i) {
          if (i.isOdd) return const Divider();
          return RichText(
              text: TextSpan(
                  text: '$i', style: Theme.of(context).textTheme.headline4));
        });
  }
}
