import 'package:flutter/material.dart';
import 'package:gakkouike/subject_pref_util.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gakkouike/subject.dart';

class CalendarExample extends StatefulWidget{
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<CalendarExample>{
  CalendarController _calendarController;

  @override
  Widget build(BuildContext context) {// TODO: implement build
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FutureBuilder(
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
      ),
    );
  }

  Future setAbsence() async{
    List<Subject> subjects = await SubjectPreferenceUtil.getSubjectListFromPref();
    Map<DateTime, List<String>> map = Map();
    for (Subject subject in subjects){
      for (DateTime dateTime in subject.absenceDates.dateTimeList){
        if (map[dateTime] is List<String>) map[dateTime].add(subject.name);
        else map[dateTime] = <String>[subject.name];
      }
    }
    return TableCalendar(
      calendarController: _calendarController,
      events: map,
      onDaySelected: (dateTime, list){
        if (list.length == 0){
          list.add("ありません");
        }
        showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              title: Text("${dateTime.year.toString()}/"
                  "${dateTime.month.toString()}/"
                  "${dateTime.day.toString()}の欠課"),
              content: ListView.builder(
                itemCount: list.length,
                itemBuilder: (BuildContext context, int index){
                  return Text(list[index]);
                },
              ),
            );
          }
        );
      },
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