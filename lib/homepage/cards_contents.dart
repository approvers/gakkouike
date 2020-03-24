import 'package:flutter/material.dart';

import '../custom_types/config.dart';
import '../custom_types/subject.dart';

class CardsContents extends StatelessWidget {
  CardsContents(
      {@required this.subject,
      @required this.config,
      @required this.onTap,
      @required this.onAddAbsence,
      @required this.onDeleteAbsence});
  final Subject subject;
  final Config config;
  final VoidCallback onTap;
  final void Function(DateTime) onAddAbsence;
  final void Function(int) onDeleteAbsence;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Color c;
    bool likeBlack = false;

    if (subject.absenceDates.length /
            (subject.scheduledClassNum - subject.cancelClasses.length) >=
        config.alertLine) {
      if (subject.absenceDates.length /
              (subject.scheduledClassNum - subject.cancelClasses.length) >=
          config.redLine)
        c = Color.fromARGB(255, 0xff, 0x33, 0x33);
      else
        c = Colors.orangeAccent;
    } else
      c = subject.color;
    if (c.red < 155 && c.blue < 155 && c.green < 155) likeBlack = true;

    return Center(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: size.height * 0.2,
            width: size.width,
            child: InkWell(
              onTap: this.onTap,
              child: Card(
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: size.width * 0.02,
                    ),
                    SubjectStats(
                        size: size, widget: this, likeBlack: likeBlack),
                    AddAbsenceButton(widget: this, size: size),
                    RemoveAbsenceButton(widget: this, size: size)
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

class AddAbsenceButton extends StatelessWidget {
  const AddAbsenceButton({
    this.widget,
    this.size,
  });

  final CardsContents widget;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: IconButton(
          icon: Icon(Icons.add, size: 25),
          onPressed: () async {
            final DateTime n = DateTime.now();
            if (widget.config.smartSet) {
              final DateTime normalized = DateTime(n.year, n.month, n.day);
              widget.onAddAbsence(normalized);
            } else {
              final DateTime cache = await showDatePicker(
                context: context,
                initialDate: widget.config.startClass.isAfter(n)
                    ? widget.config.startClass
                    : widget.config.endClass.isBefore(n)
                        ? widget.config.endClass
                        : n,
                firstDate: widget.config.startClass,
                lastDate: widget.config.endClass,
              );
              if (cache != null) {
                if (cache.isAfter(widget.config.startClass) &&
                    cache.isBefore(widget.config.endClass)) {
                  final DateTime normalized =
                      DateTime(cache.year, cache.month, cache.day);
                  widget.onAddAbsence(normalized);
                } else
                  showWrongDateDialog(context);
              }
            }
          },
        ),
        color: Colors.greenAccent,
      ),
      width: size.width * 0.17,
      height: size.width * 0.17,
    );
  }

  void showWrongDateDialog(BuildContext context) {
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

class RemoveAbsenceButton extends StatelessWidget {
  const RemoveAbsenceButton({
    this.widget,
    this.size,
  });

  final CardsContents widget;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: IconButton(
          icon: Icon(
            Icons.remove,
            size: 25,
          ),
          onPressed: () async {
            if (widget.subject.absenceDates.length == 0) {
              showNoAbsenceDialog(context);
            } else if (widget.config.smartDelete) {
              widget.onDeleteAbsence(widget.subject.absenceDates.length - 1);
            } else {
              await showDeleteDialog(context, size);
            }
          },
        ),
        color: Colors.redAccent,
      ),
      width: size.width * 0.17,
      height: size.width * 0.17,
    );
  }

  void showNoAbsenceDialog(BuildContext context) {
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
                  },
                )
              ]);
        });
  }

  void showDeleteDialog(BuildContext context, Size size) {
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
                      itemCount: widget.subject.absenceDates.length,
                      itemBuilder: (BuildContext context, int i) {
                        return GestureDetector(
                          child: ListTile(
                            title:
                                Text("${widget.subject.absenceDates[i].year}/"
                                    "${widget.subject.absenceDates[i].month}/"
                                    "${widget.subject.absenceDates[i].day}"),
                          ),
                          onTap: () {
                            widget.onDeleteAbsence(i);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  )));
        });
  }
}

class SubjectStats extends StatelessWidget {
  const SubjectStats({
    this.size,
    this.widget,
    this.likeBlack,
  });

  final Size size;
  final CardsContents widget;
  final bool likeBlack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(children: [
        SizedBox(
          height: size.height * 0.02,
        ),
        SizedBox(
          child: Text(
            widget.subject.name,
            style: TextStyle(
                fontSize: 28, color: likeBlack ? Colors.white : Colors.black),
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
                        color: likeBlack ? Colors.white : Colors.black)),
                SizedBox(
                  width: 10,
                ),
                Text("欠課時数 : ${widget.subject.absenceDates.length}",
                    style: TextStyle(
                        color: likeBlack ? Colors.white : Colors.black))
              ],
            ),
            width: size.width * 0.57,
            height: size.height * 0.04,
          )
        ]),
        Row(children: [
          Container(
              child: ListView(scrollDirection: Axis.horizontal, children: [
                Text("休講数: ${widget.subject.cancelClasses.length}",
                    style: TextStyle(
                        color: likeBlack ? Colors.white : Colors.black)),
                SizedBox(width: 10),
                Text(
                    "残り欠課数: ${(widget.subject.scheduledClassNum * widget.config.redLine - widget.subject.absenceDates.length).toInt()}",
                    style: TextStyle(
                        color: likeBlack ? Colors.white : Colors.black))
              ]),
              width: size.width * 0.57,
              height: size.height * 0.04)
        ])
      ]),
      width: size.width * 0.57,
    );
  }
}
