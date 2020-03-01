import 'package:flutter/material.dart';

class CounterRootView extends StatefulWidget {
  @override
  _CounterRootViewState createState() => _CounterRootViewState();
}

class _CounterRootViewState extends State<CounterRootView>{
  _CounterRootViewState(
      {
        this.subjectName = "subjectName",
        this.absencePer = 0.0,
        this.absenceCount = 0
      }
  );
  final String subjectName;
  final double absencePer;
  final int absenceCount;
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
                        subjectName,
                        style: TextStyle(fontSize: 28,),
                      ),
                      width: size.width * 0.45,
                    ),
                    Divider(),
                    Row(
                      children: [
                        Text("欠課率 : $absencePer%"),
                        SizedBox(width: 10,),
                        Text("欠課時数 : $absenceCount")
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
                        onPressed: (){
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
                        onPressed: (){
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