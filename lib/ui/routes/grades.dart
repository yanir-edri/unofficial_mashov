import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/ui/data_list_page.dart';

DataListPage<Grade> gradesRoute(BuildContext context) => DataListPage<Grade>(
    notFoundMessage: "לא נמצאו ציונים",
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
    filters: [
      MenuFilter(
          label: "א'-ב'",
          icon: Icons.sort_by_alpha,
          filter: (items) {
            List<Grade> grades = items.cast<Grade>();
            grades.sort((g1, g2) => g1.event.compareTo(g2.event));
            return grades;
          }),
      MenuFilter(
          label: "לפי מקצוע",
          icon: Icons.school,
          futureFilter: (items) {
            List<Grade> grades = items.cast<Grade>();
            //to set in order to remove duplicates
            return Inject.displayDialog(
                grades.map((g) => g.subject).toSet().toList(),
                "מקצוע",
                context)
                .then((subject) {
              if (subject != null && subject.isNotEmpty)
                grades = grades.where((g) => g.subject == subject).toList();
              //after filtering, sort by chronological order
              grades.sort((g1, g2) => g2.eventDate.compareTo(g1.eventDate));
              return grades;
            });
          }),
      MenuFilter(
          label: "אחרונים",
          icon: Icons.date_range,
          filter: (items) {
            List<Grade> grades = items.cast<Grade>();
            grades.sort((g1, g2) => g2.eventDate.compareTo(g1.eventDate));
            return grades;
          }),
      MenuFilter(
          label: "לפי ציון (גבוה לנמוך)",
          icon: Icons.arrow_downward,
          filter: (items) {
            List<Grade> grades = items.cast<Grade>();
            grades.sort((g1, g2) => g2.grade.compareTo(g1.grade));
            return grades;
          }),
      MenuFilter(
          label: "לפי ציון(נמוך לגבוה)",
          icon: Icons.arrow_upward,
          filter: (items) {
            List<Grade> grades = items.cast<Grade>();
            grades.sort((g1, g2) => g1.grade.compareTo(g2.grade));
            return grades;
          })
    ]);
