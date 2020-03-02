
/// 教科ごとの欠課を管理するクラス。
class Subject {

  /// 教科の名前
  String name;
  /// 休んだ日
  List<DateTime> absenceDates;
  /// 予定されている授業の数
  int scheduledClassNum;

  List<DateTime> cancelClasses;

  Subject({this.name, this.absenceDates, this.scheduledClassNum, this.cancelClasses}){
    this.absenceDates ??= [];
    this.cancelClasses ??= [];
  }
  Subject.fromJson(Map<String, dynamic> json)
    : name              = json["name"],
      absenceDates      = json["absenceDates"].map((t) => DateTime.parse(t)).toList().cast<DateTime>(),
      scheduledClassNum = json["scheduledClassNum"],
      cancelClasses     = json["cancelClasses"].map((t) => DateTime.parse(t)).toList().cast<DateTime>();

  Map<String, dynamic> toJson() => {
    "name"              : name,
    "absenceDates"      : absenceDates.map((d) => d.toIso8601String()).toList(),
    "scheduledClassNum" : scheduledClassNum,
    "cancelClasses"     : cancelClasses.map((d) => d.toIso8601String()).toList()
  };
}