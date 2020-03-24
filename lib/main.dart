// 根幹モジュール
import 'package:flutter/material.dart';
import 'package:pucis/homepage/contents.dart';

// 自作モジュール
import 'calendar/calendar.dart';
import 'config/config.dart';
import 'CustomFAB/cool.dart';
import 'custom_types/subject.dart';
import 'package:pucis/cancel_class/cancel_class.dart';
import 'package:pucis/data_manager/subject_adder.dart';
import 'package:pucis/data_manager/subject_pref_util.dart';
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
        Row(
          children: <Widget>[
            SizedBox(
              width: 80,
              child: Text("カレンダー"),
            ),
            FloatingActionButton(
              child: Icon(
                Icons.calendar_today,
                size: 20,
              ),
              backgroundColor: Colors.deepOrangeAccent,
              mini: true,
              onPressed: () {
                setState(() {
                  isExpanded ^= true;
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) =>
                          new CalendarExample()));
                });
              },
              heroTag: "calendar",
            ),
          ],
        ),
        Row(
          children: <Widget>[
            SizedBox(
              width: 80,
              child: Text("教科追加"),
            ),
            FloatingActionButton(
              child: Icon(
                Icons.add,
                size: 20,
              ),
              backgroundColor: Colors.deepOrangeAccent,
              mini: true,
              onPressed: () {
                setState(() {
                  isExpanded ^= true;
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) => new SubjectAdder()));
                });
              },
              heroTag: "adder",
            ),
          ],
        ),
        Row(
          children: <Widget>[
            SizedBox(
              width: 80,
              child: Text("設定"),
            ),
            FloatingActionButton(
              child: Icon(
                Icons.settings,
                size: 20,
              ),
              backgroundColor: Colors.deepOrangeAccent,
              mini: true,
              onPressed: () async {
                isExpanded ^= true;
                Navigator.of(context)
                    .push(new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            new ConfigRootView()))
                    .then((_) {
                  setState(() {});
                });
                setState(() {});
              },
              heroTag: "config",
            ),
          ],
        ),
        Row(
          children: <Widget>[
            SizedBox(
              width: 80,
              child: Text("休講"),
            ),
            FloatingActionButton(
              child: Icon(
                Icons.block,
                size: 20,
              ),
              backgroundColor: Colors.deepOrangeAccent,
              mini: true,
              onPressed: () {
                isExpanded ^= true;
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) =>
                        new CancelManagerRoot()));
              },
              heroTag: "cancel",
            )
          ],
        ),
        Row(
          children: <Widget>[
            SizedBox(
              width: 80,
              child: Text("教科削除"),
            ),
            FloatingActionButton(
              child: Icon(
                Icons.remove,
                size: 20,
              ),
              backgroundColor: Colors.deepOrangeAccent,
              mini: true,
              onPressed: () {
                isExpanded ^= true;
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => new SubjectDeleter()));
              },
              heroTag: "remove",
            )
          ],
        )
      ],
    );
  }
}

class AppBarContent extends StatefulWidget {
  AppBarContent({this.parentWidget});
  var parentWidget;
  @override
  _AppBarContentState createState() => _AppBarContentState();
}

class _AppBarContentState extends State<AppBarContent> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return IconButton(
      icon: Icon(Icons.remove),
      onPressed: () async {
        List<Subject> subjects =
            await SubjectPreferenceUtil.getSubjectListFromPref();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: Text("削除する教科を選択"),
                  content: Container(
                    width: size.width * 0.8,
                    height: size.height * 0.2,
                    child: ListView.builder(
                        itemCount: subjects.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            child: Column(children: [
                              Row(
                                children: <Widget>[
                                  Card(
                                      child: Padding(
                                          child: SizedBox(
                                              child: Text(
                                                subjects[index].name,
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              height: size.height * 0.05,
                                              width: size.width * 0.62),
                                          padding: EdgeInsets.only(
                                              top: 5, bottom: 5)),
                                      color: subjects[index].color),
                                ],
                              ),
                              index + 1 == subjects.length
                                  ? Container()
                                  : Divider()
                            ]),
                            onTap: () {
                              showDialog<bool>(
                                  context: context,
                                  builder: (_) {
                                    return AlertDialog(
                                      title: Text("本当に削除してもいいですか?"),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text("No"),
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                        ),
                                        FlatButton(
                                          child: Text("Yes"),
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                        )
                                      ],
                                    );
                                  }).then((v) {
                                if (v)
                                  SubjectPreferenceUtil.deleteSubjectAt(index);
                                Navigator.pop(context);
                                widget.parentWidget.setState(() {});
                              });
                            },
                          );
                        }),
                  ));
            });
      },
    );
  }
}
