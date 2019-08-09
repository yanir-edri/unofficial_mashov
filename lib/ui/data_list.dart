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

  DataList({Key key, this.builder, this.isDemo, this.additionalData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ApiProvider<E> provider =
    Provider.of<ApiProvider<E>>(context, listen: isDemo);
    List<E> data = provider.data;
    if (provider.hasData) {
      if (data.isNotEmpty && data[0] is Lesson) {
        data = Inject.timetableDayProcess(data, isDemo);
      } else if (isDemo) {
        //if it's timetable, we will want to take the whole day.
        data = data.take(min(data.length, 5)).toList();
      }
      if (isDemo) {
        return ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (BuildContext context, int i) =>
                builder(context, data[i]));
      }
      return SliverList(
          delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int i) => builder(context, data[i]),
              childCount: data.length));
    }
    Widget loading = Center(
      child: Container(
          margin: EdgeInsets.all(100), child: CircularProgressIndicator()),
    );

    return isDemo ? loading : SliverToBoxAdapter(child: loading);
  }
}
