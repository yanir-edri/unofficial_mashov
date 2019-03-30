import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/contollers/bloc.dart';

typedef Builder = Widget Function(BuildContext context, dynamic item);

class DataList<E> extends StatefulWidget {
  final Builder builder;
  final Api api;
  final Map additionalData;
  final bool isDemo;

  DataList({Key key,
    this.builder,
    @required this.api,
    this.isDemo,
    this.additionalData})
      : super(key: key);

  @override
  DataListState<E> createState() {
    return new DataListState<E>();
  }
}

class DataListState<E> extends State<DataList> /*implements Callback*/ {

  List<E> _data = List();

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<List>(
        initialData: List(),
        stream: bloc.getApiData(widget.api, data: widget.additionalData),
        builder: (context, snap) {
          if (snap.hasData && snap.data.length > 0) {
            print("snap received data\n");

            _data = snap.data;

            if (_data.isNotEmpty && _data[0] is Lesson) {
              _data = timetableDayProcess(_data, widget.isDemo);
            } else if (widget.isDemo) {
              //if it's timetable, we will want to take the whole day.
              _data = _data.take(min(_data.length, 4)).toList();
            }
            _data = _data.reversed.toList();
            return ListView.builder(
                physics: widget.isDemo && !(_data[0] is Lesson)
                    ? NeverScrollableScrollPhysics()
                    : ClampingScrollPhysics(),
                itemCount: _data.length,
                itemBuilder: (BuildContext context, int i) =>
                    widget.builder(context, _data[i])).build(context);
          } else if (snap.hasError) {
            print("snapshot error\n");
            return const Center(child: const Text("טעינת המידע נכשלה"));
          }
          print("data list loading, returning circular progress view\n");
          return Container(
              margin: EdgeInsets.all(100), child: CircularProgressIndicator());
        },
      );

  @override
  void initState() {
    super.initState();
    bloc.refreshController.refresh(widget.api);
  }

  @override
  void dispose() {
    super.dispose();
  }


  List<E> timetableDayProcess(List<E> data, bool isDemo) {
    //the days of the mashov go from 1 to 7, not from 0 to 6.
    List<Lesson> timetable = data.cast<Lesson>();
    if (isDemo) {
      print("today is ${DateTime
          .now()
          .weekday}");
      if (today == 7) {
        //get some sleep on saturday!
        timetable = [];
        for (int i = 0; i < 6; i++) {
          timetable.add(Lesson(groupId: 0,
              day: 7,
              subject: "לישון",
              hour: i + 1,
              teachers: [],
              room: ""));
        }
      } else {
        //just a normal day
        //setting temp variable just to avoid calculation of today a lot of times
        int day = today;
        timetable.retainWhere((lesson) {
          return lesson.day == day;
        });
      }
    }
    if (today != 7) {
      timetable.sort((lesson1, lesson2) =>
          lesson1.hour.compareTo(lesson2.hour));
    }
    return timetable as List<E>;
  }

  int get today {
    int day = DateTime
        .now()
        .weekday;
    return day == 7 ? 0 : day + 1;
  }
}
