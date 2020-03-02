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
      for (DateTime dateTime in subject.absenceDates){
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
            Size size = MediaQuery.of(context).size;
            return AlertDialog(
              title: Text("${dateTime.year.toString()}/"
                  "${dateTime.month.toString()}/"
                  "${dateTime.day.toString()}の欠課"),
              content: Container(
                width: size.width * 0.8,
                height: size.height * 0.4,
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int index){
                    return
                    Column(
                        children:[
                          Row(
                            children: <Widget>[
                              Text(list[index]),
                            ],
                          ),
                          index + 1 == list.length ? Container():
                              Divider()
                        ]
                    );
                  },
                )
              )
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