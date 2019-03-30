import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mashov_api/mashov_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unofficial_mashov/contollers/files_controller.dart';


abstract class DatabaseController {
  //getters
  String get password;

  String get username;

  String get sessionId;

  String get userId;

  String get name;

  String get classCode;

  String get csrfToken;

  String get uniqueId;

  String get mashovSessionId;

  String get profilePicturePath;

  int get year;

  int get classNum;

  School get school;

  set id(String value);

  set password(String value);

  set username(String value);

  set sessionId(String value);

  set userId(String value);

  set name(String value);

  set classCode(String value);

  set csrfToken(String value);

  set uniqueId(String value);

  set mashovSessionId(String value);

  set profilePicturePath(String value);

  set year(int value);

  set classNum(int value);

  set school(School value);

  //getters
  Future<List<Grade>> get grades;

//  Observable<List<Grade>> get grades;

  Future<List<BagrutGrade>> get bagrutGrades;

//  Observable<List<BagrutGrade>> get bagrutGrades;

  Future<List<BehaveEvent>> get behaveEvents;

//  Observable<List<BehaveEvent>> get behaveEvents;

  Future<List<Group>> get groups;

//  Observable<List<Group>> get groups;

  Future<List<Lesson>> get timetable;

//  Observable<List<Lesson>> get timetable;

  Future<List<Contact>> getContacts({int groupId = -1});

//  Observable<List<Contact>> getContacts({int groupId = -1});

  Future<List<MessageTitle>> get conversations;

//  Observable<List<MessageTitle>> get conversations;

  Future<List<Maakav>> get maakavReports;

//  Observable<List<Maakav>> get maakavReports;

  Future<List<Hatama>> get hatamot;

//  Observable<List<Hatama>> get hatamot;

  Future<List<Homework>> get homework;

//  Observable<List<Homework>> get homework;

  Future<Conversation> getConversation(String conversationId);

  Future<bool> hasConversation(String conversationId);

  //setters
  set grades(dynamic grades);

  set bagrutGrades(dynamic bagrutGrades);

  set behaveEvents(dynamic behaveEvents);

  set contacts(dynamic contacts);

  Future<bool> setContactsGroup(dynamic contacts, int groupId);

  set conversations(dynamic conversations);

  void setConversation(dynamic conversation);

  set timetable(dynamic timetable);

  set groups(dynamic groups);

  set maakavReports(dynamic maakav);

  set hatamot(dynamic hatamot);

  set homework(dynamic homework);

  Future<bool> hasEnoughData();

  Future<bool> clearData();

  Future<List> getApiData(Api api, {Map data});

  Future<bool> init();

  setLoginData(Login data);

  bool hasCredentials();
}

class DatabaseControllerImpl implements DatabaseController {
  SharedPreferences _prefs;

  static File _conversationsFile;
  static File _behaveEventsFile;
  static File _contactsFile;
  static File _gradesFile;
  static File _bagrutGradesFile;
  static File _groupsFile;
  static File _timetableFile;
  static File _maakavFile;
  static File _hatamotFile;
  static File _homeworkFile;

  ///Returns true if successful, false otherwise.
  @override
  Future<bool> init() =>
      Future.wait<File>([
        filesController
            .getFile("conversations.json")
            .then((file) => _conversationsFile = file),
        filesController
            .getFile("behave_events.json")
            .then((file) => _behaveEventsFile = file),
        filesController
            .getContactsGroupFile("default")
            .then((file) => _contactsFile = file),
        filesController
            .getFile("grades.json")
            .then((file) => _gradesFile = file),
        filesController
            .getFile("bagrut.json")
            .then((file) => _bagrutGradesFile = file),
        filesController
            .getFile("groups.json")
            .then((file) => _groupsFile = file),
        filesController
            .getFile("timetable.json")
            .then((file) => _timetableFile = file),
        filesController
            .getFile("maakav.json")
            .then((file) => _maakavFile = file),
        filesController
            .getFile("hatamot.json")
            .then((file) => _hatamotFile = file),
        filesController
            .getFile("homework.json")
            .then((file) => _homeworkFile = file),
      ]).then((list) => true).catchError((error) => false);

  DatabaseControllerImpl(SharedPreferences prefs) {
    ///it's easier to get it injected rather than messing it up trying to await it's future.
    _prefs = prefs;
    //make sure prefs will not throw exceptions
    fillPrefs();
  }

  ///prefs:

  ///getters

  String get password => _prefs.getString("password") ?? "";

