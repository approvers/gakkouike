// TODO: config型を定義しろ
import 'package:flutter/cupertino.dart';

class Config{

  /// +ボタンを押したタイミングで日付を登録
  bool smartSet;

  /// -ボタンを押したタイミングで最新の日付を削除
  bool smartDelete;

  /// 始業日
  DateTime startClass;

  /// 就業日
  DateTime endClass;

  /// 夏休みの長さ
  int summerVacationLength;

  /// 冬休みの長さ
  int winterVacationLength;

  /// 警告ライン
  double alertLine;

  /// 落単ライン
  double redLine;

  Config(
      {
        this.smartSet             = false,
        this.smartDelete          = false,
        this.summerVacationLength = 0,
        this.winterVacationLength = 0,
        this.alertLine            = 0.6,
        this.redLine              = 0.7,
        @required this.startClass,
        @required this.endClass,
      }
  );

  Config.fromJson(Map<String, dynamic> json)
    : smartSet             = json["smartSet"],
      smartDelete          = json["smartDelete"],
      summerVacationLength = json["summerVacationLength"],
      winterVacationLength = json["winterVacationLength"],
      alertLine            = json["alertLine"],
      redLine              = json["redLine"],
      startClass           = json["startClass"],
      endClass             = json["endClass"];

  Map<String, dynamic> toJson() => {
    "smartSet"             : smartSet,
    "smartDelete"          : smartDelete,
    "summerVacationLength" : summerVacationLength,
    "winterVacationLength" : winterVacationLength,
    "alertLine"            : alertLine,
    "redLine"              : redLine,
    "startClass"           : startClass,
    "endClass"             : endClass
  };
}