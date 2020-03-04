import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gakkouike/cancel_class/cancel_class.dart';
import 'package:gakkouike/data_manager/subject_adder.dart';
import 'package:gakkouike/data_manager/subject_pref_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 自作モジュール
import 'calendar/calendar.dart';
import 'config/config.dart';
import 'CustomFAB/cool.dart';
import 'custom_types/config.dart';
import 'custom_types/subject.dart';
import 'config/inital_config.dart';

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
  bool setting = false;
  Config config;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("学校行け"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () async{
              List<Subject> subjects = await SubjectPreferenceUtil.getSubjectListFromPref();
              showDialog(
                context: context,
                builder: (BuildContext context){
                  return AlertDialog(
                    title: Text("削除する教科を選択"),
                    content: Container(
                      width: size.width * 0.8,
                      height: size.height * 0.2,
                      child: ListView.builder(
                        itemCount: subjects.length,
                        itemBuilder: (BuildContext context, int index){
                          return GestureDetector(
                            child: Column(
                                children: [
                                  Row(
                                    children: <Widget>[
                                      Text(subjects[index].name,
                                        style: TextStyle(fontSize: 20),),
                                    ],
                                  ),

                                  index + 1 == subjects.length ? Container()
                                      : Divider()
                                ]
                            ),
                            onTap: (){
                              showDialog<bool>(
                                context: context,
                                builder: (_){
                                  return AlertDialog(
                                    title: Text("本当に削除してもいいですか?"),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text("No"),
                                        onPressed: () => Navigator.of(context).pop(false),
                                      ),
                                      FlatButton(
                                        child: Text("Yes"),
                                        onPressed: () => Navigator.of(context).pop(true),
                                      )
                                    ],
                                  );
                                }
                              ).then((v){
                                if (v) SubjectPreferenceUtil.deleteSubjectAt(index);
                                Navigator.pop(context);
                                setState(() {

                                });
                              });
                            },
                          );
                        }
                      ),
                    )
                  );
                }
              );
            },
          )
        ],
      ),
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
                                  builder: (BuildContext context) => new CalendarExample()
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
                      onPressed: ()async{
                        isExpanded ^= true;
                        Navigator.of(context).push(
                            new MaterialPageRoute(
                                builder: (BuildContext context) => new ConfigRootView()
                            )
                        ).then((_){
                          setState(() {
                          });
                        });
                        setState(() {
                        });
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
                      child: Icon(Icons.block, size: 20,),
                      backgroundColor: Colors.deepOrangeAccent,
                      mini: true,
                      onPressed: (){
                        isExpanded ^= true;
                        Navigator.of(context).push(
                          new MaterialPageRoute(
                            builder: (BuildContext context) => new CancelManagerRoot()
                          )
                        );
                      },
                      heroTag: "cancel",
                    )
                  ],
                )
              ],
            ),
    );
  }

  Future loadData()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String rawConfig = pref.getString("config");

    if (rawConfig == null){
      if (setting) return Container();
      setting = true;
      Navigator.of(context).push(
        new MaterialPageRoute(
          builder: (BuildContext context) => InitialConfigPage()
        )
      ).then<void>((_){
        setting = false;
      });
      return Container(
        child: CircularProgressIndicator(),
      );
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
        return view(
          context,
          subjects[index],
          config,
          index
        );
      },
      itemCount: subjects.length,
    );
  }

  Widget view(BuildContext context, Subject subject, Config config, int index) {
    Size size = MediaQuery.of(context).size;
    Color c;
    if (subject.absenceDates.length / (subject.scheduledClassNum - subject.cancelClasses.length) >= config.alertLine){
      if(subject.absenceDates.length / (subject.scheduledClassNum - subject.cancelClasses.length)>= config.redLine) c = Color.fromARGB(255, 0xff, 0x33, 0x33);
      else c = Colors.orangeAccent;
    }
    else c = subject.color;
    return Center(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: size.height * 0.2,
            width: size.width,
            child: InkWell(
              onTap: () async {
                Navigator.of(context).push(
                  new MaterialPageRoute(
                      builder: (BuildContext context) => SubjectAdder(subject: subject, index: index)
                  )
                );
              },
              child: Card(
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: size.width*0.02,
                    ),
                    SizedBox(child:
                    Column(children:[
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      SizedBox(
                        child: Text(
                          subject.name,
                          style: TextStyle(fontSize: 28,),
                        ),
                        width: size.width * 0.45,
                      ),
                      Divider(),
                      Row(
                          children: [
                            Container(
                              child:
                                ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: <Widget>[
                                    Text("欠課率 : ${(subject.absenceDates.length / (subject.scheduledClassNum - subject.cancelClasses.length) * 100).toStringAsFixed(1)}%"),
                                    SizedBox(width: 10,),
                                    Text("欠課時数 : ${subject.absenceDates.length}")
                                  ],
                                ),
                              width: size.width * 0.57,
                              height: size.height * 0.04,
                            )

                          ]
                      ),
                      Row(
                        children:[
                          Container(
                            child:
                              ListView(
                                scrollDirection: Axis.horizontal,
                                children:[
                                  Text("休講数: ${subject.cancelClasses.length}"),
                                  SizedBox(width: 10),
                                  Text("残り欠課数: ${(subject.scheduledClassNum * config.redLine - subject.absenceDates.length).toInt()}")
                                ]
                              ),
                              width: size.width * 0.57,
                              height: size.height * 0.04
                          )
                        ]
                     )
                      
                    ]),
                      width: size.width * 0.57,
                    ),
                    Container(child:
                    Card(
                      child: IconButton(
                        icon: Icon(Icons.add, size: 25),
                        onPressed: () async{
                          if(config.smartSet){
                            DateTime n = DateTime.now();
                            List<Subject> subjects = await SubjectPreferenceUtil.getSubjectListFromPref();
                            subjects[index].absenceDates.add(DateTime(n.year, n.month, n.day));
                            await SubjectPreferenceUtil.saveSubjectList(subjects);
                            subject = subjects[index];
                          }else{
                            print(config.startClass.isAfter(DateTime.now()));
                            print(config.startClass);
                            final DateTime cache = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: config.startClass.isAfter(DateTime.now()) ?
                                            DateTime.now().subtract(new Duration(days: 1)): config.startClass ,
                                lastDate: config.endClass.isBefore(DateTime.now()) ?
                                            DateTime.now().add(new Duration(days: 1)) : config.endClass
                            );
                            if (cache != null){
                              if (cache.isAfter(config.startClass) && cache.isBefore(config.endClass)) {
                                List<Subject> subjects = await SubjectPreferenceUtil
                                    .getSubjectListFromPref();
                                subjects[index].absenceDates.add(
                                    DateTime(cache.year, cache.month, cache.day));
                                await SubjectPreferenceUtil.
                                  saveSubjectList(subjects);
                                subject = subjects[index];
                              }
                              else showDialog(
                                context: context,
                                builder: (BuildContext context){
                                  return AlertDialog(
                                    title: Text("エラー"),
                                    content: Text(
                                      "欠課するのは始業日と終業日の間でなくてはいけません",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text("yeah"),
                                        onPressed: (){
                                          Navigator.pop(context);
                                        },
                                      )
                                    ],
                                  );
                                }
                              );
                            }
                          }
                          setState(() {

                          });
                        },
                      ),
                      color: Colors.greenAccent,
                    ),
                      width: size.width * 0.17,
                      height: size.width * 0.17,
                    )
                    ,
                    Container(child:
                    Card(
                      child: IconButton(
                        icon: Icon(Icons.remove, size: 25,),
                        onPressed: () async{
                          List<Subject> subjects = await SubjectPreferenceUtil.getSubjectListFromPref();
                          if(subjects[index].absenceDates.length == 0){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                      "あなたは神なのでまだ欠課していません。"
                                      "堕落しないようにこれからも出席を続けましょう。"
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text("yeah"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        setState(() {});
                                      },
                                    )
                                  ]
                                );
                              }
                            );
                          }else if(config.smartDelete){
                            subjects[index].absenceDates.removeLast();
                            await SubjectPreferenceUtil.saveSubjectList(subjects);
                            subject = subjects[index];
                          }else{
                            showDialog(
                                context: context,
                                builder: (BuildContext context){
                                  return Container(
                                    width: size.width * 0.8,
                                    height: size.height * 0.6,
                                      child: AlertDialog(
                                      title: Text("削除する"),
                                      content: Container(
                                        width: size.width * 0.8,
                                        height: size.height * 0.6,
                                        child: ListView.builder(
                                          itemCount: subject.absenceDates.length,
                                          itemBuilder: (BuildContext context, int i){
                                            return GestureDetector(
                                              child: ListTile(
                                                title: Text("${subject.absenceDates[i].year}/"
                                                    "${subject.absenceDates[i].month}/"
                                                    "${subject.absenceDates[i].day}"),
                                              ),
                                              onTap: ()async{
                                                List<Subject> subjects = await SubjectPreferenceUtil.getSubjectListFromPref();
                                                subjects[index].absenceDates.removeAt(i);
                                                await SubjectPreferenceUtil.saveSubjectList(subjects);
                                                subject = subjects[index];
                                                Navigator.pop(context);
                                                setState(() {

                                                });
                                              },
                                            );
                                          },
                                        ),
                                      )
                                    )
                                  );
                                }
                            );
                          }
                          setState(() {

                          });
                        },
                      ),
                      color: Colors.redAccent,
                    ),
                      width: size.width * 0.17,
                      height: size.width * 0.17,
                    )
                  ],
                ),
                color: c,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
