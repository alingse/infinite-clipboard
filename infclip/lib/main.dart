import 'dart:async';
import 'package:flutter/material.dart';
import 'package:infclip/clip.dart';
import 'package:infclip/model.dart';

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
      home: const HomePage(title: 'Infinite Clipboard'),
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
  late DatabaseHandler handler;
  late ClipCtrl clipCtrl;

  int _count = 0;
  Timer? timer;
  List<ContentItem> _items = [];

  Future<void> loadResult() async {
    List<ContentItem> items = await handler.queryItems();
    setState(() {
      _count = items.length * 2;
      _items = items;
    });
  }

  @override
  void initState() {
    super.initState();
    clipCtrl = ClipCtrl();
    handler = DatabaseHandler();
    handler.initializeDB().whenComplete(() async {
      loadResult();
    });
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      loadResult();
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
          int index = (i / 2).ceil();
          ContentItem item = _items[index];
          String content = item.id.toString() + ":" + item.content;
          return RichText(
              text: TextSpan(
                  text: content, style: Theme.of(context).textTheme.headline4));
        });
  }
}
