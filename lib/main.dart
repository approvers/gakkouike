// 根幹モジュール
import 'dart:convert';
import 'package:flutter/material.dart';

// 自作モジュール
import 'calendar/calendar.dart';
import 'config/config.dart';
import 'CustomFAB/cool.dart';
import 'custom_types/config.dart';
import 'custom_types/subject.dart';
import 'package:gakkouike/cancel_class/cancel_class.dart';
import 'package:gakkouike/data_manager/subject_adder.dart';
import 'package:gakkouike/data_manager/subject_pref_util.dart';
import 'package:gakkouike/data_manager/subject_deleter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      home: HomePageRoot(),
    );
  }
}

class HomePageRoot extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: homePageAppBar(context),
      floatingActionButton: FABs(),
      body: HomePageContents()
    );
  }
  Widget homePageAppBar(BuildContext context){
    return AppBar(
      title: Text("学校行け"),
    );
  }
}

class FABs extends StatefulWidget{
  @override
  _FABsState createState() => _FABsState();
}

class _FABsState extends State<FABs>{
  bool isExpanded = false;
  @override
  Widget build(BuildContext context){
    return FoldFloatButtonWrap(
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
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 80,
                  child: Text("教科削除"),
                ),
                FloatingActionButton(
                  child: Icon(Icons.remove, size: 20,),
                  backgroundColor: Colors.deepOrangeAccent,
                  mini: true,
                  onPressed: (){
                    isExpanded ^= true;
                    Navigator.of(context).push(
                      new MaterialPageRoute(
                        builder: (BuildContext context) => new SubjectDeleter()
                      )
                    );
                  },
                  heroTag: "remove",
                )
              ],
            )

          ],
        );
  }
}

class HomePageContents extends StatefulWidget{
  @override
  _HomePageContentsState createState() => _HomePageContentsState();
}

class _HomePageContentsState extends State<HomePageContents>{
  bool setting = false;
  Config config;
  @override
  Widget build(BuildContext context){
    return FutureBuilder(
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
    if (subjects.length == 0){
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("俺を\n活用しろ\nカス",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 50,
                  height: 1.2,
              )
            ),
            Text("とりあえず右下のボタンからなんか登録しません?",
              textAlign: TextAlign.center
            )
          ],
        )
      );
    }
    return ListView.builder(
      itemBuilder: (BuildContext context, int index){
        return CardsContents(
          subject: subjects[index],
          config: config,
          index: index,
          parentWidget: this
        );
      },
      itemCount: subjects.length,
    );
  }
}



class CardsContents extends StatefulWidget{
  CardsContents(
    {
      this.subject,
      this.config,
      this.index,
      this.parentWidget
    }
   );
  Subject subject;
  Config config;
  int index;
  var parentWidget;
  @override
  _CardsContentsState createState() => _CardsContentsState();
}

class _CardsContentsState extends State<CardsContents>{
  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size;
    Color c;
    bool likeBrack = false;

