import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mashov_api/mashov_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unofficial_mashov/contollers/files_controller.dart';

class DatabaseController {
  SharedPreferences _prefs;

  String get password => _prefs.getString("password") ?? "";

  String get username => _prefs.getString("username") ?? "";

  String get sessionId => _prefs.getString("sessionId") ?? "";

  String get userId => _prefs.get("userId") ?? "";

  String get privateName => _prefs.getString("privateName") ?? "";

  String get familyName => _prefs.getString("familyName") ?? "";

  String get displayName => "$privateName $familyName";

  String get displayClass => "$classCode\'$classNum";

  String get csrfToken => _prefs.getString("csrfToken") ?? "";

  String get uniqueId => _prefs.getString("uniqueId") ?? "";

  String get mashovSessionId => _prefs.getString("mashovSessionId") ?? "";

  String get profilePicturePath => filesController.picturePath;

  File get profilePicture =>
      profilePicturePath != null ? filesController.pictureFile : null;

  bool get pictureSet => _prefs.getBool("pictureSet") ?? false;

  School get school {
    String src = _prefs.getString("school") ?? "";
    return src.isNotEmpty ? School.fromJson(json.decode(src)) : null;
  }

  int get year => _prefs.getInt("year") ?? -1;

  String get classCode => _prefs.getString("classCode");

  String get classNum => _prefs.getString("classNum");

  String get classFormatted => "$classCode\'$classNum";

  MessagesCount get messagesCount {
    String value = _prefs.getString("messagesCount");
    if (value == null || value.isEmpty) return null;
    return MessagesCount.fromJson(
        json.decode(_prefs.getString("messagesCount")));
  }

  set id(String value) => _prefs.setString("id", value);

  set password(String value) => _prefs.setString("password", value);

  set username(String value) => _prefs.setString("username", value);

  set sessionId(String value) => _prefs.setString("sessionId", value);

  set privateName(String value) => _prefs.setString("privateName", value);

  set familyName(String value) => _prefs.setString("familyName", value);

  set csrfToken(String value) => _prefs.setString("csrfToken", value);

  set uniqueId(String value) => _prefs.setString("uniqueId", value);

  set mashovSessionId(String value) =>
      _prefs.setString("mashovSessionId", value);

  set profilePicturePath(String value) =>
      _prefs.setString("profilePicturePath", value);

  set year(int value) => _prefs.setInt("year", value);

  set school(School value) => _prefs.setString("school", json.encode(value));

  set userId(String value) => _prefs.setString("userId", value);

  set classCode(String value) => _prefs.setString("classCode", value);

  set classNum(String value) => _prefs.setString("classNum", value);

  String _countToJson(MessagesCount value) => """{
    "allMessages": ${value.allMessages},
    "inboxMessages": ${value.inboxMessages},
    "newMessages": ${value.newMessages},
    "unreadMessages": ${value.unreadMessages}
  }""";

  set messagesCount(MessagesCount value) =>
      _prefs.setString("messagesCount", _countToJson(value));

  DatabaseController(SharedPreferences prefs) {
    ///it's easier to get it injected rather than messing it up trying to await it's future.
    _prefs = prefs;
    //make sure prefs will not throw exceptions
    fillPrefs();
  }

  /// some nice utility functions

  Future<bool> hasEnoughData() => File(profilePicturePath).exists();

  void fillPrefsWithEmptyStrings() {
    const keys = [
      "id",
      "password",
      "username",
      "sessionId",
      "userId",
      "name",
      "classCode",
      "csrfToken",
      "uniqueId",
      "mashovSessionId",
      "profilePicturePath"
    ];
    var pKeys = _prefs.getKeys();
    keys.forEach((key) {
      if (!pKeys.contains(key)) {
        _prefs.setString(key, "");
      }
    });
  }

  void fillPrefWithEmptyIntegers() {
    const keys = ["year", "classNum"];
    var pKeys = _prefs.getKeys();
    keys.forEach((key) {
      if (!pKeys.contains(key)) {
        _prefs.setInt(key, -1);
      }
    });
  }

  void fillPrefs() {
    fillPrefWithEmptyIntegers();
    fillPrefsWithEmptyStrings();
    if (!_prefs.getKeys().contains("school")) {
      _prefs.setString("school", "");
    }
    if (!_prefs.getKeys().contains("pictureSet")) {
      _prefs.setBool("pictureSet", false);
    }
  }

  Future<bool> clearData() async =>
      filesController
          .clear()
          .then((isSuccessful) =>
      isSuccessful ? _prefs.clear() : Future.value(false))
          .catchError((error) {
        print(error);
        return false;
      });

  setLoginData(Login data) {
    userId = data.data.userId;
    sessionId = data.data.sessionId;
    year = data.data.year;
  }

  bool hasCredentials() =>
      username.isNotEmpty && password.isNotEmpty && school != null && year != 0;
}
