import 'dart:convert';
import 'dart:io';

import 'package:mashov_api/mashov_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unofficial_mashov/contollers/files_controller.dart';

abstract class DatabaseController {
  /*String _id;
  String _password;
  String _username;
  String _sessionId;
  String _name;
  String _classCode;
  String _csrfToken;
  String _uniqueId;
  String _mashovSessionId;
  String _profilePicturePath;
  */
  //getters
  String get id;

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
  List<Grade> get grades;

  List<BagrutGrade> get bagrutGrades;

  List<BehaveEvent> get behaveEvents;

  List<Group> get groups;

  List<Lesson> get timetable;

  List<Contact> getContacts({int groupId = -1});

  List<MessageTitle> get conversations;

  List<Maakav> get maakavReports;

  List<Hatama> get hatamot;

  List<Homework> get homework;

  Future<Conversation> getConversation(String conversationId);

  Future<bool> hasConversation(String conversationId);

  //setters
  set grades(List<Grade> grades);

  set bagrutGrades(List<BagrutGrade> bagrutGrades);

  set behaveEvents(List<BehaveEvent> behaveEvents);

  set contacts(List<Contact> contacts);

  Future<bool> setContactsGroup(List<Contact> contacts, int groupId);

  set conversations(List<MessageTitle> conversations);

  void setConversation(Conversation conversation);

  set timetable(List<Lesson> timetable);

  set groups(List<Group> groups);

  set maakavReports(List<Maakav> maakav);

  set hatamot(List<Hatama> hatamot);

  set homework(List<Homework> homework);

  Future<bool> hasEnoughData();

  clearData();

  List getApiData(Api api, {Map data});

  Future<bool> init();

  setLoginData(Login data);
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

  String get id => _prefs.getString("id");

  String get password => _prefs.getString("password");

  String get username => _prefs.getString("username");

  String get sessionId => _prefs.getString("sessionId");

  String get userId => _prefs.get("userId");

  String get name => _prefs.getString("name");

  String get classCode => _prefs.getString("classCode");

  String get csrfToken => _prefs.getString("csrfToken");

  String get uniqueId => _prefs.getString("uniqueId");

  String get mashovSessionId => _prefs.getString("mashovSessionId");

  String get profilePicturePath => _prefs.getString("profilePicturePath");

  School get school {
    String src = _prefs.getString("school");
    if (src.isEmpty) return null;
    return School.fromJson(json.decode(src));
  }

  int get year => _prefs.getInt("year");

  int get classNum => _prefs.getInt("classNum");

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
  List<BehaveEvent> get behaveEvents =>
      _getListFromFile(_behaveEventsFile, BehaveEvent.fromJson);

  @override
  List<Contact> getContacts({int groupId = -1}) =>
      _getListFromFile(
          groupId == -1
              ? _contactsFile
              : filesController.getContactsGroupFile("$groupId"),
          Contact.fromJson);

  @override
  List<MessageTitle> get conversations =>
      _getListFromFile(_conversationsFile, MessageTitle.fromJson);

  @override
  List<Group> get groups => _getListFromFile(_groupsFile, Group.fromJson);

  @override
  List<Grade> get grades => _getListFromFile(_gradesFile, Grade.fromJson);

  @override
  List<BagrutGrade> get bagrutGrades =>
      _getListFromFile(_bagrutGradesFile, BagrutGrade.fromJson);

  @override
  List<Lesson> get timetable =>
      _getListFromFile(_timetableFile, Lesson.fromJson);

  @override
  List<Maakav> get maakavReports =>
      _getListFromFile(_maakavFile, Maakav.fromJson);

  @override
  List<Hatama> get hatamot => _getListFromFile(_hatamotFile, Hatama.fromJson);

  @override
  List<Homework> get homework =>
      _getListFromFile(_homeworkFile, Homework.fromJson);

  @override
  set behaveEvents(List<BehaveEvent> value) =>
      _setFile(_behaveEventsFile, json.encode(value));

  @override
  set contacts(List<Contact> value) =>
      _setFile(_contactsFile, json.encode(value));

  @override
  set conversations(List<MessageTitle> value) =>
      _setFile(_conversationsFile, json.encode(value));

  @override
  set groups(List<Group> value) => _setFile(_groupsFile, json.encode(value));

  @override
  set grades(List<Grade> value) => _setFile(_gradesFile, json.encode(value));

  @override
  set bagrutGrades(List<BagrutGrade> value) =>
      _setFile(_bagrutGradesFile, json.encode(value));

  @override
  set timetable(List<Lesson> value) =>
      _setFile(_timetableFile, json.encode(value));

  @override
  set maakavReports(List<Maakav> value) =>
      _setFile(_maakavFile, json.encode(value));

  @override
  set hatamot(List<Hatama> value) => _setFile(_hatamotFile, json.encode(value));

  @override
  set homework(List<Homework> value) =>
      _setFile(_homeworkFile, json.encode(value));

  @override
  setConversation(Conversation conversation) {
    filesController
        .getConversationFile(conversation.conversationId)
        .then((file) {
      _setFile(file, json.encode(conversation));
    }).then((n) => true);
  }

  @override
  Future<Conversation> getConversation(String conversationId) async {
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

  List<E> _getListFromFile<E>(File f, Parser<E> parser) {
    String contents = f.readAsStringSync();
    return contents.isNotEmpty
        ? _parseList(json.decode(contents), parser)
        : List();
//    return _tryRead(f).then((contents) => contents.isNotEmpty
//          ? _parseList(json.decode(contents), parser)
//          : null);
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

  Future<bool> _setFile(File f, String value) async =>
      f
          .writeAsString((value == null || value.isEmpty) ? "" : value)
          .then((file) => true)
          .catchError((error) => false);

  @override
  Future<bool> setContactsGroup(List<Contact> contacts, int groupId) async =>
      filesController
          .getContactsGroupFile("$groupId")
          .then((file) => _setFile(file, json.encode(contacts)))
          .catchError((error) => false);

  @override
  void clearData() {
    filesController.clear();
    _prefs.clear();
    fillPrefs();
  }

  @override
  setLoginData(Login data) {
    userId = data.data.userId;
    sessionId = data.data.sessionId;
    year = data.data.year;
  }

  @override
  List getApiData(Api api, {Map data}) {
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
}
