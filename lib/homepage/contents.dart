import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pucis/homepage/cards_contents.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/inital_config.dart';
import '../custom_types/config.dart';
import '../custom_types/subject.dart';
import '../data_manager/subject_adder.dart';
import '../data_manager/subject_pref_util.dart';
import '../data_manager/subject_pref_util.dart';

class HomePageContents extends StatefulWidget {
  @override
  _HomePageContentsState createState() => _HomePageContentsState();
}

class _HomePageContentsState extends State<HomePageContents> {
  bool setting = false;
  Config config;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return snapshot.data;
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return Container(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Future loadData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String rawConfig = pref.getString("config");

    if (rawConfig == null) {
      if (setting) return Container();
      setting = true;
      Navigator.of(context)
          .push(new MaterialPageRoute(
              builder: (BuildContext context) => InitialConfigPage()))
          .then<void>((_) {
        setting = false;
      });
      return Container(
        child: CircularProgressIndicator(),
      );
    } else {
      var jsonConfig = jsonDecode(rawConfig);
      config = Config.fromJson(jsonConfig);
    }
    List<Subject> subjects =
        await SubjectPreferenceUtil.getSubjectListFromPref();
    if (subjects.length == 0) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("俺を\n活用しろ\nカス",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 50,
                height: 1.2,
              )),
          Text("とりあえず右下のボタンからなんか登録しません?", textAlign: TextAlign.center)
        ],
      ));
    }
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return CardsContents(
            subject: subjects[index],
            config: config,
            onTap: () {
              Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) =>
                      SubjectAdder(subject: subjects[index], index: index)));
            },
            onAddAbsence: (DateTime time) async {
              subjects[index].absenceDates.add(time);
              await SubjectPreferenceUtil.saveSubjectList(subjects);
              setState(() {});
            },
            onDeleteAbsence: (int index) async {
              subjects[index].absenceDates.removeAt(index);
              await SubjectPreferenceUtil.saveSubjectList(subjects);
              setState(() {});
            });
      },
      itemCount: subjects.length,
    );
  }
}
