class DateTimeListJsonHelper {

  List<DateTime> dateTimeList;

  DateTimeListJsonHelper({this.dateTimeList}){
    this.dateTimeList ??= [];
  }

  List<Map<String, int>> splitListToYMD(){
    List<Map<String, int>> return_val = [];

    for(DateTime dateTime in this.dateTimeList){
      Map<String, int> map = {
        "year": dateTime.year,
        "month": dateTime.month,
        "day": dateTime.day
      };
      return_val.add(map);
    }

    return return_val;

  }

  static DateTimeListJsonHelper castFromJson(json) {
    DateTimeListJsonHelper return_val = new DateTimeListJsonHelper();

    // JSONからもらったデータがnullなら、新しいものを渡す
    if(json == null){
      return return_val;
    }
    for(var elem in json){
      DateTime convertedDt = new DateTime(
        elem["year"], elem["month"], elem["day"]
      );
      return_val.dateTimeList.add(convertedDt);
    }

    return return_val;

  }

}