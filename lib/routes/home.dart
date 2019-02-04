import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/contollers/refresh_controller.dart';
import 'package:unofficial_mashov/inject.dart';

class HomeRoute extends StatefulWidget {
  @override
  HomeRouteState createState() {
    return new HomeRouteState();
  }
}

class HomeRouteState extends State<HomeRoute> {
  ListView gradesList;
  ListView homeworkList;
  ListView todayList;
  Callback _callback = Callback

  @override
  void initState() {
    super.initState();
    List<Api> needToRefresh = [];
    List<Grade> grades = Inject.databaseController.grades;
    List<Homework> homework = Inject.databaseController.homework;
    List<Lesson> timetable = Inject.databaseController.timetable;
    if (grades.isEmpty) {
      needToRefresh.add(Api.Grades);
    } else {
      gradesList = ListView.builder(
          itemCount: grades.length,
          itemBuilder: (BuildContext context, int index) =>
              ListTile(
                  title: Text(grades[index].event),
                  subtitle: Text(grades[index].subject)));
    }
    if (homework.isEmpty) {
      needToRefresh.add(Api.Homework);
    } else {
      homeworkList = ListView.builder(
          itemCount: homework.length,
          itemBuilder: (BuildContext context, int index) =>
              ListTile(
                title: Text(homework[index].message),
                subtitle: Text(homework[index].subject),
                isThreeLine: true,
              )
      );
    }
    if (timetable.isEmpty) {
      needToRefresh.add(Api.Timetable);
    } else {
      int today = DateTime
          .now()
          .weekday;
      timetable.retainWhere((lesson) => lesson.day == today);
      timetable.sort((lesson1, lesson2) => lesson2.hour - lesson1.hour);
      todayList = ListView.builder(itemCount: timetable.length,
          itemBuilder: (BuildContext context, int index) =>
              ListTile(
                  title: Text(timetable[index].hour.toString() + ": " +
                      timetable[index].subject),
                  subtitle: Text(timetable[index].teacher),
                  isThreeLine: true
              ));
    }
    if (needToRefresh.isNotEmpty) {
      Inject.refreshController.refreshAll(needToRefresh);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body =
    Inject.rtl(Container(margin: EdgeInsets.all(16), child: Text("היי")));
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