    if (widget.subject.absenceDates.length / (widget.subject.scheduledClassNum - widget.subject.cancelClasses.length) >= widget.config.alertLine){
      if(widget.subject.absenceDates.length / (widget.subject.scheduledClassNum - widget.subject.cancelClasses.length)>= widget.config.redLine) c = Color.fromARGB(255, 0xff, 0x33, 0x33);
      else c = Colors.orangeAccent;
    }
    else c = widget.subject.color;
    if(c.red < 155 && c.blue < 155 && c.green < 155)
      likeBrack = true;
    
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
                      builder: (BuildContext context) => SubjectAdder(subject: widget.subject, index: widget.index)
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
                          widget.subject.name,
                          style: TextStyle(
                            fontSize: 28,
                            color: likeBrack ? Colors.white : Colors.black
                          ),
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
                                    Text(
                                      "欠課率 : ${(widget.subject.absenceDates.length / (widget.subject.scheduledClassNum - widget.subject.cancelClasses.length) * 100).toStringAsFixed(1)}%",
                                      style: TextStyle(
                                        color: likeBrack ? Colors.white : Colors. black
                                      )
                                    ),
                                    SizedBox(width: 10,),
                                    Text(
                                      "欠課時数 : ${widget.subject.absenceDates.length}",
                                      style: TextStyle(
                                        color: likeBrack ? Colors.white : Colors.black
                                      )
                                    
                                    )
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
                                  Text(
                                    "休講数: ${widget.subject.cancelClasses.length}",
                                    style: TextStyle(
                                      color: likeBrack ? Colors.white : Colors.black
                                    )
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "残り欠課数: ${(widget.subject.scheduledClassNum * widget.config.redLine - widget.subject.absenceDates.length).toInt()}",
                                    style: TextStyle(
                                      color: likeBrack ? Colors.white : Colors.black
                                    )
                                  )
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
                          if(widget.config.smartSet){
                            DateTime n = DateTime.now();
                            List<Subject> subjects = await SubjectPreferenceUtil.getSubjectListFromPref();
                            subjects[widget.index].absenceDates.add(DateTime(n.year, n.month, n.day));
                            await SubjectPreferenceUtil.saveSubjectList(subjects);
                            widget.subject = subjects[widget.index];
                          }else{
                            final DateTime cache = await showDatePicker(
                                context: context,
                                initialDate: widget.config.startClass.isAfter(DateTime.now()) ? 
                                  widget.config.startClass : widget.config.endClass.isBefore(DateTime.now()) ?
                                    widget.config.endClass : DateTime.now(),
                                firstDate: widget.config.startClass,
                                lastDate: widget.config.endClass,
                            );
                            if (cache != null){
                              if (cache.isAfter(widget.config.startClass) && cache.isBefore(widget.config.endClass)) {
                                List<Subject> subjects = await SubjectPreferenceUtil
                                    .getSubjectListFromPref();
                                subjects[widget.index].absenceDates.add(
                                    DateTime(cache.year, cache.month, cache.day));
                                await SubjectPreferenceUtil.
                                  saveSubjectList(subjects);
                                widget.subject = subjects[widget.index];
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
                          widget.parentWidget.setState(() {

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
                          if(subjects[widget.index].absenceDates.length == 0){
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
                                        widget.parentWidget.setState(() {});
                                      },
                                    )
                                  ]
                                );
                              }
                            );
                          }else if(widget.config.smartDelete){
                            subjects[widget.index].absenceDates.removeLast();
                            await SubjectPreferenceUtil.saveSubjectList(subjects);
                            widget.subject = subjects[widget.index];
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
                                          itemCount: widget.subject.absenceDates.length,
                                          itemBuilder: (BuildContext context, int i){
                                            return GestureDetector(
                                              child: ListTile(
                                                title: Text("${widget.subject.absenceDates[i].year}/"
                                                    "${widget.subject.absenceDates[i].month}/"
                                                    "${widget.subject.absenceDates[i].day}"),
                                              ),
                                              onTap: ()async{
                                                List<Subject> subjects = await SubjectPreferenceUtil.getSubjectListFromPref();
                                                subjects[widget.index].absenceDates.removeAt(i);
                                                await SubjectPreferenceUtil.saveSubjectList(subjects);
                                                widget.subject = subjects[widget.index];
                                                Navigator.pop(context);
                                                widget.parentWidget.setState(() {

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
                          widget.parentWidget.setState(() {

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


class AppBarContent extends StatefulWidget {
  AppBarContent(
    {
      this.parentWidget
    }
  );
  var parentWidget;
  @override
  _AppBarContentState createState() => _AppBarContentState();
}

class _AppBarContentState extends State<AppBarContent>{
  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size;
    return IconButton(
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
                                 Card(
                                   child: Padding(
                                     child: SizedBox(
                                       child:Text(
                                         subjects[index].name,
                                         style: TextStyle(fontSize: 20),
                                       ),
                                       height: size.height * 0.05,
                                       width: size.width * 0.62
                                     ),
                                     padding: EdgeInsets.only(top:5, bottom:5)
                                   ),
                                   color: subjects[index].color
                                 ),
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
                           widget.parentWidget.setState(() {

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
    );

  }
}
