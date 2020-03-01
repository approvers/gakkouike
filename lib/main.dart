import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gakkouike/data_manager/subject_adder.dart';
import 'package:gakkouike/subject_pref_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 自作モジュール
import 'calendar/calendar.dart';
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
                    content: ListView.builder(
                      itemCount: subjects.length,
                      itemBuilder: (BuildContext context, int index){
                        return GestureDetector(
                          child: ListTile(
                            title: Text(subjects[index].name),
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
                )



              ],
            ),
    );


  }

  Config config;

  Future loadData()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String rawConfig = pref.getString("config");

    if (rawConfig == null){
      config = new Config(endClass: null, startClass: null);
    }else {
      var jsonConfig = jsonDecode(rawConfig);
      config = Config.fromJson(jsonConfig);
      print(jsonConfig);
    }
    print(config is Config);
    List<Subject> subjects = await SubjectPreferenceUtil.getSubjectListFromPref();
    if (subjects == []){
      return Text("教科を登録してください");
    }
    return ListView.builder(
      itemBuilder: (BuildContext context, int index){
        print("${index.toString()}: ${config.smartSet}");
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
    print(config.smartSet);
    return Center(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: size.height * 0.15,
            width: size.width,
            child: Card(
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: size.width*0.05,
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
                          Text("欠課率 : ${(subject.absenceDates.dateTimeList.length / subject.scheduledClassNum * 100).toStringAsFixed(1)}%"),
                          SizedBox(width: 10,),
                          Text("欠課時数 : ${subject.absenceDates.dateTimeList.length}")
                        ]
                    )
                  ]),
                    width: size.width * 0.45,
                  ),
                  SizedBox(
                    width: size.width * 0.15,
                  ),
                  Container(child:
                  Card(
                    child: IconButton(
                      icon: Icon(Icons.add, size: 25),
                      onPressed: () async{
                        if(config.smartSet){
                          DateTime n = DateTime.now();
                          List<Subject> subjects = await SubjectPreferenceUtil.getSubjectListFromPref();
                          subjects[index].absenceDates.dateTimeList.add(DateTime(n.year, n.month, n.day));
                          await SubjectPreferenceUtil.saveSubjectList(subjects);
                          subject = subjects[index];
                        }else{
                          final DateTime cache = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: config.startClass,
                              lastDate: config.endClass
                          );
                          if (cache != null){
                            List<Subject> subjects = await SubjectPreferenceUtil.getSubjectListFromPref();
                            subjects[index].absenceDates.dateTimeList.add(DateTime(cache.year, cache.month, cache.day));
                            await SubjectPreferenceUtil.saveSubjectList(subjects);
                            subject = subjects[index];
                          }
                        }
                        setState(() {

                        });
                      },
                    ),
                    color: Colors.greenAccent,
                  ),
                  )
                  ,
                  Container(child:
                  Card(
                    child: IconButton(
                      icon: Icon(Icons.remove, size: 25,),
                      onPressed: () async{
                        if(config.smartDelete){
                          List<Subject> subjects = await SubjectPreferenceUtil.getSubjectListFromPref();
                          subjects[index].absenceDates.dateTimeList.removeLast();
                          await SubjectPreferenceUtil.saveSubjectList(subjects);
                          subject = subjects[index];
                        }else{
                          showDialog(
                              context: context,
                              builder: (BuildContext context){
                                return AlertDialog(
                                  title: Text("削除する"),
                                  content: ListView.builder(
                                    itemCount: subject.absenceDates.dateTimeList.length,
                                    itemBuilder: (BuildContext context, int i){
                                      return GestureDetector(
                                        child: ListTile(
                                          title: Text("${subject.absenceDates.dateTimeList[i].year}/"
                                              "${subject.absenceDates.dateTimeList[i].month}/"
                                              "${subject.absenceDates.dateTimeList[i].day}"),
                                        ),
                                        onTap: ()async{
                                          List<Subject> subjects = await SubjectPreferenceUtil.getSubjectListFromPref();
                                          print(subjects[index].absenceDates.dateTimeList);
                                          subjects[index].absenceDates.dateTimeList.removeAt(i);
                                          await SubjectPreferenceUtil.saveSubjectList(subjects);
                                          subject = subjects[index];
                                          Navigator.pop(context);
                                          setState(() {

                                          });
                                        },
                                      );
                                    },
                                  ),
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
                  )
                ],
              ),
            ),
          ),
        ],

      ),
    )
    ;
  }
}
