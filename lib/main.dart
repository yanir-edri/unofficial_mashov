import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/contollers/bloc.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/ui/data_list_page.dart';
import 'package:unofficial_mashov/ui/routes/home.dart';
import 'package:unofficial_mashov/ui/routes/login/login.dart';
import 'package:unofficial_mashov/ui/routes/login/school.dart';

void main() {
  runApp(MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => MyApp(),
          '/schools': (context) => ChooseSchoolRoute(),
          '/login': (context) => LoginRoute(),
          '/home': (context) => HomeRoute(),
          //{Key key, this.title, this.builder, this.api, this.additionalData}
          '/grades': (context) =>
              DataListPage(
                  additionalData: {"overview": false},
                  title: "ציונים",
                  api: Api.Grades,
                  builder: (BuildContext context, dynamic g) {
                    Grade grade = g;
                    return ListTile(
                        title: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(grade.event.length > 30
                                    ? "${grade.event.substring(0, 27)
                                    .trimRight()}..."
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
                          Text(
                              "${Inject.dateTimeToDateString(grade.eventDate)}")
                        ]));
                  },
                  filters: [
                    MenuFilter(label: "א'-ב'",
                        icon: Icons.sort_by_alpha,
                        filter: (items) {
                          List<Grade> grades = items.cast<Grade>();
                          grades.sort((g1, g2) => g1.event.compareTo(g2.event));
                          return grades;
                        }),
                    MenuFilter(label: "לפי מקצוע",
                        icon: Icons.school,
                        filter: (items) {
                          List<Grade> grades = items.cast<Grade>();
                          grades.sort((g1, g2) =>
                              g1.subject.compareTo(g2.subject));
                          return grades;
                        }),
                    MenuFilter(label: "אחרונים",
                        icon: Icons.date_range,
                        filter: (items) {
                          List<Grade> grades = items.cast<Grade>();
                          grades.sort((g1, g2) =>
                              g2.eventDate.compareTo(g1.eventDate));
                          return grades;
                        }),
                    MenuFilter(label: "לפי ציון (גבוה לנמוך)",
                        icon: Icons.arrow_downward,
                        filter: (items) {
                          List<Grade> grades = items.cast<Grade>();
                          grades.sort((g1, g2) => g2.grade.compareTo(g1.grade));
                          return grades;
                        }
                    ),
                    MenuFilter(label: "לפי ציון(נמוך לגבוה)",
                        icon: Icons.arrow_upward,
                        filter: (items) {
                          List<Grade> grades = items.cast<Grade>();
                          grades.sort((g1, g2) => g1.grade.compareTo(g2.grade));
                          return grades;
                        }
                    )
                  ]),

          '/behave': (context) {
            TextStyle titleStyle = Theme
                .of(context)
                .textTheme
                .subhead;
            TextStyle passThrough = titleStyle.copyWith(
                decoration: TextDecoration.lineThrough);
            return DataListPage(
                additionalData: {"overview": false},
                title: "אירועי התנהגות",
                api: Api.BehaveEvents,
                builder: (BuildContext context, dynamic e) {
                  BehaveEvent event = e;
                  return ListTile(
                      title: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    new TextSpan(text: event.text,
                                        style: event.justificationId > 0
                                            ? passThrough
                                            : titleStyle),
                                    new TextSpan(text: event.justificationId > 0
                                        ? "(${event.justification})"
                                        : "", style: titleStyle),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Text("שיעור ${event.lesson}")
                            ],
                          ),
                        ],
                      ),
                      subtitle: Row(children: <Widget>[
                        Text(event.subject),
                        Spacer(),
//                          Text("${event.justification}(${event.justificationId})"),
//                          Spacer(),
                        Text(
                            "${Inject.dateTimeToDateString(event.date)}")
                      ]));
                },
                filters: [
                  MenuFilter(label: "לפי סוג אירוע",
                      icon: Icons.event_available,
                      filter: (items) {
                        List<BehaveEvent> data = items.cast<BehaveEvent>();
                        data.sort((e1, e2) => e1.text.compareTo(e2.text));
                        return data;
                      }),
                  MenuFilter(label: "לפי מקצוע",
                      icon: Icons.school,
                      filter: (items) {
                        List<BehaveEvent> data = items.cast<BehaveEvent>();
                        data.sort((e1, e2) =>
                            e1.subject.compareTo(e2.subject));
                        return data;
                      }),
                  MenuFilter(label: "אחרונים",
                      icon: Icons.date_range,
                      filter: (items) {
                        List<BehaveEvent> data = items.cast<BehaveEvent>();
                        data.sort((e1, e2) =>
                            e2.date.compareTo(e1.date));
                        return data;
                      }),
                  MenuFilter(label: "לפי הצדקה",
                      icon: Icons.done,
                      filter: (items) {
                        List<BehaveEvent> data = items.cast<BehaveEvent>();
                        data = data.where((e) => e.justificationId != 0 &&
                            e.justificationId != -1)
                            .toList();
                        data.sort((e1, e2) =>
                            e1.justificationId.compareTo(e2.justificationId));
                        return data;
                      }
                  ),
                  MenuFilter(label: "ללא הצדקה",
                      icon: Icons.clear,
                      filter: (items) {
                        List<BehaveEvent> data = items.cast<BehaveEvent>();
                        return data.where((e) =>
                        e.justificationId == 0 || e.justificationId == -1)
                            .toList();
                      }
                  )
                ]);
          }
        }));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    if (!_failed) {
      return Scaffold(
          appBar: AppBar(title: Text("משוב"), centerTitle: true),
          body: Container(
              child: Center(child: CircularProgressIndicator()),
              margin: EdgeInsets.all(16)));
    }
    return AlertDialog(
        title: Text("ההתחברות לשרת המשוב נכשלה"),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text("אוקיי"),
          )
        ]);
  }

  @override
  void initState() {
    super.initState();
    bloc.setup().then((isSuccessful) {
      if (!isSuccessful) {
        setState(() {
          _failed = true;
        });
      } else {
        Navigator.pushReplacementNamed(
            context, bloc.hasCredentials() ? "/login" : "/schools");
      }
    });
  }
}
