import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/ui/data_list_page.dart';

DataListPage<BehaveEvent> behaveRoute(BuildContext context) {
  TextStyle titleStyle = Theme.of(context).textTheme.subhead;
  TextStyle passThrough =
      titleStyle.copyWith(decoration: TextDecoration.lineThrough);
  return DataListPage<BehaveEvent>(
      notFoundMessage: "לא נמצאו אירועי התנהגות",
      builder: (BuildContext context, dynamic e) {
        BehaveEvent event = e;
        return ListTile(
            title: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          new TextSpan(
                              text: event.text,
                              style: event.justificationId > 0
                                  ? passThrough
                                  : titleStyle),
                          new TextSpan(
                              text: event.justificationId > 0
                                  ? "(${event.justification})"
                                  : "",
                              style: titleStyle),
                        ],
                      ),
                    ),
                    Spacer(),
                    Text("שיעור ${event.lesson}")
                  ],
                ),
              ],
            ),
            subtitle: Row(children: <Widget>[
              Text(event.subject),
              Spacer(),
//                          Text("${event.justification}(${event.justificationId})"),
//                          Spacer(),
              Text("${Inject.dateTimeToDateString(event.date)}")
            ]));
      },
      filters: [
        MenuFilter(
            label: "לפי סוג אירוע",
            icon: Icons.event_available,
            futureFilter: (items) {
              List<BehaveEvent> events = items.cast();
              //to set in order to remove duplicates
              return Inject.displayDialog(
                  events.map((e) => e.text).toSet().toList(),
                  "סוג אירוע",
                  context)
                  .then((type) {
                if (type != null && type.isNotEmpty)
                  events = events.where((e) => e.text == type).toList();
                //after filtering, sort by chronological order
                events.sort((e1, e2) => e2.date.compareTo(e1.date));
                return events;
              });
            }),
        MenuFilter(
            label: "לפי מקצוע",
            icon: Icons.school,
            futureFilter: (items) {
              List<BehaveEvent> events = items.cast();
              //to set in order to remove duplicates
              return Inject.displayDialog(
                  events.map((e) => e.subject).toSet().toList(),
                  "מקצוע",
                  context)
                  .then((subject) {
                if (subject != null && subject.isNotEmpty)
                  events = events.where((e) => e.subject == subject).toList();
                //after filtering, sort by chronological order
                events.sort((e1, e2) => e2.date.compareTo(e1.date));
                return events;
              });
            }),
        MenuFilter(
            label: "אחרונים",
            icon: Icons.date_range,
            filter: (items) {
              List<BehaveEvent> data = items.cast<BehaveEvent>();
              data.sort((e1, e2) => e2.date.compareTo(e1.date));
              return data;
            }),
        MenuFilter(
            label: "לפי הצדקה",
            icon: Icons.done,
            filter: (items) {
              List<BehaveEvent> data = items.cast<BehaveEvent>();
              data = data
                  .where(
                      (e) => e.justificationId != 0 && e.justificationId != -1)
                  .toList();
              data.sort(
                      (e1, e2) => e1.justificationId.compareTo(e2.justificationId));
              return data;
            }),
        MenuFilter(
            label: "ללא הצדקה",
            icon: Icons.clear,
            filter: (items) {
              List<BehaveEvent> data = items.cast<BehaveEvent>();
              return data
                  .where(
                      (e) => e.justificationId == 0 || e.justificationId == -1)
                  .toList();
            })
      ]);
}
