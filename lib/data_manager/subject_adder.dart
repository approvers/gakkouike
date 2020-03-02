import 'package:flutter/material.dart';
import 'package:gakkouike/data_manager/subject_pref_util.dart';

import '../custom_types/subject.dart';

class SubjectAdder extends StatelessWidget{

  final int index;
  final Subject subject;

  // TODO: SubjectPreferenceUtilにキャッシュ機能をもたせるなどして
  //       このクソみたいなコンストラクタをどうにかする
  SubjectAdder({Key key, this.subject, this.index=-1});

  @override
  Widget build(BuildContext context) {

    final nameTextController = new TextEditingController();
    final numberTextController = new TextEditingController();

    if(index >= 0){
      nameTextController.text = this.subject.name;
      numberTextController.text = this.subject.scheduledClassNum.toString();
    }

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
              onPressed: () async {
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
                    absenceDates: (index >= 0 ? subject.absenceDates : []),
                    scheduledClassNum: int.parse(numberTextController.text)
                );

                if(index >= 0){

                  bool continues = false;
                  // 欠課数が新しい授業数を超えてる(そんなことあってたまるか!)
                  if(this.subject.absenceDates.length > int.parse(numberTextController.text)){
                    await showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return AlertDialog(
                          title: Text("やばくね?"),
                          content: Text(
                            "あなた${this.subject.absenceDates.length}回欠課されてるんですけど、"
                            "新しく設定されようとしてる授業数が${int.parse(numberTextController.text)}回なんですよ\n"
                            "授業数を${this.subject.absenceDates.length}回にしてもいいですか?",
                            style: TextStyle(fontSize: 15),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text("待て何が起こった見せろ"),
                              onPressed: (){
                                Navigator.pop(context);
                              },
                            ),
                            FlatButton(
                              child: Text("いいっすよ"),
                              onPressed: (){
                                generated.scheduledClassNum = this.subject.absenceDates.length;
                                continues = true;
                                Navigator.pop(context);
                              },
                            )
                          ],
                        );
                      }
                    );

                    if(!continues) return;

                  }

                  List<Subject> subjectList = await SubjectPreferenceUtil.getSubjectListFromPref();
                  subjectList[index] = generated;
                  await SubjectPreferenceUtil.saveSubjectList(subjectList);
                  Navigator.pop(context);
                } else {
                  SubjectPreferenceUtil.addSubject(generated);
                  Navigator.pop(context);
                }

              }
            )
          ],
        ),
      ),
    );
  }
}