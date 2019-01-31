import 'package:flutter/material.dart';

class LoadingRoute extends StatelessWidget {
  final Future future;
  final String errorMessage;
  final BuildContext context;

  LoadingRoute({Key key,
    @required this.context,
    @required this.future,
    @required this.errorMessage})
      : super(key: key) {
    future.then((result) {
      Navigator.pop(context, true);
    }).catchError((error) {
      showDialog(context: context, builder: (context) {
        return Text(errorMessage);
      }).then((result) {
        //We don't care about result
        //Just go back
        Navigator.pop(context, false);
      });
    });
  }

  @override
  Widget build(BuildContext context) => Center(child: CircularProgressIndicator());
}
