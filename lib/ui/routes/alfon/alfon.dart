import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/ui/data_list_page.dart';
import 'package:url_launcher/url_launcher.dart';

class AlfonArguments {
  String groupName;
  String id;

  AlfonArguments({this.groupName, this.id});
}

DataListPage<Contact> alfonRoute(BuildContext context) => DataListPage<Contact>(
      notFoundMessage: "לא נמצאו אנשי קשר בקבוצה זו",
      title: "אנשי קשר",
      builder: (BuildContext context, dynamic g) {
        Contact c = g;
        return ListTile(
          title: Row(
            children: <Widget>[
              Text(c.name),
              Spacer(),
              FlatButton(
                child: Text(c.phone),
                onPressed: () async {
                  await launch("tel:+972${c.phone.substring(1)}");
//                  launch("tel:+972${c.phone.substring(1)})}");
                },
              )
            ],
          ),
          subtitle: Text(c.address),
        );
      },
    );
