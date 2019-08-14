import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:provider/provider.dart';
import 'package:unofficial_mashov/providers/api_provider.dart';

import '../inject.dart';

typedef Builder = Widget Function(BuildContext context, dynamic item);

class DataList<E> extends StatelessWidget {
  final Builder builder;
  final Map additionalData;
  final bool isDemo;
  final String notFoundMessage;

  DataList({Key key,
    @required this.builder,
    @required this.isDemo,
    @required this.notFoundMessage,
    this.additionalData})
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
        data = data.reversed.take(min(data.length, 5)).toList();
      }
      if (isDemo) {
        return ListView.builder(
            physics: ClampingScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (BuildContext context, int i) =>
                builder(context, data[i]));
      }
      return SliverList(
          delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int i) => builder(context, data[i]),
              childCount: data.length));
    }
    Widget w = Container();
    if (provider.hasError) {
      w = Center(
          child: Container(
              margin: EdgeInsets.all(16), child: Text(provider.error)));
    } else if (provider.isRequesting) {
      w = Center(
        child: Container(
            margin: EdgeInsets.all(100), child: CircularProgressIndicator()),
      );
    } else {
      w = Center(
          child: Container(
              margin: EdgeInsets.all(16), child: Text(notFoundMessage)));
    }
    return isDemo ? w : SliverToBoxAdapter(child: w);
  }
}
