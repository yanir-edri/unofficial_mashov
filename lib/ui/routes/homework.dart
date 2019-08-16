import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/ui/data_list_page.dart';

DataListPage<Homework> homeworkRoute(BuildContext context) =>
    DataListPage<Homework>(
      title: "שיעורי בית",
      notFoundMessage: "אין שיעורי בית",
      builder: (BuildContext context, dynamic h) {
        Homework homework = h;
        return ListTile(
          title: Text(homework.message.trim()),
          subtitle: Row(children: <Widget>[
            Text(homework.subject),
            Spacer(),
            Text(Inject.dateTimeToDateString(homework.date))
          ]),
        );
      },
    );
