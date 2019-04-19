import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/contollers/bloc.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/ui/data_list.dart';
import 'package:unofficial_mashov/ui/overview_item.dart';

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
                OverviewItem(
                    title: "ממוצע", stream: bloc.getOverviewData(Api.Grades)),
                Spacer(),
                OverviewItem(
                    title: "שעות להיום",
                    stream: bloc.getOverviewData(Api.Timetable)),
                Spacer(),
                OverviewItem(
                    title: "הודעות חדשות",
                    stream: bloc.getOverviewData(Api.MessagesCount),
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
