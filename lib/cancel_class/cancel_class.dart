import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pucis/cancel_class/cancel_class_card.dart';
import 'package:pucis/custom_types/config.dart';
import 'package:pucis/custom_types/subject.dart';
import 'package:pucis/data_manager/subject_pref_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CancelManagerRoot extends StatefulWidget {
  @override
  _CancelManagerRootState createState() => _CancelManagerRootState();
}

class _CancelManagerRootState extends State<CancelManagerRoot> {
  Config config;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("休講管理"),
      ),
      body: Container(
          child: FutureBuilder(
        future: loadList(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return snapshot.data;
          }
          if (snapshot.hasError) {
            return snapshot.error;
          }
          return Container(
            child: CircularProgressIndicator(),
          );
        },
      )),
    );
  }

  Future loadList() async {
    List<Subject> subjects =
        await SubjectPreferenceUtil.getSubjectListFromPref();
    if (config == null) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String rawConfig = pref.getString("config");
      var jsonConfig = jsonDecode(rawConfig);
      config = Config.fromJson(jsonConfig);
    }
    Size size = MediaQuery.of(context).size;
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        Subject subject = subjects[index];
        return CancelClassCard(
            config: config,
            size: size,
            subject: subject,
            onAddCancelClass: (DateTime toAdd) async {
              List<Subject> subjects =
                  await SubjectPreferenceUtil.getSubjectListFromPref();
              subjects[index].cancelClasses.add(toAdd);
              await SubjectPreferenceUtil.saveSubjectList(subjects);
              setState(() {});
            },
            onRemoveCancelClass: (int indexToRemove) async {
              List<Subject> subjects =
                  await SubjectPreferenceUtil.getSubjectListFromPref();
              subjects[index].cancelClasses.removeAt(indexToRemove);
              await SubjectPreferenceUtil.saveSubjectList(subjects);
              setState(() {});
            });
      },
      itemCount: subjects.length,
    );
  }
}
