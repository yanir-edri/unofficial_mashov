import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:provider/provider.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/providers/api_provider.dart';
import 'package:unofficial_mashov/ui/data_list.dart';
import 'package:unofficial_mashov/ui/overview_item.dart';

class HomeRoute extends StatelessWidget {
  final Widget todayList = DataList<Lesson>(
      notFoundMessage: "אין שיעורים היום",
      isDemo: true,
      builder: Inject.timetableBuilder());

  final Widget homeworkList = DataList<Homework>(
      notFoundMessage: "אין שיעורי בית",
      isDemo: true,
      builder: (BuildContext context, dynamic h) {
        Homework homework = h;
        return ListTile(
          title: Text(homework.message),
          subtitle: Row(
            children: <Widget>[
              Text(homework.subject),
              Spacer(),
              Text(Inject.dateTimeToDateString(homework.date))
            ],
          ),

          /*isThreeLine: true,*/
        );
      });
  final Widget gradesList = DataList<Grade>(
      notFoundMessage: "אין ציונים",
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
      });

  @override
  Widget build(BuildContext context) {
    //The padding for the label above the data list
    const EdgeInsets labelPadding =
    const EdgeInsets.only(right: Inject.margin * 1.25, top: Inject.margin);
    //The padding for the "see more" button
    const EdgeInsets seeMorePadding =
    const EdgeInsets.only(top: Inject.margin, left: Inject.margin / 2);
    GlobalKey<ScaffoldState> key = GlobalKey();
    List<Widget> bodyContent = <Widget>[
      //Grades list:
      Row(
        children: <Widget>[
          Padding(
            padding: labelPadding,
            child: Text("ציונים אחרונים:",
                style: Theme
                    .of(context)
                    .textTheme
                    .title),
          ),
          Spacer(),
          Padding(
            padding: seeMorePadding,
            child: FlatButton(
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
            ),
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
            padding: labelPadding,
            child: Text("ש\"ב:", style: Theme
                .of(context)
                .textTheme
                .title),
          ),
          Spacer(),
          Padding(
            padding: seeMorePadding,
            child: FlatButton(
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
            ),
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
            padding: labelPadding,
            child: Text("מערכת שעות יומית:",
                style: Theme
                    .of(context)
                    .textTheme
                    .title),
          ),
          Spacer(),
          Padding(
            padding: seeMorePadding,
            child: FlatButton(
              child: Text("כל המערכת",
                  style: Theme
                      .of(context)
                      .textTheme
                      .title
                      .copyWith(color: Theme
                      .of(context)
                      .accentColor)),
              onPressed: () {
                Navigator.pushNamed(context, '/timetable');
              },
            ),
          )
        ],
      ),
      Container(
          margin: EdgeInsets.fromLTRB(
              Inject.margin, 0, Inject.margin, Inject.margin),
          child: Center(child: Card(elevation: 2.0, child: todayList)),
          height: 300),
    ];
    Scaffold scaffold = Scaffold(
      drawer: Inject.getDrawer(context),
      key: key,
      body: CustomScrollView(slivers: <Widget>[
        headerBuilder(context),
        SliverList(
          delegate: SliverChildListDelegate(bodyContent),
        )
      ]),
    );
    return Inject.rtl(scaffold);
  }

  void workingOnIt(GlobalKey<ScaffoldState> key) {
    key.currentState.showSnackBar(SnackBar(
        content: Inject.rtl(Text("אני...אני עובד על זה! חכו לגרסה הבאה :)"))));
  }

  Widget headerBuilder(BuildContext context) =>
      SliverAppBar(
        //height needed to be exactly on the line of the drawer
        expandedHeight: 161.0,
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
                    title: "ממוצע",
                    data: Provider.of<ApiProvider<Grade>>(context)
                        .getUnfilteredOverviews()["ממוצע"]),
                Spacer(),
                OverviewItem(
                    title: "שעות להיום",
                    data: Provider.of<ApiProvider<Lesson>>(context)
                        .getUnfilteredOverviews()["שעות להיום"]),
                Spacer(),
                OverviewItem(
                    title: "הודעות חדשות",
                    data: Provider.of<ApiProvider<MessagesCount>>(context)
                        .getUnfilteredOverviews()["הודעות חדשות"]),
                Spacer()
              ],
            ),
          ),
        ),
      );
}
