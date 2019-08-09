import 'package:flutter/material.dart';

class OverviewItem extends StatelessWidget {
  final String title;
  final String data;
  final TextStyle headerStyle, valueStyle;

//  final bool isZeroGood;

  OverviewItem({@required this.title,
    @required this.data,
    this.headerStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
    this.valueStyle: const TextStyle(
        color: Colors.white, fontSize: 40.0) /*,
    this.isZeroGood: false*/
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          data,
          style: valueStyle,
        ),
        Text(title, style: headerStyle)
      ],
    );
  }
}
