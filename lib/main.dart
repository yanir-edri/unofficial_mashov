import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:provider/provider.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/providers/api_provider.dart';
import 'package:unofficial_mashov/ui/routes/bagrut.dart';
import 'package:unofficial_mashov/ui/routes/behave.dart';
import 'package:unofficial_mashov/ui/routes/grades.dart';
import 'package:unofficial_mashov/ui/routes/hatamot.dart';
import 'package:unofficial_mashov/ui/routes/home.dart';
import 'package:unofficial_mashov/ui/routes/login/login.dart';
import 'package:unofficial_mashov/ui/routes/login/school.dart';
import 'package:unofficial_mashov/ui/routes/maakav.dart';
import 'package:unofficial_mashov/ui/routes/time_table.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<ApiProvider<Grade>>(
          builder: (_) => Inject.providers[Api.Grades]),
      ChangeNotifierProvider<ApiProvider<BehaveEvent>>(
          builder: (_) => Inject.providers[Api.BehaveEvents]),
      ChangeNotifierProvider<ApiProvider<Lesson>>(
          builder: (_) => Inject.providers[Api.Timetable]),
      ChangeNotifierProvider<ApiProvider<Maakav>>(
          builder: (_) => Inject.providers[Api.Maakav]),
      ChangeNotifierProvider<ApiProvider<Homework>>(
          builder: (_) => Inject.providers[Api.Homework]),
      ChangeNotifierProvider<ApiProvider<Bagrut>>(
          builder: (_) => Inject.providers[Api.Bagrut]),
      ChangeNotifierProvider<ApiProvider<Hatama>>(
        builder: (_) => Inject.providers[Api.Hatamot],
      ),
      ChangeNotifierProvider<ApiProvider<HatamatBagrut>>(
          builder: (_) => Inject.providers[Api.HatamotBagrut])
    ],
    child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => MyApp(),
          '/schools': (context) => ChooseSchoolRoute(),
          '/login': (context) => LoginRoute(),
          '/home': (context) => HomeRoute(),
          '/grades': (context) => gradesRoute(context),
          '/behave': (context) => behaveRoute(context),
          '/timetable': (context) => TimeTable(),
          '/maakav': (context) => maakavRoute(context),
          '/bagrut': (context) => bagrutRoute(context),
          '/hatamot': (context) => hatamotRoute(context),
          '/hatamotBagrut': (context) => hatamotBagrutRoute(context)
        }),
  ));
}

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
          ),
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/');
            },
            child: Text("נסה שוב"),
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
        Navigator.pushReplacementNamed(
            context, Inject.hasCredentials() ? "/login" : "/schools");
      }
    });
  }
}