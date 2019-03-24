import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/data_list.dart';
import 'package:unofficial_mashov/inject.dart';

class HomeRoute extends StatefulWidget {
  @override
  HomeRouteState createState() {
    return new HomeRouteState();
  }
}

class HomeRouteState extends State<HomeRoute> {
  Widget gradesList;

//  Widget homeworkList;
//  Widget todayList;

  @override
  void initState() {
    super.initState();
    setup();
  }

  setup() {
//    int today = DateTime
//        .now()
//        .weekday;
//    print("today is $today. timetable length before sorting is ${timetable
//        .length}");
//    timetable.retainWhere((lesson) => lesson.day == today);
//    timetable.sort((lesson1, lesson2) => lesson2.hour - lesson1.hour);
//    print("timetable length after sorting is ${timetable.length}");
//    todayList = DataList<Lesson>(
//        initialData: List(),
//        builder: (BuildContext context, Lesson lesson) =>
//            ListTile(
//                title: Text(lesson.hour.toString() + ": " + lesson.subject),
//                subtitle: Text(lesson.teacher),
//                /*isThreeLine: false*/),
//        api: Api.Timetable);
//
//    homeworkList = DataList<Homework>(
//        initialData: List(),
//        builder: (BuildContext context, Homework homework) =>
//            ListTile(
//              title: Text(homework.message),
//              subtitle: Text(homework.subject),
//              /*isThreeLine: true,*/
//            ),
//        api: Api.Homework);

    gradesList = DataList<Grade>(
        builder: (BuildContext context, Grade grade) =>
            ListTile(title: Row(
              children: <Widget>[
                Text(grade.event.length > 30 ? "${grade.event.substring(
                    0, 27)}..." : grade.event),
                Spacer(),
                Text("${grade.grade}")
              ],
            ), subtitle: Text(grade.subject)),
        api: Api.Grades);
  }

  @override
  Widget build(BuildContext context) {
    Widget body =
    Inject.rtl(
        Container(margin: EdgeInsets.all(24),
            child: ListView(
              children: <Widget>[
                Row(children: <Widget>[
                  Text("ציונים אחרונים:"),
                  Spacer(),
                  RaisedButton(
                    child: Text("ראה עוד", style: Theme
                        .of(context)
                        .textTheme
                        .title
                        .
                    copyWith(color: Theme
                        .of(context)
                        .accentColor)),
                    onPressed: () {},

                  )
                ],),
                Container(child: gradesList, height: 300),
//                    Spacer(),
//                    Text("שיעורי בית:"),
//                    Container(child: homeworkList,height: 300),
//                    Spacer(),
//                Text("מערכת שעות יומית"),
//                Container(child: todayList, height: 300)
              ],
            )));
    return Scaffold(
      appBar: AppBar(
          title: Center(
              child: Column(children: [
                Text("משוב"),
                Row(children: [Text("משהו אחד"), Spacer(), Text("משהו אחר")])
              ]))),
      body: body,
    );
  }

}