  String get username => _prefs.getString("username") ?? "";

  String get sessionId => _prefs.getString("sessionId") ?? "";

  String get userId => _prefs.get("userId") ?? "";

  String get name => _prefs.getString("name") ?? "";

  String get classCode => _prefs.getString("classCode") ?? "";

  String get csrfToken => _prefs.getString("csrfToken") ?? "";

  String get uniqueId => _prefs.getString("uniqueId") ?? "";

  String get mashovSessionId => _prefs.getString("mashovSessionId") ?? "";

  String get profilePicturePath => _prefs.getString("profilePicturePath") ?? "";

  School get school {
    String src = _prefs.getString("school") ?? "";
    return src.isNotEmpty ? School.fromJson(json.decode(src)) : null;
  }

  int get year => _prefs.getInt("year") ?? -1;

  int get classNum => _prefs.getInt("classNum") ?? -1;

  ///setters

  set id(String value) => _prefs.setString("id", value);

  set password(String value) => _prefs.setString("password", value);

  set username(String value) => _prefs.setString("username", value);

  set sessionId(String value) => _prefs.setString("sessionId", value);

  set name(String value) => _prefs.setString("name", value);

  set classCode(String value) => _prefs.setString("classCode", value);

  set csrfToken(String value) => _prefs.setString("csrfToken", value);

  set uniqueId(String value) => _prefs.setString("uniqueId", value);

  set mashovSessionId(String value) =>
      _prefs.setString("mashovSessionId", value);

  set profilePicturePath(String value) =>
      _prefs.setString("profilePicturePath", value);

  set year(int value) => _prefs.setInt("year", value);

  set classNum(int value) => _prefs.setInt("classNum", value);

  set school(School value) => _prefs.setString("school", json.encode(value));

  set userId(String value) => _prefs.setString("userId", value);

  ///end prefs

  ///files

  @override
  Future<List<BehaveEvent>> get behaveEvents =>
      _getListFromFile(_behaveEventsFile, BehaveEvent.fromJson);

  @override
  Future<List<Contact>> getContacts({int groupId = -1}) =>
      _getListFromFile(
          groupId == -1
              ? _contactsFile
              : filesController.getContactsGroupFile("$groupId"),
          Contact.fromJson);

  @override
  Future<List<MessageTitle>> get conversations =>
      _getListFromFile(_conversationsFile, MessageTitle.fromJson);

  @override
  Future<List<Group>> get groups =>
      _getListFromFile(_groupsFile, Group.fromJson);

  @override
  Future<List<Grade>> get grades =>
      _getListFromFile(_gradesFile, Grade.fromJson);

  @override
  Future<List<BagrutGrade>> get bagrutGrades =>
      _getListFromFile(_bagrutGradesFile, BagrutGrade.fromJson);

  @override
  Future<List<Lesson>> get timetable =>
      _getListFromFile(_timetableFile, Lesson.fromJson);

  @override
  Future<List<Maakav>> get maakavReports =>
      _getListFromFile(_maakavFile, Maakav.fromJson);

  @override
  Future<List<Hatama>> get hatamot =>
      _getListFromFile(_hatamotFile, Hatama.fromJson);

  @override
  Future<List<Homework>> get homework =>
      _getListFromFile(_homeworkFile, Homework.fromJson);

  @override
  set behaveEvents(dynamic value) {
    try {
      _setFile(_behaveEventsFile, value);
    } catch (e) {
      print("error setting behave events: $e");
      print("data: ${value.join(", ")}");
    }
  }

  @override
  set contacts(dynamic value) => _setFile(_contactsFile, value);

  @override
  set conversations(dynamic value) => _setFile(_conversationsFile, value);

  @override
  set groups(dynamic value) => _setFile(_groupsFile, value);

  @override
  set grades(dynamic value) => _setFile(_gradesFile, value);

  @override
  set bagrutGrades(dynamic value) => _setFile(_bagrutGradesFile, value);

  @override
  set timetable(dynamic json) => _setFile(_timetableFile, json);

  @override
  set maakavReports(dynamic value) => _setFile(_maakavFile, value);

  @override
  set hatamot(dynamic value) => _setFile(_hatamotFile, value);

  @override
  set homework(dynamic value) => _setFile(_homeworkFile, value);

  @override
  setConversation(dynamic conversation) {
    Conversation c = Conversation.fromJson(json.decode(conversation));
    filesController.getConversationFile(c.conversationId).then((file) {
      _setFile(file, conversation);
    });
  }

