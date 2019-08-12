import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:provider/provider.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/providers/api_provider.dart';
import 'package:unofficial_mashov/ui/routes/bagrut.dart';
import 'package:unofficial_mashov/ui/routes/behave.dart';
import 'package:unofficial_mashov/ui/routes/grades.dart';
import 'package:unofficial_mashov/ui/routes/home.dart';
import 'package:unofficial_mashov/ui/routes/login/login.dart';
import 'package:unofficial_mashov/ui/routes/login/school.dart';
import 'package:unofficial_mashov/ui/routes/maakav.dart';
import 'package:unofficial_mashov/ui/routes/time_table.dart';


void main() {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => MyApp(),
        '/schools': (context) => ChooseSchoolRoute(),
        '/login': (context) => LoginRoute(),
        '/home': (context) =>
            MultiProvider(child: HomeRoute(), providers: [
              ChangeNotifierProvider<ApiProvider<Grade>>(
                  builder: (_) => Inject.providers[Api.Grades]),
              ChangeNotifierProvider<ApiProvider<Lesson>>(
                  builder: (_) => Inject.providers[Api.Timetable]),
              ChangeNotifierProvider<ApiProvider<Homework>>(
                  builder: (_) => Inject.providers[Api.Homework])
            ],),
        '/grades': (context) =>
            ChangeNotifierProvider<ApiProvider<Grade>>(
              child: gradesRoute(context),
              builder: (_) => Inject.providers[Api.Grades],),
        '/behave': (context) =>
            ChangeNotifierProvider<ApiProvider<BehaveEvent>>(
              child: behaveRoute(context),
              builder: (_) => Inject.providers[Api.BehaveEvents],),
        '/timetable': (context) =>
            ChangeNotifierProvider<ApiProvider<Lesson>>(child: TimeTable(),
              builder: (_) => Inject.providers[Api.Timetable],),
        '/maakav': (context) =>
            ChangeNotifierProvider<ApiProvider<Maakav>>(
                child: maakavRoute(context),
                builder: (_) => Inject.providers[Api.Maakav]),
        '/bagrut': (context) =>
            ChangeNotifierProvider<ApiProvider<Bagrut>>(
                child: bagrutRoute(context),
                builder: (_) => Inject.providers[Api.Bagrut])}));
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
/*
import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:provider/provider.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/providers/api_provider.dart';
import 'package:unofficial_mashov/ui/routes/behave.dart';
import 'package:unofficial_mashov/ui/routes/grades.dart';
import 'package:unofficial_mashov/ui/routes/home.dart';
import 'package:unofficial_mashov/ui/routes/bagrut.dart';
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
      ChangeNotifierProvider<ApiProvider<Homework>>(
          builder: (_) => Inject.providers[Api.Homework]),
      ChangeNotifierProvider<ApiProvider<Maakav>>(
          builder: (_) => Inject.providers[Api.Maakav]),
      ChangeNotifierProvider<ApiProvider<Bagrut>>(
          builder: (_) => Inject.providers[Api.Bagrut])
    ],
    child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => MyApp(),
          '/schools': (context) => ChooseSchoolRoute(),
          '/login': (context) => LoginRoute(),
          '/home': (context) => HomeRoute(),
          '/grades': gradesRoute,
          '/behave': behaveRoute,
          '/timetable': (BuildContext context) => TimeTable(),
          '/maakav': maakavRoute,
          '/bagrut': bagrutRoute }),
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

*/