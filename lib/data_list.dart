import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/contollers/bloc.dart';
import 'package:unofficial_mashov/inject.dart';

typedef Builder = Widget Function(BuildContext context, dynamic item);

class DataList<E> extends StatefulWidget {
  final Builder builder;
  final Api api;
  final Map additionalData;

  DataList(
      {Key key,
      this.builder,
      @required this.api,
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
            if (_data.isNotEmpty && E is Lesson) {
              print("data is proccessed as timetable\n");
              //TODO: what if this is on the actual time table
              //TODO: use additional data map to specify (with a boolean)
              _data = timetableDayProcess(_data);
            }
            print("returning listview with item count ${_data.length}");
            return ListView.builder(
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
    Inject.refreshController.refresh(widget.api);
  }

  @override
  void dispose() {
    super.dispose();
  }


  List<E> timetableDayProcess(List<E> data) {
    int today = DateTime
        .now()
        .weekday;
    List<Lesson> timetable = data.cast<Lesson>();
    timetable.retainWhere((lesson) => lesson.day == today);
    timetable.sort((lesson1, lesson2) => lesson1.hour - lesson2.hour);
    return timetable as List<E>;
  }
}
