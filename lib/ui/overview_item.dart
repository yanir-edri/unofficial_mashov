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
  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          StreamBuilder<num>(
              stream: widget.stream,
              builder: (context, snap) {
                print("overview(${widget.title}): recieved data ${snap.data}");
                return snap.hasData && (widget.isZeroGood || snap.data != 0)
                    ? Text(
                        "${snap.data.toDouble() == snap.data.roundToDouble() ? snap.data.toInt() : snap.data.toStringAsFixed(widget.precision)}",
                        style: widget.valueStyle)
                    : Text("");
              }),
          Text(widget.title, style: widget.headerStyle)
        ],
      );

  /* we don't want overview items to reload every time */
  @override
  bool get wantKeepAlive => true;
}
