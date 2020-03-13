import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pucis/custom_types/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialConfigPage extends StatefulWidget{
  @override
  _InitialConfigPageState createState() => _InitialConfigPageState();
}

class _InitialConfigPageState extends State<InitialConfigPage>{
  DateTime startClass = DateTime(2020, 4, 1);
  DateTime endClass = DateTime(2021, 3, 31);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("初期設定")),
      body: Column(
        children: <Widget>[
          GestureDetector(
            child: Container(
              margin: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Colors.grey)
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                    child: Icon(Icons.settings),
                    padding: const EdgeInsets.all(10.0),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("始業日"),
                      Text("${startClass.year.toString()}/"
                          "${startClass.month.toString()}/"
                          "${startClass.day.toString()}",
                          style: TextStyle(fontSize: 20)
                      )
                    ],
                  )
                ],
              ),
            ),
            onTap:()  async{
              final cache = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100)
              );
              if (cache != null){
                startClass = DateTime(
                    cache.year,
                    cache.month,
                    cache.day
                );
              }
              setState(() {});
            },
          ),
          GestureDetector(
            child: Container(
              margin: EdgeInsets.only(left: 10, top: 5, right: 10, bottom:10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(color: Colors.grey)
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(Icons.settings),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("終業日"),
                      Text("${endClass.year.toString()}/"
                          "${endClass.month.toString()}/"
                          "${endClass.day.toString()}",
                          style: TextStyle(fontSize: 20)
                      )
                    ],
                  ),
                ],
              ),
            ),
            onTap: () async{
              final cache = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100)
              );
              if (cache != null){
                endClass = DateTime(
                    cache.year,
                    cache.month,
                    cache.day
                );
              }
              setState(() {});
            },
          ),

          RaisedButton(
            child: Text("†設定完了†"),
            onPressed: () async{
                if(endClass.isBefore(startClass)) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("-方向に日付を進めるなカス"),
                          actions: <Widget>[
                            FlatButton(
                              child: Text("yeah"),
                              onPressed: () => Navigator.pop(context),
                            )
                          ],
                        );
                      }
                  );
                  return;
                }
                Config config = new Config(startClass: startClass, endClass: endClass);
                SharedPreferences pref = await SharedPreferences.getInstance();
                String json = jsonEncode(config.toJson());
                await pref.setString("config", json);
                Navigator.of(context).pop(false);
            },
          )
        ],
      ),
    );
  }
}