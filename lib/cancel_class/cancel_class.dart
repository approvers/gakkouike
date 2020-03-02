import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gakkouike/custom_types/config.dart';
import 'package:gakkouike/custom_types/subject.dart';
import 'package:gakkouike/data_manager/subject_pref_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CancelManagerRoot extends StatefulWidget {
  @override
  _CancelManagerRootState createState() => _CancelManagerRootState();
}

class _CancelManagerRootState extends State<CancelManagerRoot>{
  Config config;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("休講管理"),
      ),
      body: Container(
        child:
          FutureBuilder(
            future: loadList(),
            builder: (BuildContext context, AsyncSnapshot snapshot){
              if(snapshot.hasData){
                return snapshot.data;
              }else if(snapshot.hasError){
                return snapshot.error;
              }else{
                return Container(
                  child: CircularProgressIndicator(),
                );
              }
            },
          )
        
      ),
    );
  }

  Future loadList() async{
    List<Subject> subjects = await SubjectPreferenceUtil.getSubjectListFromPref();
    if (config == null) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String rawConfig = pref.getString("config");
      var jsonConfig = jsonDecode(rawConfig);
      config = Config.fromJson(jsonConfig);
    }
    Size size = MediaQuery.of(context).size;
    return ListView.builder(
      itemBuilder: (BuildContext context, int index){
        Subject subject = subjects[index];
        return Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: size.height * 0.16,
                width: size.width,
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
                                    Text("休講数 : ${subject.cancelClasses.length}"),
                                  ],
                                ),
                                width: size.width * 0.57,
                                height: size.height * 0.04,
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
                                subjects[index].cancelClasses.add(
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
                                        "休講になるのは始業日と終業日の間でなくてはいけません",
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
                                              itemCount: subject.cancelClasses.length,
                                              itemBuilder: (BuildContext context, int i){
                                                return GestureDetector(
                                                  child: ListTile(
                                                    title: Text("${subject.cancelClasses[i].year}/"
                                                        "${subject.cancelClasses[i].month}/"
                                                        "${subject.cancelClasses[i].day}"),
                                                  ),
                                                  onTap: ()async{
                                                    List<Subject> subjects = await SubjectPreferenceUtil.getSubjectListFromPref();
                                                    subjects[index].cancelClasses.removeAt(i);
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
                ),
              ),
            ],
          ),
        );
      },
      itemCount: subjects.length,
    );
  }
}