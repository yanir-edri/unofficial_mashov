import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unofficial_mashov/api_ps.dart';
import 'package:unofficial_mashov/contollers/database_controller.dart';
import 'package:unofficial_mashov/contollers/files_controller.dart';
import 'package:unofficial_mashov/contollers/refresh_controller.dart';
import 'package:unofficial_mashov/inject.dart';

class MasterBloc extends Callback {
  ApiController _apiController = MashovApi.getController();
  DatabaseController _databaseController;
  RefreshController _refreshController;
  bool _loginCredentialsSaved = false;
  bool _loggedOut = false;

  // ignore: non_constant_identifier_names
  Duration _100ms = const Duration(milliseconds: 100);
  Map<String, num> cache = {};

  Future<bool> isConnected() =>
      Connectivity()
          .checkConnectivity()
          .then((result) => result != ConnectivityResult.none)
          .catchError((error) => false);

  Future<bool> setup() =>
      isConnected().then((connected) {
        print("is connected equals $connected");
        if (!connected) return false;
        if (_loggedOut) return Future.value(true);
        return SharedPreferences.getInstance()
            .then((prefs) {
          _databaseController = DatabaseController(prefs);
          _refreshController = RefreshController();
          _refreshController.attach(this);
          return filesController.initStorage();
        })
            .then((n) => _databaseController.init())
            .then((successful) =>
        !successful
            ? Future.value(Result<List<School>>(
            value: List(),
            exception: "error initializing database",
            statusCode: -1))
            : _apiController.getSchools())
            .then((result) {
          if (result.isSuccess) {
            _schools = result.value;
            return true;
          }
          print("error : ${result.exception}\n");
          print("status code: ${result.statusCode}\n");
          return false;
        });
      });

  bool get loginCredentialsSaved => _loginCredentialsSaved;

  List<School> get schools => _schools;

  ApiController get apiController => _apiController;

  RefreshController get refreshController => _refreshController;

  DatabaseController get db => _databaseController;
  List<School> _schools;
  List<ApiPublishSubject> _publishSubjects = List();

  setYearAndSchool(School school, int year) {
    db
      ..school = school
      ..year = year;
  }

  List<School> getSuggestions(String pattern) =>
      _schools
          .where((school) =>
      school.name.startsWith(pattern) ||
          school.id.toString().startsWith(pattern))
          .toList();

  void tryLogin(String username, String password,
      void onComplete(bool success)) {
    db
      ..username = username
      ..password = password;

    _refreshController.loginDB().then((isSuccess) => onComplete(isSuccess));
  }

  tryLoginFromDB(void onComplete(bool success)) {
    tryLogin(db.username, db.password, onComplete);
  }

  Observable<List> getApiData(Api api, {Map data}) {
    if (data == null)
      data = {"overview": false};
    else
      data["overview"] = false;
    return _getData<List>(api, data: data);
  }

  Observable<num> getOverviewData(Api api, {Map data}) {
    if (data == null)
      data = {"overview": true};
    else
      data["overview"] = true;
    return _getData<num>(api, data: data);
  }

  Observable<E> _getData<E>(Api api, {Map data}) {
    ApiPublishSubject subject = _publishSubjects.firstWhere(
            (p) =>
        p.api == api && data.keys.every((key) => data[key] == p.data[key]),
        orElse: () => null);
    if (subject != null) {
      print("subject of api $api was not null");
      Future.delayed(_100ms, () => subject.flush());
      return subject.ps.stream;
    }
    // ignore: close_sinks
    PublishSubject<E> ps = PublishSubject();

    _publishSubjects.add(ApiPublishSubject(ps, api, db.getApiData, data: data));
    refreshController.refresh(api, data: data);
    return ps.stream;
  }

  filterData(Api api, List Function(List items) filter, {Map data}) {
    ApiPublishSubject<List> subject = _publishSubjects.firstWhere(
            (subject) => subject.api == api && subject.data == data,
        orElse: () => null);
    if (subject == null) {
      print(
          "Error: subject with api $api and data $data was not found. Filter was not set.");
      return;
    }
    subject.setFilter(filter);
  }

  bool hasCredentials() => db.hasCredentials();

  dispose() {
    _publishSubjects.forEach((ps) => ps.ps.close());
  }

  logout(BuildContext context) {
    _loggedOut = true;
    db.clearData().then((b) {
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacementNamed(context, "/");
    });
  }

  Widget getDrawer(BuildContext context) =>
      Drawer(
          child: ListView(padding: EdgeInsets.zero, children: <Widget>[
            UserAccountsDrawerHeader(
                accountName: Text(db.displayName),
            accountEmail: Text(db.displayClass),
            currentAccountPicture: getPicture()),
            ListTile(
                title: const Text("בית"),
                onTap: () {
                  closeDrawerAndNavigate(context, "/home");
                }),
            ListTile(
                title: const Text("ציונים"),
                onTap: () {
                  closeDrawerAndNavigate(context, "/grades");
                }),
            ListTile(
                title: const Text("אירועי התנהגות"),
                onTap: () {
                  closeDrawerAndNavigate(context, "/behave");
                }),
            ListTile(
                title: const Text("מערכת שעות"),
                onTap: () {
                  closeDrawerAndNavigate(context, "/timetable");
                }),
            ListTile(
                title: const Text("התנתק/י"),
                onTap: () {
                  bloc.logout(context);
                })
          ]));

  void closeDrawerAndNavigate(BuildContext context, String route) {
    Navigator.pop(context);
//    if (!ModalRoute
//        .of(context)
//        .settings
//        .name
//        .contains(route)) {
//    }
    Navigator.pushNamed(context, route);
  }

  @override
  onSuccess(Api api) {
    _publishSubjects.where((ps) => ps.api == api).forEach((ps) => ps.update());
  }

  @override
  onLogin() {
    _refreshController.refreshAll([Api.Homework, Api.BehaveEvents]);
  }

  //If picture is set, return it. Otherwise, return future builder
  Widget getPicture() =>
      db.pictureSet
          ? decoratePicture(db.profilePicture)
          : FutureBuilder<File>(
        future: apiController.getPicture(db.userId, db.profilePicture),
        builder: (context, snap) {
          return snap.hasData
              ? decoratePicture(db.profilePicture)
              : RefreshProgressIndicator();
        },
      );

  Widget decoratePicture(File picture) =>
      Center(
          child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.fill, image: FileImage(picture)))));

  SimpleDialog createDialog<E>(List<E> data, String itemTitle,
      BuildContext context,
      {TextAlign align}) {
    return SimpleDialog(
      title: Inject.rtl(Text("בחר $itemTitle:", textAlign: TextAlign.center)),
      children: data
          .map((option) =>
          SimpleDialogOption(
              child: Text("$option",
                  textAlign: align, style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.pop(context, option);
              }))
          .toList(),
    );
  }

  Future<E> displayDialog<E>(List<E> data, String title, BuildContext context,
      {TextAlign align: TextAlign.right}) =>
      showDialog<E>(
          context: context,
          builder: (c) => createDialog(data, title, c, align: align))
          .catchError((error) => null);
}

MasterBloc bloc = MasterBloc();
