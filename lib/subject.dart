/// 教科ごとの欠課を管理するクラス。
class Subject {

  /// 教科の名前
  String name;
  /// 休んだ日
  List<DateTime> _absenceDates;
  /// 予定されている授業の数
  int _scheduledClassNum;

  Subject(this.name, this._absenceDates, this._scheduledClassNum);

  /// getter
  int get scheduledClassNum => _scheduledClassNum;
  List<DateTime> get absenceDates => _absenceDates;

}