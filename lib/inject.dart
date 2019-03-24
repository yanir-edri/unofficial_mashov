import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unofficial_mashov/contollers/database_controller.dart';
import 'package:unofficial_mashov/contollers/files_controller.dart';
import 'package:unofficial_mashov/contollers/refresh_controller.dart';

class Inject {
  static ApiController _apiController = MashovApi.getController();
  static DatabaseController _databaseController;
  static RefreshController _refreshController;
  static List<School> _schools = List();

  static Future<bool> isConnected() =>
      Connectivity()
          .checkConnectivity()
          .then((result) => result != ConnectivityResult.none)
          .catchError((error) => false);

  static Future<bool> setup() {
    return isConnected().then((connected) {
      print("is connected equals $connected");
      if (!connected) return false;

      return SharedPreferences.getInstance()
          .then((prefs) {
        _databaseController = DatabaseControllerImpl(prefs);
        _refreshController = RefreshController();
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
  }

  static List<School> get schools => _schools;

  static ApiController get apiController => _apiController;

  static DatabaseController get databaseController => _databaseController;

  static RefreshController get refreshController => _refreshController;

  //Wraps a widget with RTL directionality.
  static Widget rtl(Widget w) =>
      Directionality(textDirection: TextDirection.rtl, child: w);

  static Widget wrapper(Widget w) {
    return rtl(
        Scaffold(
            appBar: AppBar(title: Text("התחברות למשוב"), centerTitle: true),
            body: Container(margin: EdgeInsets.all(16.0), child: w)
        )
    );
  }
}
