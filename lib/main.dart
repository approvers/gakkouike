import 'package:flutter/material.dart';

// 自作モジュール
import 'calendar/calendar.dart';
import 'counter/counter.dart';
import 'config/config.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '学校行け',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("学校行け")),
      body: Container(
        child: Text("はよ実装しろカス"),
      ),
    );
  }
}
