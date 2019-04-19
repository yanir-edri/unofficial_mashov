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
          child: AppBar(title: Column(children: <Widget>[
            Center(child: Text("משוב")),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: <Widget>[
                Text("average"),
                Spacer(),
                Text("hours")
              ],),
            )
          ],)));


/*


AppBar(
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
              ])))


*/

  //turn YYYY-MM-DD'T'HH:MM:SS into DD/MM/YYYY
  static String dateTimeToDateString(DateTime d) =>
      d
          .toIso8601String()
          .split("T")
          .first
          .split("-")
          .reversed
          .join("/");

  static List<E> timetableDayProcess<E>(List<E> data) {
    int today = DateTime
        .now()
        .weekday;
    List<Lesson> timetable = data.cast<Lesson>();
    timetable.retainWhere((lesson) => lesson.day == today);
    timetable.sort((lesson1, lesson2) => lesson1.hour - lesson2.hour);
    return timetable as List<E>;
  }

  static const double margin = 24.0;

}