  @override
  Future<Conversation> getConversation(String conversationId) {
    return filesController.getConversationFile(conversationId).then((file) =>
        _tryRead(file).then((contents) =>
        contents.isNotEmpty
            ? Conversation.fromJson(json.decode(contents))
            : null));
  }

  ///end files

  /// some nice utility functions

  List<E> _parseList<E>(List list, Parser<E> parser) {
    return list.map<E>((item) => parser(item)).toList();
  }

  Future<List<E>> _getListFromFile<E>(File f, Parser<E> parser,
      {bool tried: false}) {
    return f.readAsString().then((contents) {
      print("contents length is ${contents.length} in _getListFromFile");
      return contents.isNotEmpty
          ? _parseList(json.decode(contents), parser)
          : List<E>();
    }).catchError((error) {
      if (tried) {
        print(
            "error getting list from file ${f.path
                .split("/")
                .last}, returning empty list.");
        return List<E>();
      }
      print("error getting list from file ${f.path
          .split("/")
          .last}, trying again.");
      return _getListFromFile(f, parser, tried: true);
    });

//    // because we close it in bloc
//    // ignore: close_sinks
//    PublishSubject<List<E>> fetcher = PublishSubject<List<E>>();
//    f.watch(events: FileSystemEvent.modify).listen((event) {
//      f.readAsString().then((contents) {
//        print("contents length is ${contents.length} in _getListFromFile");
//        fetcher.sink.add(contents.isNotEmpty
//            ? _parseList(json.decode(contents), parser)
//            : List<E>());
//      }).catchError((error) {
//        print(
//            "error getting list from file ${f.path.split("/").last}, returning empty list.");
//      });
//    });
//    return fetcher.stream;
  }

  @override
  Future<bool> hasConversation(String conversationId) =>
      filesController
          .getConversationFile(conversationId)
          .then((file) => file.exists())
          .catchError((error) => false);

  @override
  Future<bool> hasEnoughData() =>
      Future.wait([
        File(profilePicturePath).exists(),
        _timetableFile.exists(),
        _groupsFile.exists(),
        _gradesFile.exists(),
        _bagrutGradesFile.exists(),
        _behaveEventsFile.exists(),
        _maakavFile.exists(),
        _conversationsFile.exists()
      ]).then((areExisting) => _all(areExisting));

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
  }

  Future<bool> _setFile(File f, String value) async {
    print(
        "set file is called with file ${f.path
            .split("/")
            .last}, value $value");
    return f
        .writeAsString((value == null || value.isEmpty) ? "" : value)
        .then((file) => true)
        .catchError((error) => false);
  }

  @override
  Future<bool> setContactsGroup(dynamic contacts, int groupId) async =>
      filesController
          .getContactsGroupFile("$groupId")
          .then((file) => _setFile(file, contacts))
          .catchError((error) => false);

  @override
  Future<bool> clearData() async =>
      filesController
          .clear()
          .then((isSuccessful) =>
      isSuccessful ? _prefs.clear() : Future.value(false))
          .catchError((error) {
        print(error);
        return false;
      });

  @override
  setLoginData(Login data) {
    userId = data.data.userId;
    sessionId = data.data.sessionId;
    year = data.data.year;
  }

  @override
  Future<List> getApiData(Api api, {Map data}) {
    switch (api) {
      case Api.Homework:
        return homework;
      case Api.Grades:
        return grades;
      case Api.Groups:
        return groups;
      case Api.Timetable:
        return timetable;
      case Api.Alfon:
        if (data != null) if (data.containsKey("groupId"))
          return getContacts(groupId: data["groupId"]);
        return getContacts();
      case Api.BagrutGrades:
        return bagrutGrades;
      case Api.BehaveEvents:
        return behaveEvents;
      case Api.Messages:
      //TODO: older messages handling(?)
        return conversations;
      case Api.Maakav:
        return maakavReports;
      case Api.Hatamot:
        return hatamot;
      default:
        print(
            "error: trying to get list api ${api
                .toString()} $api. returning grades");
        return grades;
    }
  }

  Future<String> _tryRead(File f) async {
    try {
      return await f.readAsString();
    } catch (e) {
      print(e);
      return "";
    }
  }

  bool _all(List<bool> booleans) => booleans.every((bool) => bool);

  @override
  bool hasCredentials() =>
      username.isNotEmpty && password.isNotEmpty && school != null && year != 0;
}
