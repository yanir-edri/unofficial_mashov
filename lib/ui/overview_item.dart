import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unofficial_mashov/contollers/bloc.dart';

class OverviewItem extends StatelessWidget {
  final String title;
  final Stream<num> stream;
  final int precision;
  final TextStyle headerStyle, valueStyle;
  final bool isZeroGood;

  OverviewItem({@required this.title,
    @required this.stream,
    this.precision: 1,
    this.headerStyle: const TextStyle(color: Colors.white, fontSize: 20.0),
    this.valueStyle: const TextStyle(color: Colors.white, fontSize: 32.0),
    this.isZeroGood: false}) {
    if (!bloc.cache.containsKey(title)) {
      bloc.cache[title] = -1;
    }
  }

  @override
  Widget build(BuildContext context) =>
      Column(
        children: <Widget>[
          bloc.cache[title] == -1 ?
          StreamBuilder<num>(
              stream: stream,
              builder: (context, snap) {
                print("overview($title): recieved data ${snap
                    .data}, cache is ${bloc.cache[title]}");
                if (snap.hasData &&
                    (isZeroGood || snap.data != null && snap.data != 0)) {
                  bloc.cache[title] = snap.data;
                  return _build(snap.data);
                }
                return const Text("");
              }) : _build(bloc.cache[title])

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

/*
import 'dart:async';

import 'package:flutter/material.dart';

class OverviewItem extends StatefulWidget {
  final String title;
  final Stream<num> stream;
  final int precision;
  final TextStyle headerStyle, valueStyle;
  final bool isZeroGood;

  OverviewItem(
      {@required this.title,
      @required this.stream,
      this.precision: 1,
      this.headerStyle: const TextStyle(color: Colors.white, fontSize: 20.0),
      this.valueStyle: const TextStyle(color: Colors.white, fontSize: 32.0),
      this.isZeroGood: false});

  @override
  _OverviewItemState createState() => _OverviewItemState();
}

class _OverviewItemState extends State<OverviewItem>
    with AutomaticKeepAliveClientMixin<OverviewItem> {
  num cache = -1;
  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          cache == -1 ?
          StreamBuilder<num>(
              stream: widget.stream,
              builder: (context, snap) {
                print("overview(${widget.title}): recieved data ${snap.data}, cache is $cache");
                cache = snap.data;
                return snap.hasData && (widget.isZeroGood || snap.data != null && snap.data != 0)
                    ? _build(snap.data)
                    : Text("");
              }) : _build(cache)

          ,
          Text(widget.title, style: widget.headerStyle)
        ],
      );

  Text _build(num data) => Text(
        "${data.toDouble() == data.roundToDouble() ? data.toInt() : data.toStringAsFixed(widget.precision)}",
        style: widget.valueStyle);


  @override
  void initState() {
    super.initState();
    print("overview state initialized ${widget.title}");
  }

  /* we don't want overview items to reload every time */
  @override
  bool get wantKeepAlive => true;
}


*/
