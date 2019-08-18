import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:provider/provider.dart';
import 'package:unofficial_mashov/providers/api_provider.dart';

import '../inject.dart';

typedef Builder = Widget Function(BuildContext context, dynamic item);

class DataList<E> extends StatelessWidget {
  final Builder builder;
  final bool isDemo;
  final String notFoundMessage;

  DataList({Key key,
    @required this.builder,
    @required this.isDemo,
    @required this.notFoundMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ApiProvider<E> provider =
    Provider.of<ApiProvider<E>>(context, listen: isDemo);
    if (provider.hasData) {
      List<E> data = provider.data;
      if (provider.data[0] is Lesson) {
        //if it's timetable, we will want to take the whole day.
        data = Inject.cloneTimetable(provider.data);
        data = Inject.timetableDayProcess(data, isDemo);
      } else if (isDemo) {
        data = data.take(min(data.length, 5)).toList();
      }
      if ("$E" == "Bagrut") {
        List<Bagrut> grades = data.cast<Bagrut>();
        TextStyle colStyle = Theme
            .of(context)
            .textTheme
            .title;
        TextStyle valueStyle =
        Theme
            .of(context)
            .textTheme
            .title
            .copyWith(fontSize: 16);
        return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: data.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) {
                return Container(
                  margin: EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 3,
                          child: Text("מקצוע",
                              style: colStyle, textAlign: TextAlign.center)),
                      Expanded(
                          flex: 1,
                          child: Text("שנתי",
                              style: colStyle, textAlign: TextAlign.center)),
                      Expanded(
                          flex: 1,
                          child: Text("מבחן",
                              style: colStyle, textAlign: TextAlign.center)),
                      Expanded(
                          flex: 1,
                          child: Text("סופי",
                              style: colStyle, textAlign: TextAlign.center)),
                    ],
                  ),
                );
              }
              return Container(
                margin: EdgeInsets.all(8.0),
                child: Row(children: <Widget>[
                  Expanded(flex: 3, child: Text(grades[i - 1].name)),
                  Expanded(
                      flex: 1,
                      child: Text("${grades[i - 1].yearGrade}",
                          style: valueStyle, textAlign: TextAlign.center)),
                  Expanded(
                      flex: 1,
                      child: Text("${grades[i - 1].testGrade}",
                          style: valueStyle, textAlign: TextAlign.center)),
                  Expanded(
                      flex: 1,
                      child: Text("${grades[i - 1].finalGrade}",
                          style: valueStyle, textAlign: TextAlign.center)),
                ]),
              );
            });
      }
      if (data.length == 0) {
        return ListView.builder(
            itemBuilder: (c, i) =>
                Container(
                    margin: EdgeInsets.all(16),
                    child: Center(child: Text(notFoundMessage))),
            itemCount: 1);
      }
      return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: data.length,
          itemBuilder: (BuildContext context, int i) =>
              builder(context, data[i]));
    }
    if (provider.hasError && provider.error != "-") {
      return Center(
          child: Container(
              margin: EdgeInsets.all(16), child: Text(provider.error)));
    } else if (provider.isRequesting) {
      if (provider.isRefreshing) return Container();
      return Center(
        child: Container(
            margin: EdgeInsets.all(100), child: CircularProgressIndicator()),
      );
    } else {
      return ListView.builder(
          itemBuilder: (c, i) =>
              Container(
                  margin: EdgeInsets.all(16),
                  child: Center(child: Text(notFoundMessage))),
          itemCount: 1);
    }
  }
}
