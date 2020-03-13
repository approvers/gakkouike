import 'dart:convert';

import 'package:pucis/custom_types/subject.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SubjectのリストとSharedPreferencesの肩代わりをします
class SubjectPreferenceUtil{

  /// SharedPreferenceからSubjectのリストを持ってきます
  static Future<List<Subject>> getSubjectListFromPref() async{

    SharedPreferences pref = await SharedPreferences.getInstance();
    if(!pref.containsKey("subjectList")){
      pref.setString("subjectList", "");
      return [];
    }

    if(pref.getString("subjectList") == ""){
      return [];
    }
    List<dynamic> jsonList = json.decode(pref.getString("subjectList"));
    List<Subject> subjectList = [];

    for(Map<String, dynamic> json in jsonList){
      subjectList.add(Subject.fromJson(json));
    }
    return subjectList;
  }

  /// SharedPreferenceにsubjectList(と等価のJSON)を保存します
  static Future saveSubjectList(List<Subject> subjectList) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("subjectList", jsonEncode(subjectList));
  }

  /// SharedPreference上のsubjectListにSubjectを追加します
  static void addSubject(Subject subject) async{
    List<Subject> list = await getSubjectListFromPref();
    list.add(subject);
    saveSubjectList(list);
  }

  static Future<Subject> deleteSubjectAt(int index) async{
    List<Subject> subjectLists = await getSubjectListFromPref();
    Subject deletedSubject = subjectLists.removeAt(index);
    saveSubjectList(subjectLists);
    return deletedSubject;
  }

}