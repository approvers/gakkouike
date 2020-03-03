import 'package:flutter/material.dart';
import 'package:gakkouike/config/config.dart';
import 'package:gakkouike/data_manager/subject_pref_util.dart';

import '../custom_types/subject.dart';

class SubjectAdder extends StatefulWidget {

  final int index;
  final Subject subject;

  // TODO: SubjectPreferenceUtilにキャッシュ機能をもたせるなどして
  //       このクソみたいなコンストラクタをどうにかする
  SubjectAdder({Key key, this.subject, this.index = -1});
  @override
  State<StatefulWidget> createState() => _SubjectAdderState(this.subject);
}

class _SubjectAdderState extends State<SubjectAdder>{

  final nameTextController = new TextEditingController();
  final numberTextController = new TextEditingController();
  final calcedTextController = new TextEditingController();

  Color calcErrOccurred = Colors.black;

  _SubjectAdderState(Subject subject){
    if(subject != null){
      nameTextController.text = subject.name;
      // TODO: numberTextController、どうにかしたほうがいいかも?? (強い必要性はないとは思ふ)
      calcedTextController.text = subject.scheduledClassNum.toString();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("教科を追加する"),),
      body: Container(
        margin: EdgeInsets.all(20),
        child: ListView(
          children: <Widget>[
            Column(
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
                    labelText: "週あたりの時間数",
                    hintText: "1週間に授業が何回あるか教えてください"
                  ),
                  controller: numberTextController,
                  onChanged: (chg) async {
                    String numCalcedStr = "";
                    if (numberTextController.text.trim() == ""){
                      setState(() {
                      });
                    }
                    else if(int.tryParse(chg) == null){
                      numCalcedStr = "授業数、数字ではない";
                      setState(() {calcErrOccurred = Colors.red;});
                    } else {
                      int calculated = await Subject.calcClassesFromWeek(int.parse(chg));
                      numCalcedStr = calculated.toString();
                      setState(() {calcErrOccurred = Colors.black;});
                    }
                    calcedTextController.text = numCalcedStr;
                  },
                  keyboardType: TextInputType.number,
                ),
                Container(
                    margin: EdgeInsets.all(10)
                ),
                TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(fontSize: 18),
                      labelText: "自動計算された時間数(間違ってたら訂正してください)",
                      hintText: "↑を入力すると自動計算します  天才ですまん"
                  ),
                  style: TextStyle(
                      // TODO: 次のFlutterアプデで使えるようになります
                      // color: calcErrOccurred
                  ),
                  controller: calcedTextController,
                  onChanged: (chg) {
                    setState(() {
                      // TODO: 次のFlutterアプデで使えるようになります
                      // calcErrOccurred = (int.tryParse(calcedTextController.text) == null ? Colors.red : Colors.black);
                    });
                  },
                  keyboardType: TextInputType.number,
                ),
                Container(
                  margin: EdgeInsets.all(20)
                ),
                RaisedButton(
                  child: Text("追加する"),
                  shape: UnderlineInputBorder(),
                  // ignore: missing_return
                  onPressed: () async {
                    if(nameTextController.text == "" || calcedTextController.text == ""){
                      return showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: Text("エラー"),
                            content: Text("必要なデータが入力されていません！"),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("は、ミスっただけだが"),
                                onPressed: () => Navigator.pop(context),
                              )
                            ],
                          );
                        }
                      );
                    }
                    if(int.tryParse(calcedTextController.text) == null) {
                      return showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: Text("私にはその授業数が読めません！"),
                            content: Text("一般的に数字として定義されている文字を使用してください"),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("は、ミスっただけだが"),
                                onPressed: () => Navigator.pop(context),
                              )
                            ],
                          );
                        }
                      );
                    }

                    Subject generated = new Subject(
                        name: nameTextController.text,
                        absenceDates: (widget.index >= 0 ? widget.subject.absenceDates : []),
                        scheduledClassNum: int.parse(calcedTextController.text)
                    );

                    if(widget.index >= 0){

                      bool continues = false;
                      // 欠課数が新しい授業数を超えてる(そんなことあってたまるか!)
                      if(this.widget.subject.absenceDates.length > int.parse(calcedTextController.text)){
                        await showDialog(
                          context: context,
                          builder: (BuildContext context){
                            return AlertDialog(
                              title: Text("やばくね?"),
                              content: Text(
                                "あなた${this.widget.subject.absenceDates.length}回欠課されてるんですけど、"
                                "新しく設定されようとしてる授業数が${int.parse(calcedTextController.text)}回なんですよ\n"
                                "授業数を${this.widget.subject.absenceDates.length}回にしてもいいですか?",
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
                                    generated.scheduledClassNum = this.widget.subject.absenceDates.length;
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
                      subjectList[widget.index] = generated;
                      await SubjectPreferenceUtil.saveSubjectList(subjectList);
                      Navigator.pop(context);
                    } else {
                      SubjectPreferenceUtil.addSubject(generated);
                      Navigator.pop(context);
                    }

                  }
                ),
                Divider(),
                Text("「ん？計算結果がおかしいぞ?」と思ったら設定がおかしくなっている可能性があります。"
                     "下のボタンから設定を見直そうね"),
                RaisedButton(
                  child: Text("設定を変更する"),
                  onPressed: () {
                    Navigator.of(context).push(
                      new MaterialPageRoute(
                          builder: (BuildContext context) => new ConfigRootView()
                      )
                    ).then(
                      (_) async {
                        String numCalcedStr = "";
                        if (numberTextController.text.trim() == ""){
                          setState(() {
                          });
                        }
                        else if(int.tryParse(numberTextController.text) == null){
                          numCalcedStr = "授業数、数字ではない";
                          setState(() {calcErrOccurred = Colors.red;});
                        } else {
                          int calculated = await Subject.calcClassesFromWeek(int.parse(numberTextController.text));
                          numCalcedStr = calculated.toString();
                          setState(() {calcErrOccurred = Colors.black;});
                        }
                        calcedTextController.text = numCalcedStr;
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}