import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:provider/provider.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/providers/api_provider.dart';

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

  Widget buildBody(BuildContext context, List<Lesson> data) {
    if (data.isNotEmpty) {
      _lessons
        ..clear()
        ..addAll(data);
      _map.clear();
      for (int i = 1; i <= 6; i++) {
        _map[i] = Inject.timetableDayProcess(
            _lessons.where((l) => l.day == i).toList(), false);
      }
      var builder = Inject.timetableBuilder();
      return TabBarView(
          children: List.generate(_days.length, (i) {
            return Container(
                child: ListView.builder(
                    itemBuilder: (context, j) =>
                        builder(context, _map[i + 1][j]),
                    itemCount: _map[i + 1].length));
          }));
    }
    return Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    ApiProvider<Lesson> provider = Provider.of<ApiProvider<Lesson>>(context);
    return Inject.rtl(DefaultTabController(
      child: Scaffold(
          drawer: Inject.getDrawer(context),
          appBar: AppBar(
              title: Text("מערכת שעות"),
              centerTitle: true,
              bottom: TabBar(
                tabs: List.generate(_days.length, (i) => Text(_days[i])),
                labelPadding: EdgeInsets.all(8.0),
              )),
          body: buildBody(context, provider.data)),
      length: _days.length,
    ));
  }
}
