class DateTimeListJsonHelper {

  List<DateTime> dateTimeList;

  DateTimeListJsonHelper({this.dateTimeList}){
    this.dateTimeList ??= [];
  }

  List<Map<String, int>> splitListToYMD(){
    List<Map<String, int>> returnVal = [];

    for(DateTime dateTime in this.dateTimeList){
      Map<String, int> map = {
        "year": dateTime.year,
        "month": dateTime.month,
        "day": dateTime.day
      };
      returnVal.add(map);
    }

    return returnVal;

  }

  static DateTimeListJsonHelper castFromJson(json) {
    DateTimeListJsonHelper returnVal = new DateTimeListJsonHelper();

    // JSONからもらったデータがnullなら、新しいものを渡す
    if(json == null){
      return returnVal;
    }
    for(var elem in json){
      DateTime convertedDt = new DateTime(
        elem["year"], elem["month"], elem["day"]
      );
      returnVal.dateTimeList.add(convertedDt);
    }

    return returnVal;

  }

}