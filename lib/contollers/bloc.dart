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

typedef Future<List> Updater(Api api, {Map data});

class MasterBloc extends Callback {
  ApiController _apiController = MashovApi.getController();
  DatabaseController _databaseController;
  RefreshController _refreshController;
  bool _loginCredentialsSaved = false;
  bool _loggedOut = false;

  MessagesCount _count;

  Future<MessagesCount> getMessagesCount() =>
      Future(() {
        return _count != null
            ? _count
            : _apiController.getMessagesCount().then((r) => r.value);
      });

  Future<num> getNewMessagesCount() =>
      getMessagesCount().then((count) => count.newMessages);

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
    /*print("tryLogin is called:\n");
    print("school id ${db.school.id}");
    print("year: ${db.year}");
    print("username: $username");
    print("password: $password");*/
    apiController.login(db.school, username, password, db.year).then((loginR) {
      if (loginR.isSuccess) {
        //save login info for next login
        //and save session's data
        LoginData data = loginR.value.data;
        Student student = loginR.value.students.first;
        db
          ..username = username
          ..password = password
          ..sessionId = data.sessionId
          ..userId = data.userId
          ..classCode = student.classCode
          ..classNum = student.classNum.toString()
          ..privateName = student.privateName
          ..familyName = student.familyName;
        //might want to refresh these stuff from here in the future:
//        Inject.refreshController.refreshAll(
//            [Api.Grades, Api.Homework, Api.Timetable, Api.BehaveEvents]);
      } else {
        print("result.exception = ${loginR.exception}\n");
        NoSuchMethodError error = loginR.exception as NoSuchMethodError;
        print("error: ${error.stackTrace}");
        print("${loginR.exception.runtimeType}\n");
        print("status code: ${loginR.statusCode}");
      }
      onComplete(loginR.isSuccess);
    });
  }

  tryLoginFromDB(void onComplete(bool success)) {
    tryLogin(db.username, db.password, onComplete);
  }

  Observable<List> getApiData(Api api, {Map data}) {
    print("Get api data is called with api $api");
    ApiPublishSubject subject = _publishSubjects
        .firstWhere((p) => p.api == api && p.data == data, orElse: () => null);
    if (subject != null) {
      print("subject was not null\n");
      Future.delayed(Duration(milliseconds: 100), () => subject.flush());
      return subject.ps.stream;
    }
    // ignore: close_sinks
    PublishSubject<List> ps = PublishSubject();
    _publishSubjects.add(ApiPublishSubject(ps, api, db.getApiData, data: data));
    refreshController.refresh(api, data: data);
    return ps.stream;
  }

  filterData(Api api, List Function(List items) filter, {Map data}) {
    ApiPublishSubject subject = _publishSubjects
        .firstWhere((subject) => subject.api == api && subject.data == data);
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
                title: const Text("התנתק/י"),
                onTap: () {
                  bloc.logout(context);
        })
      ]));

  void closeDrawerAndNavigate(BuildContext context, String route) {
    Navigator.pop(context);
    Navigator.pushNamed(context, route);
  }

  @override
  onSuccess(Api api) {
    _publishSubjects.where((ps) => ps.api == api).forEach((ps) => ps.update());
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
}


MasterBloc bloc = MasterBloc();
