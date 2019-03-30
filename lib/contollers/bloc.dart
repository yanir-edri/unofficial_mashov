import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
          _databaseController = DatabaseControllerImpl(prefs);
          _refreshController = RefreshController();
          _refreshController.attach(this);
          return filesController.initStorage();
        })
            .then((n) => _databaseController.init())
            .then((successful) =>
        !successful
            ? false
            : _apiController.getSchools().then((result) {
          if (result.isSuccess) {
            _schools = result.value;
            return true;
          }
          return false;
        }));
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
    apiController
        .login(db.school, username, password,
        db.year)
        .then((loginR) {
      if (loginR.isSuccess) {
        //save login info for next login
        //and save session's data
        LoginData data = loginR.value.data;
        db
          ..username = username
          ..password = password
          ..sessionId = data.sessionId
          ..userId = data.userId;
        //might want to refresh these stuff from here in the future:
//        Inject.refreshController.refreshAll(
//            [Api.Grades, Api.Homework, Api.Timetable, Api.BehaveEvents]);

      }
      onComplete(loginR.isSuccess);
    });
  }

  tryLoginFromDB(void onComplete(bool success)) {
    tryLogin(db.username, db.password, onComplete);
  }

  Observable<List> getApiData(Api api, {Map data}) {
    print("Get api data is called with api $api");

    // ignore: close_sinks
    PublishSubject<List> ps = PublishSubject();
    refreshController.refresh(api, data: data);
    _publishSubjects.add(ApiPublishSubject(ps, api, db
        .getApiData, data: data));
    return ps.stream;
  }

  bool hasCredentials() => db.hasCredentials();

  dispose() {
    _publishSubjects.forEach((ps) => ps.ps.close());
  }

  logout(BuildContext context) {
    _loggedOut = true;
    db.clearData().then((b) {
      Navigator.pushReplacementNamed(context, "/");
    });
  }

  @override
  onSuccess(Api api) {
    _publishSubjects.where((ps) => ps.api == api).forEach((ps) => ps.update());
  }
}

class ApiPublishSubject {
  final Api api;
  final Map data;
  final PublishSubject<List> ps;
  final Updater updater;

  update() {
    print("update is called");
    updater(api, data: data).then((list) => ps.sink.add(list));
  }

  ApiPublishSubject(this.ps, this.api, this.updater, {this.data}) {
    update();
  }
}

MasterBloc bloc = MasterBloc();

