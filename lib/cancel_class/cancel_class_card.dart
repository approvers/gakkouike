import 'package:flutter/material.dart';

import 'package:pucis/custom_types/config.dart';
import 'package:pucis/custom_types/subject.dart';

class CancelClassCard extends StatelessWidget {
  CancelClassCard(
      {@required this.config,
      @required this.size,
      @required this.subject,
      @required this.onAddCancelClass,
      @required this.onRemoveCancelClass});

  final Config config;
  final Size size;
  final Subject subject;
  final Function(DateTime toAdd) onAddCancelClass;
  final Function(int indexToRemove) onRemoveCancelClass;

  @override
  Widget build(BuildContext context) {
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
                    width: size.width * 0.02,
                  ),
                  SizedBox(
                    child: Column(children: [
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      SizedBox(
                        child: Text(
                          subject.name,
                          style: TextStyle(
                            fontSize: 28,
                          ),
                        ),
                        width: size.width * 0.45,
                      ),
                      Divider(),
                      Row(children: [
                        Container(
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              Text("休講数 : ${subject.cancelClasses.length}"),
                            ],
                          ),
                          width: size.width * 0.57,
                          height: size.height * 0.04,
                        )
                      ])
                    ]),
                    width: size.width * 0.57,
                  ),
                  AddCancelClassButton(
                    config: config,
                    size: size,
                    onAddCancelClass: onAddCancelClass,
                  ),
                  RemoveCancelClassButton(
                    subject: subject,
                    size: size,
                    onRemoveCancelClass: onRemoveCancelClass,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddCancelClassButton extends StatelessWidget {
  const AddCancelClassButton(
      {@required this.config,
      @required this.size,
      @required this.onAddCancelClass});

  final Config config;
  final Size size;
  final Function(DateTime) onAddCancelClass;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: IconButton(
          icon: Icon(Icons.add, size: 25),
          onPressed: () async {
            final DateTime cache = await showDatePicker(
              context: context,
              initialDate: config.startClass.isAfter(DateTime.now())
                  ? config.startClass
                  : config.endClass.isBefore(DateTime.now())
                      ? config.endClass
                      : DateTime.now(),
              firstDate: config.startClass,
              lastDate: config.endClass,
            );
            if (cache != null) {
              if (cache.isAfter(config.startClass) &&
                  cache.isBefore(config.endClass)) {
                final DateTime normalized =
                    DateTime(cache.year, cache.month, cache.day);
                onAddCancelClass(normalized);
              } else
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("エラー"),
                        content: Text(
                          "休講になるのは始業日と終業日の間でなくてはいけません",
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
          },
        ),
        color: Colors.greenAccent,
      ),
      width: size.width * 0.17,
      height: size.width * 0.17,
    );
  }
}

class RemoveCancelClassButton extends StatelessWidget {
  const RemoveCancelClassButton({
    @required this.size,
    @required this.subject,
    @required this.onRemoveCancelClass,
  });

  final Size size;
  final Subject subject;
  final Function(int) onRemoveCancelClass;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: IconButton(
          icon: Icon(
            Icons.remove,
            size: 25,
          ),
          onPressed: () {
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
                              itemCount: subject.cancelClasses.length,
                              itemBuilder: (BuildContext context, int i) {
                                return GestureDetector(
                                  child: ListTile(
                                    title:
                                        Text("${subject.cancelClasses[i].year}/"
                                            "${subject.cancelClasses[i].month}/"
                                            "${subject.cancelClasses[i].day}"),
                                  ),
                                  onTap: () {
                                    onRemoveCancelClass(i);
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                          )));
                });
          },
        ),
        color: Colors.redAccent,
      ),
      width: size.width * 0.17,
      height: size.width * 0.17,
    );
  }
}
