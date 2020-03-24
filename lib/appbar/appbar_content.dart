import 'package:flutter/material.dart';

import 'package:pucis/data_manager/subject_pref_util.dart';

import '../custom_types/subject.dart';

class AppBarContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return IconButton(
      icon: Icon(Icons.remove),
      onPressed: () async {
        List<Subject> subjects =
            await SubjectPreferenceUtil.getSubjectListFromPref();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: Text("削除する教科を選択"),
                  content: Container(
                    width: size.width * 0.8,
                    height: size.height * 0.2,
                    child: ListView.builder(
                        itemCount: subjects.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            child: Column(children: [
                              Row(
                                children: <Widget>[
                                  Card(
                                      child: Padding(
                                          child: SizedBox(
                                              child: Text(
                                                subjects[index].name,
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              height: size.height * 0.05,
                                              width: size.width * 0.62),
                                          padding: EdgeInsets.only(
                                              top: 5, bottom: 5)),
                                      color: subjects[index].color),
                                ],
                              ),
                              index + 1 == subjects.length
                                  ? Container()
                                  : Divider()
                            ]),
                            onTap: () {
                              showDialog<bool>(
                                  context: context,
                                  builder: (_) {
                                    return AlertDialog(
                                      title: Text("本当に削除してもいいですか?"),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text("No"),
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                        ),
                                        FlatButton(
                                          child: Text("Yes"),
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                        )
                                      ],
                                    );
                                  }).then((v) {
                                if (v)
                                  SubjectPreferenceUtil.deleteSubjectAt(index);
                                Navigator.pop(context);
                              });
                            },
                          );
                        }),
                  ));
            });
      },
    );
  }
}
