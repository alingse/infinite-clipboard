import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:infclip/clip.dart';
import 'package:infclip/model.dart';

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  final handler = DatabaseHandler();
  await handler.initializeDB();
}

void main() async {
  await init();
  runApp(const ClipApp());
  final keepper = IsolateKeepper();
  keepper.start();
}

void clipSyncLoop() {
  final clipCtrl = ClipCtrl();
  clipCtrl.loadAndSave();
  //Timer.periodic(const Duration(milliseconds: 300), (t) {
  //  clipCtrl.loadAndSave();
  //});
}

class ClipApp extends StatelessWidget {
  const ClipApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinite Clipboard',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
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
  late ClipCtrl clipCtrl;

  int _count = 0;
  Timer? timer;
  List<ContentItem> _items = [];

  Future<void> loadResult() async {
    List<ContentItem> items = await clipCtrl.queryItems();
    setState(() {
      _count = items.length * 2;
      _items = items;
    });
  }

  @override
  void initState() {
    super.initState();
    clipCtrl = ClipCtrl();
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
          String content = item.id.toString() + ". " + item.content;
          return RichText(
              text: TextSpan(
                  text: content, style: Theme.of(context).textTheme.headline6));
        });
  }
}

class IsolateKeepper {
  late Isolate? _isolate;
  late ReceivePort _receivePort;

  void start() async {
    log("start keepper");
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_runTimer, _receivePort.sendPort);
    _receivePort.listen(_handleRecv, onDone: () {
      log("done!");
    });
  }

  static void _runTimer(SendPort sendPort) async {
    clipSyncLoop();
    Timer.periodic(const Duration(seconds: 1), (Timer t) {
      sendPort.send("ok");
    });
  }

  void _handleRecv(dynamic data) {
    log('RECEIVED: ' + data);
  }

  void stop() {
    if (_isolate != null) {
      _receivePort.close();
      _isolate!.kill(priority: Isolate.immediate);
    }
  }
}
