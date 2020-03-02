import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gakkouike/custom_types/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialConfigPage extends StatefulWidget{
  @override
  _InitialConfigPageState createState() => _InitialConfigPageState();
}

class _InitialConfigPageState extends State<InitialConfigPage>{
  DateTime startClass = DateTime(2019, 8, 10);
  DateTime endClass = DateTime(2100, 8, 10);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("初期設定")),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text("始業日: ${startClass.year.toString()}/"
                  "${startClass.month.toString()}/"
                  "${startClass.day.toString()}",
                style: TextStyle(fontSize: 30),
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () async{
                  final cache = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2200)
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
              )
            ],
          ),
          Row(
            children: <Widget>[
              Text("終業日: ${endClass.year.toString()}/"
                  "${endClass.month.toString()}/"
                  "${endClass.day.toString()}",
                style: TextStyle(fontSize: 30),
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () async{
                  final cache = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2200)
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
              )
            ],
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