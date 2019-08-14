import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/ui/data_list_page.dart';

DataListPage<Hatama> hatamotRoute(BuildContext context) => DataListPage<Hatama>(
    notFoundMessage: "אין התאמות",
    title: "התאמות",
    builder: (BuildContext context, dynamic h) {
      Hatama hatama = h;
      return ListTile(title: Text(hatama.name), subtitle: Text(hatama.remark));
    });

DataListPage<HatamatBagrut> hatamotBagrutRoute(BuildContext context) =>
    DataListPage<HatamatBagrut>(
      notFoundMessage: "אין התאמות בגרות",
      title: "התאמות בגרות",
      builder: (BuildContext context, dynamic h) {
        HatamatBagrut hatama = h;
        return ListTile(
            isThreeLine: true,
            title: Text(hatama.hatama),
            subtitle: Text("${hatama.name}\n" +
                "שאלון " +
                hatama.semel +
                ", מועד " +
                Inject.bagrutDate(hatama.moed)));
      },
    );
