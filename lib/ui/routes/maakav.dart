import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/ui/data_list_page.dart';

DataListPage<Maakav> maakavRoute(BuildContext context) => DataListPage<Maakav>(
      builder: (context, e) {
        Maakav event = e;

        TextTheme theme = Theme.of(context).textTheme;
        return Card(
            elevation: 8.0,
            margin: EdgeInsets.all(8.0),
            child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        event.reporter +
                            " בתאריך " +
                            Inject.dateTimeToDateString(event.date) +
                            ":",
                        style: theme.title),
                    Text(Inject.formatMessage(event.message),
                        style: theme.body1),
                    for (Attachment attachment in event.attachments)
                      FlatButton.icon(
                          onPressed: () {
                            Inject.downloadFile(event.id, attachment).then((f) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(f != null
                                      ? "הקובץ ירד בהצלחה!"
                                      : "הורדת הקובץ נכשלה")));
                            });
                          },
                          icon: Icon(Icons.attach_file),
                          label: Text(attachment.name))
                  ],
                )));
      },
    );
