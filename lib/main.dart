
import 'dart:async';
import 'package:curiosite/pages/favoritesPage.dart';
import 'package:curiosite/pages/historyPage.dart';
import 'package:curiosite/pages/settingsPage.dart';
import 'package:curiosite/pages/NavPage.dart';
import 'package:flutter/material.dart';

import 'model/modelProvider.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppModel model = AppModel();
  runApp(MaterialApp(
    title: 'Curiosite',
    theme: ThemeData(primarySwatch: Colors.blue,),
    initialRoute: '/',
    routes: {
      // When navigating to the "/" route, build the FirstScreen widget.
      '/': (context) => MyApp(model: model,),
      // When navigating to the "/second" route, build the SecondScreen widget.
      '/settings': (context) => const SettingsPage(),
      '/history':(context) => const HistoryPage(),
      '/favorites':(context) => const FavoritesPage(),
    },
  ));
}

class MyApp extends StatelessWidget {
  AppModel model;
  MyApp({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModelProvider(
      model: model,
      child: const MaterialApp(
        title: 'Curiosité',
        home: NavPage(),
      ),
    );
  }
}