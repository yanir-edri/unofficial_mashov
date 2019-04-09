import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/contollers/bloc.dart';
import 'package:unofficial_mashov/ui/data_list.dart';
import 'package:unofficial_mashov/inject.dart';

class HomeRoute extends StatefulWidget {
  @override
  HomeRouteState createState() {
    return new HomeRouteState();
  }
}

class HomeRouteState extends State<HomeRoute> {
  Widget gradesList;
  Widget homeworkList;
  Widget todayList;

  @override
  void initState() {
    super.initState();
    setup();
  }

  setup() {
    todayList = DataList<Lesson>(
        isDemo: true,
        builder: (BuildContext context, dynamic l) {
          Lesson lesson = l;
          return ListTile(
            title: Text(lesson.hour.toString() + ": " + lesson.subject),
            subtitle: Text(lesson.teachers.join(", ")),
            /*isThreeLine: false*/);
        },
        api: Api.Timetable);

    homeworkList = DataList<Homework>(
        isDemo: true,
        builder: (BuildContext context, dynamic h) {
          Homework homework = h;
          return ListTile(
            title: Text(homework.message),
            subtitle: Text(homework.subject),
            /*isThreeLine: true,*/
          );
        },
        api: Api.Homework);
    gradesList = DataList<Grade>(
        isDemo: true,
        builder: (BuildContext context, dynamic g) {
          Grade grade = g;
          return ListTile(
              title: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(grade.event.length > 30
                          ? "${grade.event.substring(0, 27).trimRight()}..."
                          : grade.event),
                      Spacer(),
                      Text("${grade.grade}")
                    ],
                  ),
                ],
              ),
              subtitle: Row(children: <Widget>[
                Text(grade.subject),
                Spacer(),
                Text("${Inject.dateTimeToDateString(grade.eventDate)}")
              ]));
        },
        api: Api.Grades);
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> key = GlobalKey();
    List<Widget> bodyContent = <Widget>[

      //Grades list:
      Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                right: Inject.margin, left: Inject.margin, top: Inject.margin),
            child: Text("ציונים אחרונים:",
                style: Theme
                    .of(context)
                    .textTheme
                    .title),
          ),
          Spacer(),
          FlatButton(
            child: Text("ראה עוד",
                style: Theme
                    .of(context)
                    .textTheme
                    .title
                    .copyWith(color: Theme
                    .of(context)
                    .accentColor)),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/grades");
            },
          )
        ],
      ),
      Container(
          margin: EdgeInsets.fromLTRB(
              Inject.margin, 0, Inject.margin, Inject.margin),
          child: Center(child: Card(elevation: 2.0, child: gradesList)),
          height: 300),


      //homework list:
      Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                right: Inject.margin, left: Inject.margin, top: Inject.margin),
            child: Text("ש\"ב:",
                style: Theme
                    .of(context)
                    .textTheme
                    .title),
          ),
          Spacer(),
          FlatButton(
            child: Text("ראה עוד",
                style: Theme
                    .of(context)
                    .textTheme
                    .title
                    .copyWith(color: Theme
                    .of(context)
                    .accentColor)),
            onPressed: () {
              workingOnIt(key);
            },
          )
        ],
      ),
      Container(
          margin: EdgeInsets.fromLTRB(
              Inject.margin, 0, Inject.margin, Inject.margin),
          child: Center(child: Card(elevation: 2.0, child: homeworkList)),
          height: 300),

      //Time table list:
      Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                right: Inject.margin, left: Inject.margin, top: Inject.margin),
            child: Text("מערכת שעות יומית:",
                style: Theme
                    .of(context)
                    .textTheme
                    .title),
          ),
          Spacer(),
          FlatButton(
            child: Text("כל המערכת",
                style: Theme
                    .of(context)
                    .textTheme
                    .title
                    .copyWith(color: Theme
                    .of(context)
                    .accentColor)),
            onPressed: () {
              workingOnIt(key);
            },
          )
        ],
      ),
      Container(
          margin: EdgeInsets.fromLTRB(
              Inject.margin, 0, Inject.margin, Inject.margin),
          child: Center(child: Card(elevation: 2.0, child: todayList)),
          height: 300),


    ];

    Widget content = Inject.rtl(ListView(
      children: bodyContent,
    ));
    Widget body = CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(expandedHeight: 200.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Column(children: <Widget>[
              Text("כותרת"),
              Spacer(),
              Row(children: <Widget>[
                Text("ממוצע:"), Spacer(), Text("שעות להיום:")
              ],),
              Spacer(),
              Row(children: <Widget>[
                FutureBuilder(future: bloc.db.getAverage(),
                    builder: (context, snap) =>
                    snap.hasData ? Text("${snap.data}") : Text("")),
                Spacer(),
                FutureBuilder(future: bloc.db.todayLessonsCount(),
                    builder: (context, snap) =>
                    snap.hasData ? Text("${snap.data}") : Text("")),
              ],)
            ],),
          ),),
        SliverFillRemaining(child: content)
      ],
    )
    Scaffold s = Scaffold(
      key: key,
      drawer: bloc.getDrawer(context),
      appBar: AppBar(
          title: Center(
              child: Column(children: [
                Text("משוב"),
                Row(children: [
                  GestureDetector(
                    child: Text("התנתק/י"),
                    onTap: () {
                      print("logging out");
                      bloc.logout(context);
                    },
                  ),
                  Spacer(),
                  Text("משהו אחר")
                ])
              ]))),
      body: content,
    );
    return Inject.rtl(s);
  }

  void workingOnIt(GlobalKey<ScaffoldState> key) {
    key.currentState.showSnackBar(SnackBar(
        content: Inject.rtl(Text("אני...אני עובד על זה! חכו לגרסה הבאה :)"))));
  }
}
