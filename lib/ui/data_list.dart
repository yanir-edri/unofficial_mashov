import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/contollers/bloc.dart';

import '../inject.dart';

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
        stream: widget.stream != null
            ? widget.stream
            : bloc.getApiData(widget.api, data: widget.additionalData),
        builder: (context, snap) {
          if (snap.hasData && snap.data.length > 0) {
            _data = snap.data;

            if (_data.isNotEmpty && _data[0] is Lesson) {
              _data = Inject.timetableDayProcess(_data, widget.isDemo);
            } else if (widget.isDemo) {
              //if it's timetable, we will want to take the whole day.
              _data = _data.take(min(_data.length, 4)).toList();
            }
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

  //If the data list is a demo, we do not want to rebuild it every time we scroll
  @override
  bool get wantKeepAlive => true;
}
