import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unofficial_mashov/contollers/bloc.dart';

class OverviewItem extends StatefulWidget {
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
    assert(stream != null || this.data != null,
    "Error: overview item must recieve either data or stream.");
    if (!bloc.cache.containsKey(title) && data == -1) {
      bloc.cache[title] = data;
    }
  }

  @override
  _OverviewItemState createState() => _OverviewItemState();
}

class _OverviewItemState extends State<OverviewItem>
    with AutomaticKeepAliveClientMixin<OverviewItem> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: <Widget>[
        widget.data != -1
            ? _build(
            widget.data == null ? bloc.cache[widget.title] : widget.data)
            : StreamBuilder<num>(
            stream: widget.stream,
            builder: (context, snap) {
//                print("overview($title): recieved data ${snap
//                    .data}, cache is ${bloc.cache[title]}");
              if (snap.hasData &&
                  (widget.isZeroGood || snap.data != null && snap.data != 0)) {
                bloc.cache[widget.title] = snap.data;
                return _build(snap.data);
              }
              return const Text("");
            }),
        Text(widget.title, style: widget.headerStyle)
      ],
    );
  }

  Text _build(num data) =>
      Text(
          "${data.toDouble() == data.roundToDouble() ? data.toInt() : data
              .toStringAsFixed(widget.precision)}",
          style: widget.valueStyle);

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
