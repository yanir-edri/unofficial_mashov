import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/routes/login.dart';
import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';

void main() {
  Inject.setup();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: MaterialApp(
            home: Scaffold(
                appBar: AppBar(title: Text("משוב"), centerTitle: true),
                body: Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Directionality(
                        textDirection: TextDirection.rtl, child: LoginForm()))
//                LoginForm()
            )
        )
    );
  }
}
