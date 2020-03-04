import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gakkouike/data_manager/subject_pref_util.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gakkouike/custom_types/subject.dart';

class CalendarExample extends StatefulWidget{
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<CalendarExample>{
  CalendarController _calendarController;
  List<Subject> subjects;
  List<dynamic> selectedSublist = [];
  DateTime selectedDay;

  @override
  Widget build(BuildContext context) {// TODO: implement build
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          FutureBuilder(
            future: setAbsence(),
            builder: (BuildContext context, AsyncSnapshot snapshot){
              if(snapshot.hasData){
                return snapshot.data;
              }else if(snapshot.hasError){
                return Center(
                  child: Text("${snapshot.error.toString()}"),
                );
              }else{
                return Container(
                  child: CircularProgressIndicator(),
                );
              }
            },
          )
        ]
      ),
    );
  }

  Future setAbsence() async{
    subjects = await SubjectPreferenceUtil.getSubjectListFromPref();
    Map<DateTime, List<Subject>> map = Map();
    for (Subject subject in subjects){
      for (DateTime dateTime in subject.absenceDates){
        if (map[dateTime] is List<Subject>) map[dateTime].add(subject);
        else map[dateTime] = <Subject>[subject];
      }
    }


    return Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              calendarController: _calendarController,
              events: map,
              onDaySelected: (dateTime, list){
                setState(() {
                  selectedDay = dateTime;
                  selectedSublist = list;
                  print(dateTime.toIso8601String());
                  print(list);
                });
              },
              builders: CalendarBuilders(
                markersBuilder: (BuildContext context, DateTime date, events, holidays){
                  final children = <Widget>[];
                  if (events.isNotEmpty){
                    children.add(
                      Positioned(
                        right: 1,
                        bottom: 1,
                        child: _buildEventMarker(date, events),
                      )
                    );
                  }
                  return children;
                }
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        (selectedDay != null ?
                          "${selectedDay.year}年${selectedDay.month}月${selectedDay
                          .day}日の欠課"
                        :
                          "日付選んでクレメンス"
                        ),
                        style: TextStyle(fontSize: 20)),
                    Divider(color: Colors.grey),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: selectedSublist.length,
                        itemBuilder: (BuildContext context, int index) {
                          return  Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(5)),
                              ),
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    gradient: LinearGradient(
                                      stops: [0.02, 0.02],
                                      colors: [
                                        selectedSublist[index].color,
                                        Colors.white
                                      ],
                                    ),
                                  ),
                                child: Text(selectedSublist[index].name),
                                padding: EdgeInsets.fromLTRB(8, 0, 0, 0)
                              ),
                          );
                        }
                      ),
                    ),
                  ]
                )
              ),
            )
          ]
        )
    );
  }

  Widget _buildEventMarker(DateTime date, events){
    // print(events);
    Color color = events[0].color;
    bool likeWhite = false;
    if (color.red > 150 && color.green > 150 && color.blue > 150) likeWhite = true;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: likeWhite ? Colors.black : Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
  }

  @override
  void dispose() {
    super.dispose();
    _calendarController.dispose();
  }
}