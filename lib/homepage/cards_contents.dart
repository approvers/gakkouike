import 'package:flutter/material.dart';

import '../custom_types/config.dart';
import '../custom_types/subject.dart';
import '../data_manager/subject_adder.dart';
import '../data_manager/subject_pref_util.dart';

class CardsContents extends StatefulWidget {
  CardsContents({this.subject, this.config, this.index, this.parentWidget});
  Subject subject;
  Config config;
  int index;
  var parentWidget;
  @override
  _CardsContentsState createState() => _CardsContentsState();
}

class _CardsContentsState extends State<CardsContents> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Color c;
    bool likeBrack = false;

    if (widget.subject.absenceDates.length /
            (widget.subject.scheduledClassNum -
                widget.subject.cancelClasses.length) >=
        widget.config.alertLine) {
      if (widget.subject.absenceDates.length /
              (widget.subject.scheduledClassNum -
                  widget.subject.cancelClasses.length) >=
          widget.config.redLine)
        c = Color.fromARGB(255, 0xff, 0x33, 0x33);
      else
        c = Colors.orangeAccent;
    } else
      c = widget.subject.color;
    if (c.red < 155 && c.blue < 155 && c.green < 155) likeBrack = true;

    return Center(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: size.height * 0.2,
            width: size.width,
            child: InkWell(
              onTap: () async {
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => SubjectAdder(
                        subject: widget.subject, index: widget.index)));
              },
              child: Card(
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: size.width * 0.02,
                    ),
                    SizedBox(
                      child: Column(children: [
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        SizedBox(
                          child: Text(
                            widget.subject.name,
                            style: TextStyle(
                                fontSize: 28,
                                color: likeBrack ? Colors.white : Colors.black),
                          ),
                          width: size.width * 0.45,
                        ),
                        Divider(),
                        Row(children: [
                          Container(
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: <Widget>[
                                Text(
                                    "欠課率 : ${(widget.subject.absenceDates.length / (widget.subject.scheduledClassNum - widget.subject.cancelClasses.length) * 100).toStringAsFixed(1)}%",
                                    style: TextStyle(
                                        color: likeBrack
                                            ? Colors.white
                                            : Colors.black)),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                    "欠課時数 : ${widget.subject.absenceDates.length}",
                                    style: TextStyle(
                                        color: likeBrack
                                            ? Colors.white
                                            : Colors.black))
                              ],
                            ),
                            width: size.width * 0.57,
                            height: size.height * 0.04,
                          )
                        ]),
                        Row(children: [
                          Container(
                              child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    Text(
                                        "休講数: ${widget.subject.cancelClasses.length}",
                                        style: TextStyle(
                                            color: likeBrack
                                                ? Colors.white
                                                : Colors.black)),
                                    SizedBox(width: 10),
                                    Text(
                                        "残り欠課数: ${(widget.subject.scheduledClassNum * widget.config.redLine - widget.subject.absenceDates.length).toInt()}",
                                        style: TextStyle(
                                            color: likeBrack
                                                ? Colors.white
                                                : Colors.black))
                                  ]),
                              width: size.width * 0.57,
                              height: size.height * 0.04)
                        ])
                      ]),
                      width: size.width * 0.57,
                    ),
                    Container(
                      child: Card(
                        child: IconButton(
                          icon: Icon(Icons.add, size: 25),
                          onPressed: () async {
                            if (widget.config.smartSet) {
                              DateTime n = DateTime.now();
                              List<Subject> subjects =
                                  await SubjectPreferenceUtil
                                      .getSubjectListFromPref();
                              subjects[widget.index]
                                  .absenceDates
                                  .add(DateTime(n.year, n.month, n.day));
                              await SubjectPreferenceUtil.saveSubjectList(
                                  subjects);
                              widget.subject = subjects[widget.index];
                            } else {
                              final DateTime cache = await showDatePicker(
                                context: context,
                                initialDate: widget.config.startClass
                                        .isAfter(DateTime.now())
                                    ? widget.config.startClass
                                    : widget.config.endClass
                                            .isBefore(DateTime.now())
                                        ? widget.config.endClass
                                        : DateTime.now(),
                                firstDate: widget.config.startClass,
                                lastDate: widget.config.endClass,
                              );
                              if (cache != null) {
                                if (cache.isAfter(widget.config.startClass) &&
                                    cache.isBefore(widget.config.endClass)) {
                                  List<Subject> subjects =
                                      await SubjectPreferenceUtil
                                          .getSubjectListFromPref();
                                  subjects[widget.index].absenceDates.add(
                                      DateTime(
                                          cache.year, cache.month, cache.day));
                                  await SubjectPreferenceUtil.saveSubjectList(
                                      subjects);
                                  widget.subject = subjects[widget.index];
                                } else
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("エラー"),
                                          content: Text(
                                            "欠課するのは始業日と終業日の間でなくてはいけません",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text("yeah"),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            )
                                          ],
                                        );
                                      });
                              }
                            }
                            widget.parentWidget.setState(() {});
                          },
                        ),
                        color: Colors.greenAccent,
                      ),
                      width: size.width * 0.17,
                      height: size.width * 0.17,
                    ),
                    Container(
                      child: Card(
                        child: IconButton(
                          icon: Icon(
                            Icons.remove,
                            size: 25,
                          ),
                          onPressed: () async {
                            List<Subject> subjects = await SubjectPreferenceUtil
                                .getSubjectListFromPref();
                            if (subjects[widget.index].absenceDates.length ==
                                0) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                        title: Text("あなたは神なのでまだ欠課していません。"
                                            "堕落しないようにこれからも出席を続けましょう。"),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: Text("yeah"),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              widget.parentWidget
                                                  .setState(() {});
                                            },
                                          )
                                        ]);
                                  });
                            } else if (widget.config.smartDelete) {
                              subjects[widget.index].absenceDates.removeLast();
                              await SubjectPreferenceUtil.saveSubjectList(
                                  subjects);
                              widget.subject = subjects[widget.index];
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                        width: size.width * 0.8,
                                        height: size.height * 0.6,
                                        child: AlertDialog(
                                            title: Text("削除する"),
                                            content: Container(
                                              width: size.width * 0.8,
                                              height: size.height * 0.6,
                                              child: ListView.builder(
                                                itemCount: widget.subject
                                                    .absenceDates.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int i) {
                                                  return GestureDetector(
                                                    child: ListTile(
                                                      title: Text(
                                                          "${widget.subject.absenceDates[i].year}/"
                                                          "${widget.subject.absenceDates[i].month}/"
                                                          "${widget.subject.absenceDates[i].day}"),
                                                    ),
                                                    onTap: () async {
                                                      List<Subject> subjects =
                                                          await SubjectPreferenceUtil
                                                              .getSubjectListFromPref();
                                                      subjects[widget.index]
                                                          .absenceDates
                                                          .removeAt(i);
                                                      await SubjectPreferenceUtil
                                                          .saveSubjectList(
                                                              subjects);
                                                      widget.subject = subjects[
                                                          widget.index];
                                                      Navigator.pop(context);
                                                      widget.parentWidget
                                                          .setState(() {});
                                                    },
                                                  );
                                                },
                                              ),
                                            )));
                                  });
                            }
                            widget.parentWidget.setState(() {});
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
