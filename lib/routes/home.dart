import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/contollers/refresh_controller.dart';
import 'package:unofficial_mashov/data_list.dart';
import 'package:unofficial_mashov/inject.dart';

class HomeRoute extends StatefulWidget {
  @override
  HomeRouteState createState() {
    return new HomeRouteState();
  }
}

class HomeRouteState extends State<HomeRoute> implements Callback {
  Widget gradesList;
  Widget homeworkList;
  Widget todayList;

  @override
  void initState() {
    super.initState();
    List<Api> needToRefresh = [];
    List<Grade> grades = Inject.databaseController.grades ?? List();
    List<Homework> homework = Inject.databaseController.homework ?? List();
    List<Lesson> timetable = Inject.databaseController.timetable ?? List();
    if (grades.isEmpty) {
      needToRefresh.add(Api.Grades);
    }
    if (homework.isEmpty) {
      needToRefresh.add(Api.Homework);
    }
    if (timetable.isEmpty) {
      needToRefresh.add(Api.Timetable);
    }

    gradesList = DataList<Grade>(
        initialData: grades,
        builder: (BuildContext context, Grade grade) =>
            ListTile(title: Text(grade.event), subtitle: Text(grade.subject)),
        api: Api.Grades);

    homeworkList = DataList<Homework>(
        initialData: homework,
        builder: (BuildContext context, Homework homework) =>
            ListTile(
              title: Text(homework.message),
              subtitle: Text(homework.subject),
              isThreeLine: true,
            ),
        api: Api.Homework);

    int today = DateTime
        .now()
        .weekday;
    print("today is $today. timetable length before sorting is ${timetable
        .length}");
    timetable.retainWhere((lesson) => lesson.day == today);
    timetable.sort((lesson1, lesson2) => lesson2.hour - lesson1.hour);
    print("timetable length after sorting is ${timetable.length}");

    todayList = DataList<Lesson>(
        initialData: timetable,
        builder: (BuildContext context, Lesson lesson) =>
            ListTile(
                title: Text(lesson.hour.toString() + ": " + lesson.subject),
                subtitle: Text(lesson.teacher),
                isThreeLine: true),
        api: Api.Timetable);

    if (needToRefresh.isNotEmpty) {
      Inject.refreshController.refreshAll(needToRefresh);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body =
    Inject.rtl(
        Container(margin: EdgeInsets.all(24),
            child: ListView(
              children: <Widget>[
//                    Text("ציונים אחרונים:"),
//                    Container(child: gradesList, height: 300),
//                    Spacer(),
//                    Text("שיעורי בית:"),
//                    Container(child: homeworkList,height: 300),
//                    Spacer(),
                Text("מערכת שעות יומית"),
                Container(child: todayList, height: 300)
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

  @override
  onFail(Api api) {
    switch (api) {
      case Api.Homework:
      case Api.Timetable:
      case Api.Grades:
        setState(() {
          //update list views
        });
        break;
      default:
        break;
    }
  }

  @override
  onLogin() {
    // TODO: implement onLogin
    return null;
  }

  @override
  onLoginFail() {
    // TODO: implement onLoginFail
    return null;
  }

  @override
  onSuccess(Api api) {
    // TODO: implement onSuccess
    return null;
  }

  @override
  onSuspend() {
    // TODO: implement onSuspend
    return null;
  }

  @override
  onUnauthorized() {
    // TODO: implement onUnauthorized
    return null;
  }
}
