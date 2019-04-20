import 'dart:async';
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
  final Stream<List<E>> stream;

  DataList({Key key,
    this.builder,
    @required this.api,
    this.stream,
    this.isDemo,
    this.additionalData})
      : super(key: key);

  @override
  DataListState<E> createState() {
    return new DataListState<E>();
  }

}

class DataListState<E> extends State<DataList>
    with AutomaticKeepAliveClientMixin<DataList> {
  List<E> _data = List();

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<List>(
        initialData: List(),
        //stream won't be null in data list page
        stream: widget.stream != null ? widget.stream : bloc.getApiData(
            widget.api, data: widget.additionalData),
        builder: (context, snap) {
          if (snap.hasData && snap.data.length > 0) {
            _data = snap.data;

            if (_data.isNotEmpty && _data[0] is Lesson) {
              _data = timetableDayProcess(_data, widget.isDemo);
            } else if (widget.isDemo) {
              //if it's timetable, we will want to take the whole day.
              _data = _data.take(min(_data.length, 4)).toList();
            }
//            _data
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
          return Center(
            child: Container(
                margin: EdgeInsets.all(100),
                child: CircularProgressIndicator()),
          );
        },
      );


  @override
  void dispose() {
    super.dispose();
//    widget._processedStream.close();
  }


  List<E> timetableDayProcess(List<E> data, bool isDemo) {
    //the days of the mashov go from 1 to 7, not from 0 to 6.
    List<Lesson> timetable = data.cast<Lesson>();
    if (isDemo) {
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
    return day == 7 ? 1 : day + 1;
  }

  //If the data list is a demo, we do not want to rebuild it every time we scroll
  @override
  bool get wantKeepAlive => true;
}
