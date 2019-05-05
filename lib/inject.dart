import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';

typedef Builder = Widget Function(BuildContext context, dynamic item);

class Inject {
  //Wraps a widget with RTL directionality.
  static Widget rtl(Widget w) =>
      Directionality(textDirection: TextDirection.rtl, child: w);

  static Widget wrapper(Widget w) {
    return rtl(Scaffold(
        appBar: AppBar(title: Text("התחברות למשוב"), centerTitle: true),
        body: Container(margin: EdgeInsets.all(16.0), child: w)));
  }

  static PreferredSizeWidget appbar() =>
      PreferredSize(
          preferredSize: Size.fromHeight(150),
          child: AppBar(
              title: Column(
                children: <Widget>[
                  Center(child: Text("משוב")),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Text("average"),
                        Spacer(),
                        Text("hours")
                      ],
                    ),
                  )
                ],
              )));

  //turn YYYY-MM-DD'T'HH:MM:SS into DD/MM/YYYY
  static String dateTimeToDateString(DateTime d) =>
      d
          .toIso8601String()
          .split("T")
          .first
          .split("-")
          .reversed
          .join("/");


  static const double margin = 24.0;

  static Builder timetableBuilder() =>
          (BuildContext context, dynamic l) {
        Lesson lesson = l;
        Widget Function(String subject, List<String> teachers) builder =
            (String subject, List<String> teachers) =>
            ListTile(
                title: Text(subject),
                subtitle: Text(teachers.join(", ")),
                contentPadding: EdgeInsets.only(left: 4.0, right: 4.0));
        //if there is only one lesson, it should be right next to the hour.
        //otherwise, we want a spacer and a divider
        List<Widget> content = List();
        if (!lesson.subject.contains("|||")) {
          content.add(builder(lesson.subject, lesson.teachers));
        } else {
          List<String> subjects = lesson.subject.split("|||");
          int teachersIndex = 0;
          for (int i = 0; i < subjects.length; i++) {
            List<String> teachers = List();
            while (teachersIndex < lesson.teachers.length &&
                lesson.teachers[teachersIndex] != "|||") {
              teachers.add(lesson.teachers[teachersIndex++]);
            }
            teachersIndex++;
            //add one to skip ||| for the next one
            content.add(builder(subjects[i], teachers));
          }
        }
        return ListTile(
          leading: CircleAvatar(
            child: Text("${lesson.hour}",
                style:
                Theme
                    .of(context)
                    .textTheme
                    .body1
                    .copyWith(fontSize: 18)),
            backgroundColor: Colors.transparent,
          ),
          title: Column(children: content),
          contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
          dense: true,
        );
      };

  static List<E> timetableDayProcess<E>(List<E> data, bool isDemo) {
    //the days of the mashov go from 1 to 7, not from 0 to 6.
    List<Lesson> timetable = data.cast<Lesson>();
    if (isDemo) {
      if (today == 7) {
        //get some sleep on saturday!
        timetable = [];
        for (int i = 0; i < 6; i++) {
          timetable.add(Lesson(groupId: 0,
              day: 7,
              subject: "לישון",
              hour: i + 1,
              teachers: [],
              room: ""));
        }
      } else {
        //just a normal day
        //setting temp variable just to avoid calculation of today a lot of times
        int day = today;
        timetable.retainWhere((lesson) {
          return lesson.day == day;
        });
      }
    }
    if (today != 7) {
      timetable.sort((lesson1, lesson2) =>
          lesson1.hour.compareTo(lesson2.hour));
      for (int i = 0; i < timetable.length - 1; i++) {
        if (timetable[i].hour == timetable[i + 1].hour) {
          timetable[i].teachers.addAll(["|||", ...(timetable[i + 1].teachers)]);
          timetable[i].subject += "|||${timetable[i + 1].subject}";
          timetable.removeAt(i + 1);
        }
      }
    }
    return timetable as List<E>;
  }

  static int get today {
    int day = DateTime
        .now()
        .weekday;
    return day == 7 ? 1 : day + 1;
  }
}
