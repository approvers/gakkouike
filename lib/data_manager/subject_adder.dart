import 'package:flutter/material.dart';
import 'package:gakkouike/subject_pref_util.dart';

import '../subject.dart';

class SubjectAdder extends StatelessWidget{
  @override
  Widget build(BuildContext context) => _SubjectAdder();
}

class _SubjectAdder extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final nameTextController = new TextEditingController();
    final numberTextController = new TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text("教科を追加する"),),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelStyle: TextStyle(fontSize: 18),
                labelText: "教科名",
                hintText: "欠課した教科の名前を入力してください"
              ),
              controller: nameTextController,
            ),
            Container(
              margin: EdgeInsets.all(10)
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelStyle: TextStyle(fontSize: 18),
                labelText: "予定されている授業数",
                hintText: "数字で入力をしましょう"
              ),
              controller: numberTextController,
            ),
            Container(
              margin: EdgeInsets.all(20)
            ),
            RaisedButton(
              child: Text("追加する"),
              shape: UnderlineInputBorder(),
              // ignore: missing_return
              onPressed: (){
                if(nameTextController.text == "" || numberTextController.text == ""){
                  return showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: Text("エラー"),
                        content: Text("必要なデータが入力されていません！"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("了解"),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      );
                    }
                  );
                }
                if(int.tryParse(numberTextController.text) == null) {
                  return showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: Text("エラー"),
                        content: Text("予定されている授業数に数値以外の何かが入力されています！"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("了解"),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      );
                    }
                  );
                }
                Subject generated = new Subject(
                    name: nameTextController.text,
                    absenceDates: [],
                    scheduledClassNum: int.parse(numberTextController.text)
                );

                SubjectPreferenceUtil.addSubject(generated);
                Navigator.pop(context);
              }
            )
          ],
        ),
      ),
    );
  }
}