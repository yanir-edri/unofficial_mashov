import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unofficial_mashov/contollers/bloc.dart';

class OverviewItem extends StatelessWidget {
  final String title;
  final Stream<num> stream;
  final num data;
  final int precision;
  final TextStyle headerStyle, valueStyle;
  final bool isZeroGood;

  OverviewItem({@required this.title,
    this.stream,
    this.data: -1,
    this.precision: 1,
    this.headerStyle: const TextStyle(color: Colors.white, fontSize: 20.0),
    this.valueStyle: const TextStyle(color: Colors.white, fontSize: 32.0),
    this.isZeroGood: false}) {
    assert(stream != null || this.data !=
        null, "Error: overview item must recieve either data or stream.");
    if (!bloc.cache.containsKey(title) && data == -1) {
      bloc.cache[title] = data;
    }
  }

  @override
  Widget build(BuildContext context) =>
      Column(
        children: <Widget>[
          data != -1 ? _build(data == null ? bloc.cache[title] : data) :
          StreamBuilder<num>(
              stream: stream,
              builder: (context, snap) {
//                print("overview($title): recieved data ${snap
//                    .data}, cache is ${bloc.cache[title]}");
                if (snap.hasData &&
                    (isZeroGood || snap.data != null && snap.data != 0)) {
                  bloc.cache[title] = snap.data;
                  return _build(snap.data);
                }
                return const Text("");
              })
          ,
          Text(title, style: headerStyle)
        ],
      );

  Text _build(num data) =>
      Text(
          "${data.toDouble() == data.roundToDouble() ? data.toInt() : data
              .toStringAsFixed(precision)}",
          style: valueStyle);

}