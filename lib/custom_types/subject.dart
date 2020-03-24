import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:pucis/custom_types/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 教科ごとの欠課を管理するクラス。
class Subject {
  /// 教科の名前
  String name;

  /// 休んだ日
  List<DateTime> absenceDates;

  /// 予定されている授業の数
  int scheduledClassNum;

  List<DateTime> cancelClasses;

  Color color;

  Subject(
      {this.name,
      this.absenceDates,
      this.scheduledClassNum,
      this.cancelClasses,
      this.color}) {
    this.absenceDates ??= [];
    this.cancelClasses ??= [];
  }
  Subject.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        absenceDates = json["absenceDates"]
            .map((t) => DateTime.parse(t))
            .toList()
            .cast<DateTime>(),
        scheduledClassNum = json["scheduledClassNum"],
        cancelClasses = json["cancelClasses"]
            .map((t) => DateTime.parse(t))
            .toList()
            .cast<DateTime>(),
        color = Color(json["color"]);

  Map<String, dynamic> toJson() => {
        "name": name,
        "absenceDates": absenceDates.map((d) => d.toIso8601String()).toList(),
        "scheduledClassNum": scheduledClassNum,
        "cancelClasses": cancelClasses.map((d) => d.toIso8601String()).toList(),
        "color": color.value
      };

  static calcClassesFromWeek(int classesPerWeek) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    Config config = Config.fromJson(jsonDecode(pref.getString("config")));

    int fullWeek = config.endClass.difference(config.startClass).inDays ~/ 7;
    int vcSubbed =
        fullWeek - config.summerVacationLength - config.winterVacationLength;

    return vcSubbed * classesPerWeek;
  }
}
