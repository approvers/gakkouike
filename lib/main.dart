// 根幹モジュール
import 'package:flutter/material.dart';
import 'package:pucis/homepage/contents.dart';

// 自作モジュール
import 'calendar/calendar.dart';
import 'config/config.dart';
import 'CustomFAB/cool.dart';
import 'package:pucis/cancel_class/cancel_class.dart';
import 'package:pucis/data_manager/subject_adder.dart';
import 'package:pucis/data_manager/subject_deleter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pucis',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePageRoot(),
    );
  }
}

class HomePageRoot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: homePageAppBar(context),
        floatingActionButton: FABs(),
        body: HomePageContents());
  }

  Widget homePageAppBar(BuildContext context) {
    return AppBar(
      title: Text("Pucis"),
    );
  }
}

class FABs extends StatefulWidget {
  @override
  _FABsState createState() => _FABsState();
}

class _FABsState extends State<FABs> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return FoldFloatButtonWrap(
      isExpanded: isExpanded,
      floatButton: Container(
        child: FloatingActionButton(
          child: isExpanded ? Icon(Icons.close) : Icon(Icons.menu),
          backgroundColor: Colors.deepOrangeAccent,
          onPressed: () {
            setState(() {
              isExpanded ^= true;
            });
          },
        ),
        height: 60,
        width: 60,
      ),
      expandedWidget: <Widget>[
        FABRow(
          label: "カレンダー",
          icon: Icons.calendar_today,
          onPressed: () {
            setState(() {
              isExpanded ^= true;
              Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new CalendarExample()));
            });
          },
          heroTag: "calendar",
        ),
        FABRow(
            label: "教科追加",
            onPressed: () {
              setState(() {
                isExpanded ^= true;
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => new SubjectAdder()));
              });
            },
            icon: Icons.add,
            heroTag: "adder"),
        FABRow(
          label: "設定",
          onPressed: () {
            isExpanded ^= true;
            Navigator.of(context)
                .push(new MaterialPageRoute(
                    builder: (BuildContext context) => new ConfigRootView()))
                .then((_) {
              setState(() {});
            });
            setState(() {});
          },
          icon: Icons.settings,
          heroTag: "config",
        ),
        FABRow(
          label: "休講",
          icon: Icons.block,
          onPressed: () {
            isExpanded ^= true;
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new CancelManagerRoot()));
          },
          heroTag: "cancel",
        ),
        FABRow(
          label: "教科削除",
          icon: Icons.remove,
          onPressed: () {
            isExpanded ^= true;
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new SubjectDeleter()));
          },
          heroTag: "remove",
        )
      ],
    );
  }
}

class FABRow extends StatelessWidget {
  const FABRow(
      {@required this.label,
      @required this.onPressed,
      @required this.icon,
      @required this.heroTag});

  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 80,
          child: Text(label),
        ),
        FloatingActionButton(
          child: Icon(
            icon,
            size: 20,
          ),
          backgroundColor: Colors.deepOrangeAccent,
          mini: true,
          onPressed: onPressed,
          heroTag: heroTag,
        ),
      ],
    );
  }
}
