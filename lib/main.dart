import 'package:flutter/material.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/routes/home.dart';
import 'package:unofficial_mashov/routes/login.dart';
import 'package:unofficial_mashov/routes/login/school.dart';

void main() =>
    runApp(MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => MyApp(),
          '/schools': (context) => ChooseSchoolRoute(),
          '/login': (context) => LoginRoute(),
          '/home': (context) => HomeRoute()
        }
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    if (!_failed) {
      return Scaffold(
          appBar: AppBar(title: Text("משוב"), centerTitle: true),
          body: Container(
              child: Center(child: CircularProgressIndicator()),
              margin: EdgeInsets.all(16)));
    }
    return AlertDialog(
        title: Text("ההתחברות לשרת המשוב נכשלה"),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text("אוקיי"),
          )
        ]);
  }

  @override
  void initState() {
    super.initState();
    Inject.setup().then((isSuccessful) {
      if (!isSuccessful) {
        setState(() {
          _failed = true;
        });
      } else {
        Navigator.pushReplacementNamed(context, "/schools");
      }
    });
  }
}
