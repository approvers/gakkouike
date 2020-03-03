import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../custom_types/config.dart';

class ConfigRootView extends StatefulWidget {
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigRootView>{
  bool changeAnySetting = false;
  bool first = true;
  Config config;
  final TextEditingController summerVacationController = new TextEditingController();
  final TextEditingController winterVacationController = new TextEditingController();
  final TextEditingController alertLineController = new TextEditingController();
  final TextEditingController redLineController = new TextEditingController();

  //TODO: 実装しろカス
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(changeAnySetting) {
          int exitCode = await showDialog<int>(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: Text("ああ待って待って"),
                  content: Text(
                      "設定変えられてるんですけど保存されてないんです\n"
                          "どうしますか?"
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("変えるのやめるわ"),
                      onPressed: () => Navigator.of(context).pop(0),
                    ),
                    FlatButton(
                      child: Text("一旦設定に戻りたい"),
                      onPressed: () => Navigator.of(context).pop(1),
                    ),
                    FlatButton(
                      child: Text("保存してくれ"),
                      onPressed: () => Navigator.of(context).pop(2),
                    )
                  ],
                );
              }
          );
          switch (exitCode) {
            case 0:
              Navigator.of(context).pop();
              return Future.value(false);
            case 1:
              return Future.value(false);
            case 2:
              await saveConfig();
              Navigator.of(context).pop();
              return Future.value(false);
            default:
              return Future.value(false);
          }
        } else {
          Navigator.of(context).pop();
          return Future.value(false);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text("設定"),),
        body:Container(
          child: FutureBuilder(
            future: loadConfig(),
            builder: (BuildContext context, AsyncSnapshot snapshot){
              if (snapshot.hasData){
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
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          onPressed: () async {
            saveConfig();
            Navigator.pop(context);
          }
        ),
      ),
    );
  }

  @override
  void dispose(){
    summerVacationController.dispose();
    winterVacationController.dispose();
    alertLineController.dispose();
    redLineController.dispose();
    super.dispose();
  }

  Future saveConfig() async{
    if (changeAnySetting){
      SharedPreferences pref = await SharedPreferences.getInstance();
      var rawJson = config.toJson();
      String json = jsonEncode(rawJson);
      pref.setString("config", json);
    }
  }

  Future loadConfig() async{
    // ここにロード処理
    if(first) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      var j = pref.getString("config");
      if (j == null) {
        config = new Config();
      } else {
        var jsonArray = json.decode(j);
        config = Config.fromJson(jsonArray);
      }
      first = false;
      summerVacationController.text = config.summerVacationLength.toString();
      winterVacationController.text = config.winterVacationLength.toString();
      alertLineController.text = config.alertLine.toString();
      redLineController.text = config.redLine.toString();
    }
    return Container(
      child: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              CheckboxListTile(
                activeColor: Colors.blue,
                title: Text("スマートセット"),
                subtitle: Text("+ボタンを押すだけで日付も登録されるようにする"),
                controlAffinity: ListTileControlAffinity.trailing,
                value: config.smartSet,
                onChanged: (_){
                  setState(() {
                    config.smartSet = !config.smartSet;
                    changeAnySetting = true;
                  });
                },
              ),

              CheckboxListTile(
                activeColor: Colors.blue,
                title: Text("スマートデリート"),
                subtitle: Text("-ボタンを押すだけで最後に登録したものが消えるようにする"),
                controlAffinity: ListTileControlAffinity.trailing,
                value: config.smartDelete,
                onChanged: (_){
                  setState(() {
                    config.smartDelete = !config.smartDelete;
                    changeAnySetting = true;
                  });
                },
              ),

              ListTile(
                title: Text("夏休みの期間"),
                subtitle: Text("夏休みの期間を週単位で入力してください"),
                onTap: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        title: Text("夏休みの期間"),
                        content: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "期間",
                            hintText: "夏休みの期間を入力してください"
                          ),
                          controller: summerVacationController,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("決定"),
                            onPressed: (){
                              String _input = summerVacationController.text;
                              if (_input.trim() == ""){
                                return;
                              }
                              try{
                                int num = int.parse(_input);
                                config.summerVacationLength = num;
                                changeAnySetting = true;
                                Navigator.of(context).pop();
                              }
                              catch(exception){
                               return;
                              }
                            },
                          ),
                          FlatButton(
                            child: Text("キャンセル"),
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    }
                  );
                },
              ),

              ListTile(
                title: Text("冬休みの期間"),
                subtitle: Text("冬休みの期間を週単位で入力してください"),
                onTap: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        title: Text("冬休みの期間"),
                        content: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "期間",
                            hintText: "冬休みの期間を入力してください"
                          ),
                          controller: winterVacationController,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("決定"),
                            onPressed: (){
                              String _input = winterVacationController.text;
                              if (_input.trim() == ""){
                                return;
                              }
                              try{
                                int num = int.parse(_input);
                                config.winterVacationLength = num;
                                changeAnySetting = true;
                                Navigator.of(context).pop();
                              }catch(exception){
                                return;
                              }
                            },
                          ),
                          FlatButton(
                            child: Text("キャンセル"),
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    }
                  );
                },
              ),

              ListTile(
                title: Text("警告ライン"),
                subtitle: Text("警告を出す欠課の割合を決定します"),
                onTap: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        title: Text("警告ライン"),
                        content: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "警告ライン",
                            hintText: "0から1までの中で警告を出すラインを決めてください"
                          ),
                          controller: alertLineController,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("決定"),
                            onPressed: (){
                              String _input = alertLineController.text;
                              if (_input.trim() == ""){
                                return;
                              }
                              try{
                                double num = double.parse(_input);
                                config.alertLine = num;
                                changeAnySetting = true;
                                Navigator.of(context).pop();
                              }catch(exception){
                                return;
                              }
                            },
                          ),
                          FlatButton(
                            child: Text("キャンセル"),
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    }
                  );
                },
              ),

              ListTile(
                title: Text("留年ライン"),
                subtitle: Text("留年が確定する欠課の割合を決定します"),
                onTap: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        title: Text("留年ライン"),
                        content: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "留年ライン",
                            hintText: "0から1までの中で留年が確定するラインを決めてください"
                          ),
                          controller: redLineController,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("決定"),
                            onPressed: (){
                              String _input = redLineController.text;
                              if (_input.trim() == ""){
                                return;
                              }
                              try{
                                double num = double.parse(_input);
                                config.redLine = num;
                                changeAnySetting = true;
                                Navigator.of(context).pop();
                              }catch(exception){
                                return;
                              }
                            },
                          ),
                          FlatButton(
                            child: Text("キャンセル"),
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    }
                  );
                },
              ),

              ListTile(
                title: Text("始業日"),
                subtitle: Text("授業の開始日を指定します"),
                onTap: () async{
                  final DateTime cache = await showDatePicker(
                      context: context,
                      initialDate: config.startClass,
                      firstDate: DateTime(2019),
                      lastDate: DateTime(2100)
                  );
                  if (cache != null){
                    if (config.endClass.isAfter(cache)) {
                      setState(() {
                        config.startClass = DateTime(
                            cache.year,
                            cache.month,
                            cache.day
                        );
                      });
                      changeAnySetting = true;
                    }else showDialog(
                        context: context,
                        builder: (BuildContext context){
                          return AlertDialog(
                            title: Text("エラー"),
                            content: Text(
                              "始業の前に終業する特殊な学校には対応していません",
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
                },
              ),

              ListTile(
                title: Text("終業日"),
                subtitle: Text("授業の終了日を指定します"),
                onTap: () async{
                  final DateTime cache = await showDatePicker(
                      context: context,
                      initialDate: config.endClass,
                      firstDate: DateTime(2019),
                      lastDate: DateTime(2100)
                  );
                  if (cache != null){
                    if (config.startClass.isBefore(cache)) {
                      setState(() {
                        config.endClass = DateTime(
                            cache.year,
                            cache.month,
                            cache.day
                        );
                      });
                      changeAnySetting = true;
                    }else showDialog(
                        context: context,
                        builder: (BuildContext context){
                          return AlertDialog(
                            title: Text("エラー"),
                            content: Text(
                              "始業の前に終業する特殊な学校には対応していません",
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
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
