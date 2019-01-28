import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';

class LoadingRoute extends StatelessWidget {
  final Future<Result<Login>> login;

  LoadingRoute({Key key, @required this.login}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }

}
