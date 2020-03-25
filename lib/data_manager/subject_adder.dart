import 'package:flutter/material.dart';
import 'package:pucis/config/config.dart';
import 'package:pucis/data_manager/subject_pref_util.dart';

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

class _SubjectAdderState extends State<SubjectAdder> {
  final nameTextController = new TextEditingController();
  final numberTextController = new TextEditingController();
  final calcedTextController = new TextEditingController();
  final redTextController = new TextEditingController();
  final greenTextController = new TextEditingController();
  final blueTextController = new TextEditingController();

  Color calcErrOccurred = Colors.black;

  _SubjectAdderState(Subject subject) {
    if (subject != null) {
      nameTextController.text = subject.name;
      // TODO: numberTextController、どうにかしたほうがいいかも?? (強い必要性はないとは思ふ)
      calcedTextController.text = subject.scheduledClassNum.toString();
    }
  }
  @override
  void initState() {
    super.initState();
    redTextController.text = "255";
    greenTextController.text = "255";
    blueTextController.text = "255";
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Color nowColor;
    if (int.tryParse(calcedTextController.text) != null &&
        int.tryParse(redTextController.text) != null &&
        int.tryParse(greenTextController.text) != null &&
        int.tryParse(blueTextController.text) !=
            null) if (int.tryParse(redTextController.text) >= 0 &&
        int.tryParse(redTextController.text) <= 255 &&
        int.tryParse(greenTextController.text) >= 0 &&
        int.tryParse(greenTextController.text) <= 255 &&
        int.tryParse(blueTextController.text) >= 0 &&
        int.tryParse(blueTextController.text) <= 255) {
      int red = int.parse(redTextController.text);
      int green = int.parse(greenTextController.text);
      int blue = int.parse(blueTextController.text);
      String rHash = red.toRadixString(16);
      String gHash = green.toRadixString(16);
      String bHash = blue.toRadixString(16);
      if (red < 10) {
        rHash = "0$rHash";
      }
      if (green < 10) {
        gHash = "0$gHash";
      }
      if (blue < 10) {
        bHash = "0$bHash";
      }

      String colorCode = "0xff$rHash$gHash$bHash";
      nowColor = Color(int.parse(colorCode));
    } else {
      String colorCode = "0xffffffff";
      nowColor = Color(int.parse(colorCode));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("教科を追加する"),
      ),
      body: Container(
        margin: EdgeInsets.all(size.width * 0.05),
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
                      hintText: "欠課した教科の名前を入力してください"),
                  controller: nameTextController,
                ),
                Container(margin: EdgeInsets.all(10)),
                TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(fontSize: 18),
                      labelText: "週あたりの時間数",
                      hintText: "1週間に授業が何回あるか教えてください"),
                  controller: numberTextController,
                  onChanged: (chg) async {
                    String numCalcedStr = "";
                    if (numberTextController.text.trim() == "") {
                      setState(() {});
                    } else if (int.tryParse(chg) == null) {
                      numCalcedStr = "授業数、数字ではない";
                      setState(() {
                        calcErrOccurred = Colors.red;
                      });
                    } else {
                      int calculated =
                          await Subject.calcClassesFromWeek(int.parse(chg));
                      numCalcedStr = calculated.toString();
                      setState(() {
                        calcErrOccurred = Colors.black;
                      });
                    }
                    calcedTextController.text = numCalcedStr;
                  },
                  keyboardType: TextInputType.number,
                ),
                Container(margin: EdgeInsets.all(10)),
                TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(fontSize: 18),
                      labelText: "自動計算された時間数(間違ってたら訂正してください)",
                      hintText: "↑を入力すると自動計算します  天才ですまん"),
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
                Container(margin: EdgeInsets.all(10)),
                Text("色設定"),
                Row(
                  children: <Widget>[
                    Container(
                      child: TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(fontSize: 18),
                            labelText: "赤",
                            hintText: "0~255までで入力してください"),
                        keyboardType: TextInputType.number,
                        controller: redTextController,
                      ),
                      width: size.width * 0.3,
                    ),
                    Container(
                      child: TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(fontSize: 18),
                            labelText: "緑",
                            hintText: "0~255までで入力してください"),
                        keyboardType: TextInputType.number,
                        controller: greenTextController,
                      ),
                      width: size.width * 0.3,
                    ),
                    Container(
                      child: TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(fontSize: 18),
                            labelText: "青",
                            hintText: "0~255までで入力してください"),
                        keyboardType: TextInputType.number,
                        controller: blueTextController,
                      ),
                      width: size.width * 0.3,
                    ),
                  ],
                ),
                Container(margin: EdgeInsets.all(20)),
                Row(children: <Widget>[
                  Text("色のサンプル"),
                  Container(
                      width: size.width * 0.1,
                      height: size.width * 0.1,
                      decoration: BoxDecoration(
                          color: nowColor, shape: BoxShape.circle)),
                  RaisedButton(
                      child: Text("確認する"),
                      onPressed: () {
                        setState(() {});
                      })
                ]),
                RaisedButton(
                    child: Text("追加する"),
                    shape: UnderlineInputBorder(),
                    // ignore: missing_return
                    onPressed: () async {
                      if (nameTextController.text.trim() == "" ||
                          calcedTextController.text.trim() == "" ||
                          redTextController.text.trim() == "" ||
                          greenTextController.text.trim() == "" ||
                          blueTextController.text.trim() == "") {
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
                            });
                      }
                      if (int.tryParse(calcedTextController.text) == null ||
                          int.tryParse(redTextController.text) == null ||
                          int.tryParse(greenTextController.text) == null ||
                          int.tryParse(blueTextController.text) == null) {
                        return showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: Text("私にはその授業数または色コードが読めません！"),
                                content: Text("一般的に数字として定義されている文字を使用してください"),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text("は、ミスっただけだが"),
                                    onPressed: () => Navigator.pop(context),
                                  )
                                ],
                              );
                            });
                      }
                      if (255 < int.parse(redTextController.text) ||
                          255 < int.parse(greenTextController.text) ||
                          255 < int.parse(blueTextController.text) ||
                          0 > int.parse(redTextController.text) ||
                          0 > int.parse(greenTextController.text) ||
                          0 > int.parse(blueTextController.text)) {
                        return showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("エラー"),
                                content: Text("おう!!!色コードを0~255にしろって言ったよな?"
                                    "なんでそんな値入力してんだカス!†悔い改めて†"),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text("おう!!!"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text("は、知るか"),
                                    onPressed: () {
                                      redTextController.text =
                                          "034043t4380435024";
                                      greenTextController.text =
                                          "342342480r2r02939r";
                                      blueTextController.text =
                                          "3925248063503606540";
                                      Navigator.pop(context);
                                    },
                                  )
                                ],
                              );
                            });
                      }
                      int red = int.parse(redTextController.text);
                      int green = int.parse(greenTextController.text);
                      int blue = int.parse(blueTextController.text);
                      String rHash = red.toRadixString(16);
                      String gHash = green.toRadixString(16);
                      String bHash = blue.toRadixString(16);
                      if (red < 10) {
                        rHash = "0$rHash";
                      }
                      if (green < 10) {
                        gHash = "0$gHash";
                      }
                      if (blue < 10) {
                        bHash = "0$bHash";
                      }

                      String colorCode = "0xff$rHash$gHash$bHash";

                      Subject generated = new Subject(
                          name: nameTextController.text,
                          absenceDates: (widget.index >= 0
                              ? widget.subject.absenceDates
                              : []),
                          scheduledClassNum:
                              int.parse(calcedTextController.text),
                          color: Color(int.parse(colorCode)));

                      if (widget.index >= 0) {
                        bool continues = false;
                        // 欠課数が新しい授業数を超えてる(そんなことあってたまるか!)
                        if (this.widget.subject.absenceDates.length >
                            int.parse(calcedTextController.text)) {
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) {
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
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    FlatButton(
                                      child: Text("いいっすよ"),
                                      onPressed: () {
                                        generated.scheduledClassNum = this
                                            .widget
                                            .subject
                                            .absenceDates
                                            .length;
                                        continues = true;
                                        Navigator.pop(context);
                                      },
                                    )
                                  ],
                                );
                              });

                          if (!continues) return;
                        }

                        List<Subject> subjectList = await SubjectPreferenceUtil
                            .getSubjectListFromPref();
                        subjectList[widget.index] = generated;
                        await SubjectPreferenceUtil.saveSubjectList(
                            subjectList);
                        Navigator.pop(context);
                      } else {
                        SubjectPreferenceUtil.addSubject(generated);
                        Navigator.pop(context);
                      }
                    }),
                Divider(),
                Text("「ん？計算結果がおかしいぞ?」と思ったら設定がおかしくなっている可能性があります。"
                    "下のボタンから設定を見直そうね"),
                RaisedButton(
                  child: Text("設定を変更する"),
                  onPressed: () {
                    Navigator.of(context)
                        .push(new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new ConfigRootView()))
                        .then(
                      (_) async {
                        String numCalcedStr = "";
                        if (numberTextController.text.trim() == "") {
                          setState(() {});
                        } else if (int.tryParse(numberTextController.text) ==
                            null) {
                          numCalcedStr = "授業数、数字ではない";
                          setState(() {
                            calcErrOccurred = Colors.red;
                          });
                        } else {
                          int calculated = await Subject.calcClassesFromWeek(
                              int.parse(numberTextController.text));
                          numCalcedStr = calculated.toString();
                          setState(() {
                            calcErrOccurred = Colors.black;
                          });
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
