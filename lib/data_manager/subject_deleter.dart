import 'package:flutter/material.dart';

import 'subject_pref_util.dart';
import 'package:gakkouike/custom_types/subject.dart';

class SubjectDeleter extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title:Text("教科の削除")
      ),
      body:Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                "削除する教科を選択してください",
                style: TextStyle(fontSize:25)
              ),
            ]
          ),
          Divider(),
          Expanded(
            child: SubjectDeleterContent()
          )
        ]
      )
    );
  }
}

class SubjectDeleterContent extends StatefulWidget{
  @override
  _SubjectDeleterState createState() => _SubjectDeleterState();
}

class _SubjectDeleterState extends State<SubjectDeleterContent>{
  @override
  Widget build(BuildContext context){
    return FutureBuilder(
      future: loadData(context),
      builder:(BuildContext context, AsyncSnapshot snapshot){
        if (snapshot.hasData){
          return snapshot.data;
        } else if (snapshot.hasError){
          return Text("${snapshot.error}");
        }else{
          return Container(
            child: CircularProgressIndicator()
          );
        }
      }
    );
  }

  Future<Widget> loadData(BuildContext context)async{
    List<Subject> subjects = await SubjectPreferenceUtil.getSubjectListFromPref();
    Size size = MediaQuery.of(context).size;
    if (subjects.length == 0){
      return Center(
        child: Text(
          "何も無いのに消せるわけねえよなぁ?????????????????????????????????????????????????????????????",
          style: TextStyle(
            fontSize: 50
          )
        )
      );
    }
    return ListView.builder(
      itemCount: subjects.length,
      itemBuilder: (BuildContext context, int index){
        Subject subject = subjects[index];
        bool likeBlack = false;
        Color c = subject.color;
        if (c.red < 155 && c.blue < 155 && c.green < 155)
          likeBlack = true;

        return GestureDetector(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(5),
              child: SizedBox(
                width: size.width * 0.9,
                child: Text(
                  subject.name,
                  style: TextStyle(
                    fontSize:40,
                    color: likeBlack ? Colors.white : Colors.black
                  )
                )
              )
            ),
            color: subject.color
          ),
          onTap:(){
            showDialog<bool>(
              context: context,
              builder: (_){
                return AlertDialog(
                  title: Text("本当に削除してもいいですか?"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("No"),
                      onPressed: () => Navigator.of(context).pop(false)
                    ),
                    FlatButton(
                      child: Text("Yes"),
                      onPressed: () => Navigator.of(context).pop(true)
                    )
                  ]
                );
              }
            ).then((v){
                if (v) SubjectPreferenceUtil.deleteSubjectAt(index);
                setState((){});
              }
            );
          }
        );
      }
    );
  }
}
