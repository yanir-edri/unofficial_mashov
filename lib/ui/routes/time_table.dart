import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/contollers/bloc.dart';

import '../../inject.dart';

class TimeTable extends StatelessWidget {
  final List<Lesson> _lessons = List();
  final List<String> _days = [
    "ראשון",
    "שני",
    "שלישי",
    "רביעי",
    "חמישי",
    "שישי"
  ];
  final Map<int, List<Lesson>> _map = Map();

  @override
  Widget build(BuildContext context) {
    Widget body = StreamBuilder(
        stream: bloc.getApiData(Api.Timetable, data: {"overview": false}),
        builder: (context, snap) {
          if (snap.hasData) {
            _lessons
              ..clear()
              ..addAll(snap.data);
            _map.clear();
            for (int i = 1; i <= 6; i++) {
              _map[i] = Inject.timetableDayProcess(
                  _lessons.where((l) => l.day == i).toList(), false);
            }
            return TabBarView(
                children: List.generate(_days.length, (i) {
              return Container(
                  child: ListView.builder(
                          itemBuilder: (context, j) =>
                              Inject.timetableBuilder()(
                                  context, _map[i + 1][j]),
                          itemCount: _map[i + 1].length)
                      .build(context));
            }));
          }
          return CircularProgressIndicator();
        });
    return Inject.rtl(DefaultTabController(
      child: Scaffold(
          drawer: bloc.getDrawer(context),
          appBar: AppBar(
              title: Text("מערכת שעות"),
              centerTitle: true,
              bottom: TabBar(
                tabs: List.generate(_days.length, (i) => Text(_days[i])),
                labelPadding: EdgeInsets.all(8.0),
              )),
          body: body),
      length: _days.length,
    ));
  }
}
