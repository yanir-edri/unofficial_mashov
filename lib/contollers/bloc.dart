import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unofficial_mashov/contollers/database_controller.dart';
import 'package:unofficial_mashov/contollers/refresh_controller.dart';
import 'package:unofficial_mashov/inject.dart';

typedef Future<List> Updater(Api api, {Map data});

class MasterBloc extends Callback {
  DatabaseController get db => Inject.databaseController;
  List<School> _schools;
  List<ApiPublishSubject> _publishSubjects = List();

  MasterBloc() {
    Inject.refreshController.attach(this);
  }

  setYearAndSchool(School school, int year) {
    Inject.databaseController
      ..school = school
      ..year = year;
  }

  List<School> getSuggestions(String pattern) {
    if (_schools == null) {
      _schools = Inject.schools;
    }
    return _schools
        .where((school) =>
    school.name.startsWith(pattern) ||
        school.id.toString().startsWith(pattern))
        .toList();
  }

  void tryLogin(String username, String password,
      void onComplete(bool success)) {
    Inject.apiController
        .login(Inject.databaseController.school, username, password,
        Inject.databaseController.year)
        .then((loginR) {
      if (loginR.isSuccess) {
        //save login info for next login
        Inject.databaseController
          ..username = username
          ..password = password;
        //save session's data
        LoginData data = loginR.value.data;
        Inject.databaseController
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
    Inject.refreshController.refresh(api, data: data);
    _publishSubjects.add(ApiPublishSubject(ps, api, Inject.databaseController
        .getApiData, data: data));
    return ps.stream;
  }

  bool hasCredentials() => Inject.databaseController.hasCredentials();

  dispose() {
    _publishSubjects.forEach((ps) => ps.ps.close());
  }

  logout(BuildContext context) {
    db.clearData();
    Navigator.pushReplacementNamed(context, "/");
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
