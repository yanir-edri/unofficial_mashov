import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/ui/data_list_page.dart';

DataListPage<Bagrut> bagrutRoute(BuildContext context) => DataListPage<Bagrut>(
    notFoundMessage: "לא נמצאו ציוני בגרויות",
    additionalData: {"overview": false},
    builder: (BuildContext context, dynamic g) {
      Bagrut grade = g;
      return ListTile(
          title: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(grade.name.length > 30
                      ? "${grade.name.substring(0, 27).trimRight()}..."
                      : grade.name.padRight(30)),
                  Spacer(),
                  Text("${grade.yearGrade}"),
                  Spacer(),
                  Text("${grade.testGrade}"),
                  Spacer(),
                  Text("${grade.finalGrade}"),
                  Spacer()
                ],
              ),
            ],
          ),
          subtitle: Text(Inject.bagrutDate(grade.moed)));
    },
    filters: [
      MenuFilter(
          label: "א'-ב'",
          icon: Icons.sort_by_alpha,
          filter: (items) {
            List<Bagrut> grades = items.cast<Bagrut>();
            grades.sort((g1, g2) => g1.name.compareTo(g2.name));
            return grades;
          }),
      MenuFilter(
          label: "אחרונים",
          icon: Icons.date_range,
          filter: (items) {
            List<Bagrut> grades = items.cast<Bagrut>();
            grades.sort((g1, g2) => g2.date.compareTo(g1.date));
            return grades;
          }),
      MenuFilter(
          label: "לפי ציון (גבוה לנמוך)",
          icon: Icons.arrow_downward,
          filter: (items) {
            List<Bagrut> grades = items.cast<Bagrut>();
            grades.sort((g1, g2) => g2.testGrade.compareTo(g1.testGrade));
            return grades;
          }),
      MenuFilter(
          label: "לפי ציון(נמוך לגבוה)",
          icon: Icons.arrow_upward,
          filter: (items) {
            List<Bagrut> grades = items.cast<Bagrut>();
            grades.sort((g1, g2) => g1.testGrade.compareTo(g2.testGrade));
            return grades;
          })
    ]);
