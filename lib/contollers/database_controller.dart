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

  List<BehaveEvent> get behaveEvents;

  List<Group> get groups;

  List<Lesson> get timetable;

  List<Contact> get contacts;

  List<MessageTitle> get conversations;

  List<Maakav> get maakavReports;

  List<Hatama> get hatamot;

  List<Homework> get homework;

  Conversation getConversation(String conversationId);

  bool hasConversation(String conversationId);

  //setters
  set grades(List<Grade> grades);

  set behaveEvents(List<BehaveEvent> behaveEvents);

  set contacts(List<Contact> contacts);

  void setContactsGroup(List<Contact> contacts, int groupId);

  set conversations(List<MessageTitle> conversations);

  set conversation(Conversation conversation);

  set timetable(List<Lesson> timetable);

  set groups(List<Group> groups);

  set maakavReports(List<Maakav> maakav);

  set hatamot(List<Hatama> hatamot);

  set homework(List<Homework> homework);

  bool hasEnoughData();

  clearData();


  setLoginData(Login data);
}

class DatabaseControllerImpl implements DatabaseController {
  SharedPreferences _prefs;

  static File _conversationsFile =
      filesController.getFile("conversations.json");
  static File _behaveEventsFile = filesController.getFile("behave_events.json");
  static File _contactsFile = filesController.getContactsGroupFile("default");
  static File _gradesFile = filesController.getFile("grades.json");
  static File _groupsFile = filesController.getFile("grades.json");
  static File _timetableFile = filesController.getFile("grades.json");
  static File _maakavFile = filesController.getFile("maakav.json");
  static File _hatamotFile = filesController.getFile("hatamot.json");
  static File _homeworkFile = filesController.getFile("homework.json");

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
  List<Contact> get contacts =>
      _getListFromFile(_contactsFile, Contact.fromJson);

  @override
  List<MessageTitle> get conversations =>
      _getListFromFile(_conversationsFile, MessageTitle.fromJson);

  @override
  List<Group> get groups => _getListFromFile(_groupsFile, Group.fromJson);

  @override
  List<Grade> get grades => _getListFromFile(_gradesFile, Grade.fromJson);

  @override
  List<Lesson> get timetable =>
      _getListFromFile(_timetableFile, Lesson.fromJson);

  @override
  List<Maakav> get maakavReports =>
      _getListFromFile(_maakavFile, Maakav.fromJson);

  @override
  List<Hatama> get hatamot =>
      _getListFromFile(_hatamotFile, Hatama.fromJson);

  @override
  List<Homework> get homework =>
      _getListFromFile(_homeworkFile, Homework.fromJson);

  @override
  set behaveEvents(List<BehaveEvent> value) =>
      setFile(_behaveEventsFile, json.encode(value));

  @override
  set contacts(List<Contact> value) =>
      setFile(_contactsFile, json.encode(value));

  @override
  set conversations(List<MessageTitle> value) =>
      setFile(_conversationsFile, json.encode(value));

  @override
  set groups(List<Group> value) => setFile(_groupsFile, json.encode(value));

  @override
  set grades(List<Grade> value) => setFile(_gradesFile, json.encode(value));

  @override
  set timetable(List<Lesson> value) =>
      setFile(_timetableFile, json.encode(value));

  @override
  set maakavReports(List<Maakav> value) =>
      setFile(_maakavFile, json.encode(value));

  @override
  set hatamot(List<Hatama> value) =>
      setFile(_hatamotFile, json.encode(value));

  @override
  set homework(List<Homework> value) =>
      setFile(_homeworkFile, json.encode(value));

  @override
  set conversation(Conversation conversation) {
    File conversationFile =
        filesController.getConversationFile(conversation.conversationId);
    setFile(conversationFile, json.encode(conversation));
  }

  @override
  Conversation getConversation(String conversationId) {
    File conversationFile = filesController.getConversationFile(conversationId);
    String contents = conversationFile.readAsStringSync();
    if (contents.isEmpty) return null;
    return Conversation.fromJson(json.decode(contents));
  }

  ///end files

  /// some nice utility functions

  List<E> _parseList<E>(List list, Parser<E> parser) {
    return list.map<E>((item) => parser(item)).toList();
  }

  List<E> _getListFromFile<E>(File f, Parser<E> parser) {
    String contents = f.readAsStringSync();
    return contents.isEmpty ? null : _parseList(json.decode(contents), parser);
  }

  @override
  bool hasConversation(String conversationId) =>
      filesController.getConversationFile(conversationId).existsSync();

  @override
  bool hasEnoughData() =>
      File(profilePicturePath).existsSync() &&
      _timetableFile.existsSync() &&
      _groupsFile.existsSync() &&
      _gradesFile.existsSync() &&
      _behaveEventsFile.existsSync() &&
          _maakavFile.existsSync() &&
      _conversationsFile.existsSync();

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

  void setFile(File f, String value) {
    if (value == null || value.isEmpty)
      f.writeAsStringSync("");
    else
      f.writeAsStringSync(value);
  }

  @override
  void setContactsGroup(List<Contact> contacts, int groupId) {
    File contactsFile = filesController.getContactsGroupFile("$groupId");
    setFile(contactsFile, json.encode(contacts));
  }

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

}
