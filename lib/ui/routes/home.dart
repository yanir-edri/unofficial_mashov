import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/contollers/bloc.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/ui/data_list.dart';

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
  int _newMessagesCache = -1;

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
            /*isThreeLine: false*/
          );
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
              Navigator.pushNamed(context, "/grades");
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
            child: Text("ש\"ב:", style: Theme
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
    Scaffold test = Scaffold(
      drawer: bloc.getDrawer(context),
      key: key,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
            headerBuilderV2(context, innerBoxIsScrolled),
        body: content,
      ),
    );
    return Inject.rtl(test);
  }

  void workingOnIt(GlobalKey<ScaffoldState> key) {
    key.currentState.showSnackBar(SnackBar(
        content: Inject.rtl(Text("אני...אני עובד על זה! חכו לגרסה הבאה :)"))));
  }

  Column overviewItemBuilder({@required String title,
    @required Future<num> future,
    int precision: 1,
    TextStyle headerStyle:
    const TextStyle(color: Colors.white, fontSize: 20.0),
    TextStyle valueStyle:
    const TextStyle(color: Colors.white, fontSize: 32.0),
    isZeroGood: false}) =>
      Column(
        children: <Widget>[
          FutureBuilder<num>(
              future: future,
              builder: (context, snap) {
                print("overview($title): recieved data ${snap.data}");
                return snap.hasData &&
                    (isZeroGood || snap.data != 0)
                    ? Text(
                    "${snap.data.toDouble() == snap.data.roundToDouble() ? snap
                        .data.toInt() : snap.data.toStringAsFixed(precision)}",
                    style: valueStyle)
                    : Text("");
              }),
          Text(title, style: headerStyle)
        ],
      );

  List<Widget> headerBuilderV2(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        expandedHeight: 150.0,
        floating: false,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          background: Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: Row(
              children: <Widget>[
                Spacer(),
                overviewItemBuilder(
                    title: "ממוצע", future: bloc.db.getAverage()),
                Spacer(),
                overviewItemBuilder(
                    title: "שעות להיום", future: bloc.db.todayLessonsCount()),
                Spacer(),
                overviewItemBuilder(
                    title: "הודעות חדשות",
                    future: _newMessagesCache == -1
                        ? bloc.getNewMessagesCount().then((n) {
                      _newMessagesCache = n;
                      return n;
                    })
                        : Future.value(_newMessagesCache),
                    isZeroGood: true),
                Spacer()
              ],
            ),
          ),
        ),
      )
    ];
  }

  List<Widget> headerBuilder(BuildContext context, bool innerBoxIsScrolled) =>
      <Widget>[
        SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Text("משוב",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                )),
            background: Column(
              children: <Widget>[
                Spacer(),
                Row(
                  children: <Widget>[
                    Spacer(),
                    Text("ממוצע",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                        )),
                    Spacer(),
                    Text("שעות להיום",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                        )),
                    Spacer()
                  ],
                ),
                Row(
                  children: <Widget>[
                    Spacer(),
                    FutureBuilder<num>(
                        future: bloc.db.getAverage(),
                        builder: (context, snap) =>
                        snap.hasData
                            ? Text(
                            "${snap.data.toDouble() == snap.data.roundToDouble()
                                ? snap.data.toInt()
                                : snap.data.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                            ))
                            : Text("")),
                    Spacer(),
                    FutureBuilder(
                        future: bloc.db.todayLessonsCount(),
                        builder: (context, snap) =>
                        snap.hasData
                            ? Text("${snap.data}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                            ))
                            : Text("")),
                    Spacer()
                  ],
                ),
                Spacer()
              ],
            ),
          ),
        ),
      ];


}
