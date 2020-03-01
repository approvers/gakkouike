import 'package:flutter/material.dart';
import '../subject.dart';
import 'package:gakkouike/subject_pref_util.dart';

class CounterRootView extends StatefulWidget {
  CounterRootView(
      {
        this.subject,
        this.index,
        @required this.smartSet,
        @required this.smartDelete
      }
  );
  final Subject subject;
  final bool smartSet;
  final bool smartDelete;
  final int index;
  @override
  _CounterRootViewState createState() =>
      _CounterRootViewState(
    subject: subject,
    smartSet: smartSet,
    smartDelete: smartDelete,
    index: index
  );
}

class _CounterRootViewState extends State<CounterRootView>{
  _CounterRootViewState(
      {
        this.subject,
        this.index,
        this.smartSet,
        this.smartDelete
      }
  );

  Subject subject;
  final bool smartSet;
  final bool smartDelete;
  final int index;

  int a = 0;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    a++;
    return Center(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: size.height * 0.15,
            width: size.width,
            child: Card(
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: size.width*0.05,
                  ),
                  SizedBox(child:
                  Column(children:[
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    SizedBox(
                      child: Text(
                        subject.name,
                        style: TextStyle(fontSize: 28,),
                      ),
                      width: size.width * 0.45,
                    ),
                    Divider(),
                    Row(
                      children: [
                        Text("欠課率 : ${(subject.absenceDates.dateTimeList.length / subject.scheduledClassNum * 100).toStringAsFixed(1)}%"),
                        SizedBox(width: 10,),
                        Text("欠課時数 : ${subject.absenceDates.dateTimeList.length}")
                        ]
                    )
                  ]),
                  width: size.width * 0.45,
                  ),
                  SizedBox(
                    width: size.width * 0.15,
                  ),
                  Container(child:
                    Card(
                      child: IconButton(
                        icon: Icon(Icons.add, size: 25),
                        onPressed: () async{
                          print("Pressed");
                          if(smartSet){
                            DateTime n = DateTime.now();
                            List<Subject> subjects = await SubjectPreferenceUtil.getSubjectListFromPref();
                            print(index);
                            subjects[index].absenceDates.dateTimeList.add(DateTime(n.year, n.month, n.day));
                            await SubjectPreferenceUtil.saveSubjectList(subjects);
                            subject = subjects[index];
                          }
                          setState(() {

                          });
                        },
                      ),
                      color: Colors.greenAccent,
                    ),
                  )
                  ,
                  Container(child:
                    Card(
                      child: IconButton(
                        icon: Icon(Icons.remove, size: 25,),
                        onPressed: () async{
                          print("Pressed");
                          if(smartDelete){
                            List<Subject> subjects = await SubjectPreferenceUtil.getSubjectListFromPref();
                            subjects[index].absenceDates.dateTimeList.removeLast();
                            await SubjectPreferenceUtil.saveSubjectList(subjects);
                            subject = subjects[index];
                          }

                          setState(() {

                          });
                        },
                      ),
                      color: Colors.redAccent,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],

      ),
    )
      ;
  }
}