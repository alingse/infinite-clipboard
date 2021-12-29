/*
import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:isolate_handler/isolate_handler.dart';
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
  Timer.periodic(const Duration(milliseconds: 300), (t) {
    // clipCtrl.loadAndSave();
    log('async Loop');
  });
}

void clipSyncLoop2(Map<String, dynamic> context) {
  HandledIsolate.initialize(context);
  clipSyncLoop();
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

class IsolateKeepper2 {
  final isolates = IsolateHandler();

  void start() async {
    isolates.spawn<String>(
      clipSyncLoop2,
      name: 'loader',
      paused: false,
    );
  }
}
*/

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Welcome to the Isolate Handler example
///
/// In this example we will take a look at how to spawn an isolate and allow it
/// to communicate with the main isolate. The isolate will be using a plugin, too.
///
/// This will be a simple, but complete project. We will start an isolate and
/// send it a string, have it add a path to it and return the value.
///
/// We will also give our isolate a name to make it easy to access from
/// anywhere.

import 'package:isolate_handler/isolate_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
// Let's create a new IsolateHandler instance. This is what we will use
// to spawn isolates.
  final isolates = IsolateHandler();

// Variable where we can store the message.
  String pathMessage = 'The documents folder is ';

  @override
  void initState() {
    super.initState();

    // Start the isolate at the `entryPoint` function. We will be dealing with
    // string types here, so we will restrict communication to that type. If no type
    // is given, the type will be dynamic instead.
    isolates.spawn<String>(entryPoint,
        // Here we give a name to the isolate, by which we can access is later,
        // for example when sending it data and when disposing of it.
        name: 'path',
        // onReceive is executed every time data is received from the spawned
        // isolate. We will let the setPath function deal with any incoming
        // data.
        onReceive: setPath,
        // Executed once when spawned isolate is ready for communication. We will
        // send the isolate a request to perform its task right away.
        onInitialized: () => isolates.send(pathMessage, to: 'path'));
  }

  void setPath(String path) {
    // Show the new message.
    setState(() {
      pathMessage = path;
    });

    // We will no longer be needing the isolate, let's dispose of it.
    // isolates.kill('path');
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Isolate Handler example'),
          ),
          body: Center(child: Text(pathMessage)),
        ),
      );
}

// This function happens in the isolate.
void entryPoint(Map<String, dynamic> context) {
  // Calling initialize from the entry point with the context is
  // required if communication is desired. It returns a messenger which
  // allows listening and sending information to the main isolate.
  final messenger = HandledIsolate.initialize(context);

  // Triggered every time data is received from the main isolate.
  messenger.listen((msg) async {
    messenger.send("hello ok");
    //ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    // log(data.toString());
    log(msg);
  });
}
