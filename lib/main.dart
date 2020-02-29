import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gakkouike/data_manager/subject_adder.dart';
import 'package:gakkouike/subject_pref_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 自作モジュール
import 'calendar/calendar.dart';
import 'counter/counter.dart';
import 'config/config.dart';
import 'CustomFAB/cool.dart';
import 'config.dart';
import 'subject.dart';

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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("学校行け")),
      body: FutureBuilder(
        future: loadData(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.hasData){
            return snapshot.data;
          }else if(snapshot.hasError){
            return Text(snapshot.error.toString());
          }else{
            return Container(
              child: CircularProgressIndicator(),
            );
          }
        },
      )
      ,
      floatingActionButton:
        FoldFloatButtonWrap(
          isExpanded: isExpanded,
          floatButton:
          Container(
            child: FloatingActionButton(
              child: isExpanded ? Icon(Icons.close) : Icon(Icons.menu),
              backgroundColor: Colors.deepOrangeAccent,
              onPressed: (){
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
                      child: Icon(Icons.calendar_today, size: 20,),
                      backgroundColor: Colors.deepOrangeAccent,
                      mini: true,
                      onPressed: (){
                        setState(() {
                          isExpanded ^= true;
                          Navigator.of(context).push(
                              new MaterialPageRoute(
                                  builder: (BuildContext context) => new CalendarRootView()
                              )
                          );
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
                      child: Icon(Icons.add, size: 20,),
                      backgroundColor: Colors.deepOrangeAccent,
                      mini: true,
                      onPressed: (){
                        setState(() {
                          isExpanded ^= true;
                          Navigator.of(context).push(
                              new MaterialPageRoute(
                                  builder: (BuildContext context) => new SubjectAdder()
                              )
                          );
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
                      child: Icon(Icons.settings, size: 20,),
                      backgroundColor: Colors.deepOrangeAccent,
                      mini: true,
                      onPressed: (){
                        setState(() {
                          isExpanded ^= true;
                          Navigator.of(context).push(
                              new MaterialPageRoute(
                                  builder: (BuildContext context) => new ConfigRootView()
                              )
                          );
                        });
                      },
                      heroTag: "config",
                    ),
                  ],
                )



              ],
            ),
    );
  }

  Future loadData()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String rawConfig = pref.getString("config");
    Config config;
    print(rawConfig);

    if (rawConfig == null){
      config = new Config(endClass: null, startClass: null);
      print("ok");
    }else {
      var jsonConfig = jsonDecode(rawConfig);
      config = Config.fromJson(jsonConfig);
    }
    List<Subject> subjects = await SubjectPreferenceUtil.getSubjectListFromPref();
    if (subjects == []){
      return Text("教科を登録してください");
    }
    return ListView.builder(
      itemBuilder: (BuildContext context, int index){
        return CounterRootView(
          subject: subjects[index],
          smartSet: config.smartSet,
          smartDelete: config.smartDelete,
          index: index,
        );
      },
      itemCount: subjects.length,
    );
  }
}
