import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:infclip/src/db/database_helper.dart';

import 'core/detailview.dart';
import 'core/listview.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String clipboardContent = '';
  Timer? clipboardTimer;

  @override
  void initState() {
    super.initState();
    startClipboardTimer();
    getClipboardContent();
  }

  @override
  void dispose() {
    clipboardTimer?.cancel();
    super.dispose();
  }

  void startClipboardTimer() {
    clipboardTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      getClipboardContent();
    });
  }

  Future<void> getClipboardContent() async {
    ClipboardData? clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData != null && clipboardData.text != null) {
      String newContent = clipboardData.text!;
      if (newContent != clipboardContent) {
        DatabaseProvider.insertRecord(newContent);
        setState(() {
          clipboardContent = newContent;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: widget.settingsController.themeMode,
          onGenerateRoute: (RouteSettings routeSettings) {
            final Map<String, dynamic>? arguments =
                routeSettings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: widget.settingsController);
                  case ItemDetailsView.routeName:
                    final int realID = arguments?['id'];
                    return ItemDetailsView(
                      id: realID,
                    );
                  case ItemListView.routeName:
                  default:
                    return const ItemListView();
                }
              },
            );
          },
        );
      },
    );
  }
}
