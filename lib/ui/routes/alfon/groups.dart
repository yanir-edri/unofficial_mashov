import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/ui/data_list_page.dart';
import 'package:unofficial_mashov/ui/routes/alfon/alfon.dart';

DataListPage<Group> groupsRoute(BuildContext context) => DataListPage<Group>(
      notFoundMessage: "לא נמצאו קבוצות אלפון",
      title: "קבוצות אלפון",
      builder: (BuildContext context, dynamic g) {
        return ListTile(
          title: Text(g.subject),
          subtitle: Text(g.teachers.isNotEmpty ? g.teachers.join(", ") : ""),
          onTap: () {
            Inject.onNewRoute("/contacts");
            Navigator.pushNamed(context, "/contacts",
                arguments: AlfonArguments(groupName: g.subject, id: "${g.id}"));
          },
        );
      },
    );
