import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'package:infclip/clip.dart';
import 'package:infclip/model.dart';

void init() {
  WidgetsFlutterBinding.ensureInitialized();
  final handler = DatabaseHandler();
  handler.initializeDB();
}

void main() {
  init();
  FlutterBackgroundService.initialize(clipLoop);

  runApp(const ClipApp());
}

void clipLoop() {
  init();

  final service = FlutterBackgroundService();

  service.onDataReceived.listen((event) {
    log(event.toString());
  });

  // bring to foreground
  service.setForegroundMode(true);
  var count = 0;
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    // if (!(await service.isServiceRunning())) timer.cancel();
    count += 1;
    // ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    service.setNotificationInfo(
      title: "+infclip keep Listening clipboard",
      content: "runing at ${DateTime.now()}",
    );

    service.sendData({
      "success": count,
    });
  });
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

  Timer? timer;
  Timer? clipTimer;

  int _count = 0;
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
    clipTimer =
        Timer.periodic(const Duration(milliseconds: 300), (timer) async {
      // await clipCtrl.loadAndSave();
    });

    timer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      loadResult();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _build(context),
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

  Widget _build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<Map<String, dynamic>?>(
          stream: FlutterBackgroundService().onDataReceived,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            clipCtrl.loadAndSave();

            final data = snapshot.data!;
            return Text(data.toString());
          },
        ),
      ],
    );
  }
}
