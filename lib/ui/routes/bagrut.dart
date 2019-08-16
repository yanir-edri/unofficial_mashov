import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/ui/data_list_page.dart';

DataListPage<Bagrut> bagrutRoute(BuildContext context) => DataListPage<Bagrut>(
    notFoundMessage: "לא נמצאו ציוני בגרויות",
    //we don't need to specify a builder because bagrut has a special builder function.
    builder: (BuildContext context, dynamic g) => null,
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
            grades.sort((g1, g2) {
              int comp = g2.finalGrade.compareTo(g1.finalGrade);
              if (comp == 0) comp = g2.testGrade.compareTo(g1.testGrade);
              if (comp == 0) comp = g2.yearGrade.compareTo(g1.yearGrade);
              return comp;
            });
            return grades;
          }),
      MenuFilter(
          label: "לפי ציון(נמוך לגבוה)",
          icon: Icons.arrow_upward,
          filter: (items) {
            List<Bagrut> grades = items.cast<Bagrut>();
            grades.sort((g1, g2) {
              int comp = g1.finalGrade.compareTo(g2.finalGrade);
              if (comp == 0) comp = g1.testGrade.compareTo(g2.testGrade);
              if (comp == 0) comp = g1.yearGrade.compareTo(g2.yearGrade);
              return comp;
            });
            return grades;
          })
    ]);
