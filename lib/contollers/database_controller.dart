import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mashov_api/mashov_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unofficial_mashov/contollers/files_controller.dart';
import 'package:unofficial_mashov/contollers/refresh_controller.dart';

class DatabaseController extends Callback {
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



  Future<List<BehaveEvent>> get behaveEvents =>
      _getListFromFile(_behaveEventsFile, BehaveEvent.fromJson).then((l) {
        l.sort((event1, event2) => event1.date.compareTo(event2.date));
        return l;
      });

  Future<List<Contact>> getContacts({int groupId = -1}) =>
      _getListFromFile(
          groupId == -1
              ? _contactsFile
              : filesController.getContactsGroupFile("$groupId"),
          Contact.fromJson)
          .then((l) {
        l.sort((o1, o2) => o1.name.compareTo(o2.name));
        return l;
      });

  Future<List<MessageTitle>> get conversations =>
      _getListFromFile(_conversationsFile, MessageTitle.fromJson).then((l) {
        l.sort((o1, o2) => o2.sendDate.compareTo(o1.sendDate));
        return l;
      });

  Future<List<Group>> get groups =>
      _getListFromFile(_groupsFile, Group.fromJson).then((l) {
        l.sort((o1, o2) => o1.subject.compareTo(o2.subject));
        return l;
      });

  Future<List<Grade>> get grades =>
      _getListFromFile(_gradesFile, Grade.fromJson).then((l) {
        l.sort((o1, o2) => o2.eventDate.compareTo(o1.eventDate));
        return l;
      });

  Future<List<BagrutGrade>> get bagrutGrades =>
      _getListFromFile(_bagrutGradesFile, BagrutGrade.fromJson).then((l) {
        l.sort((o1, o2) => o2.date.compareTo(o1.date));
        return l;
      });

  Future<List<Lesson>> get timetable =>
      _getListFromFile(_timetableFile, Lesson.fromJson);

  Future<List<Maakav>> get maakavReports =>
      _getListFromFile(_maakavFile, Maakav.fromJson).then((l) {
        l.sort((o1, o2) => o2.date.compareTo(o1.date));
        return l;
      });

  Future<List<Hatama>> get hatamot =>
      _getListFromFile(_hatamotFile, Hatama.fromJson).then((l) {
        l.sort((o1, o2) => o1.name.compareTo(o2.name));
        return l;
      });

  Future<List<Homework>> get homework =>
      _getListFromFile(_homeworkFile, Homework.fromJson).then((l) {
        l.sort((o1, o2) => o1.date.compareTo(o2.date));
        return l;
      });

  set behaveEvents(dynamic value) {
    try {
      _setFile(_behaveEventsFile, value);
    } catch (e) {
      print("error setting behave events: $e");
      print("data: ${value.join(", ")}");
    }
  }

  set contacts(dynamic value) => _setFile(_contactsFile, value);

  set conversations(dynamic value) => _setFile(_conversationsFile, value);

  set groups(dynamic value) => _setFile(_groupsFile, value);

  set grades(dynamic value) => _setFile(_gradesFile, value);

  set bagrutGrades(dynamic value) => _setFile(_bagrutGradesFile, value);

  set timetable(dynamic json) => _setFile(_timetableFile, json);

  set maakavReports(dynamic value) => _setFile(_maakavFile, value);

  set hatamot(dynamic value) => _setFile(_hatamotFile, value);

  set homework(dynamic value) => _setFile(_homeworkFile, value);

  setConversation(dynamic conversation) {
    Conversation c = Conversation.fromJson(json.decode(conversation));
    filesController.getConversationFile(c.conversationId).then((file) {
      _setFile(file, conversation);
    });
  }

  Future<Conversation> getConversation(String conversationId) {
    return filesController.getConversationFile(conversationId).then((file) =>
        _tryRead(file).then((contents) =>
        contents.isNotEmpty
            ? Conversation.fromJson(json.decode(contents))
            : null));
  }


  ///Returns true if successful, false otherwise.
  Future<bool> init() {
    List<Future> futures = [
      filesController
          .getFile("conversations.json")
          .then((file) => _conversationsFile = file),
      filesController
          .getFile("behave_events.json")
          .then((file) => _behaveEventsFile = file),
      filesController
          .getContactsGroupFile("default")
          .then((file) => _contactsFile = file),
      filesController.getFile("grades.json").then((file) => _gradesFile = file),
      filesController
          .getFile("bagrut.json")
          .then((file) => _bagrutGradesFile = file),
      filesController.getFile("groups.json").then((file) => _groupsFile = file),
      filesController
          .getFile("timetable.json")
          .then((file) => _timetableFile = file),
      filesController.getFile("maakav.json").then((file) => _maakavFile = file),
      filesController
          .getFile("hatamot.json")
          .then((file) => _hatamotFile = file),
      filesController
          .getFile("homework.json")
          .then((file) => _homeworkFile = file),
    ];
    return Future.wait(futures).then((l) => true).catchError((error) {
      print(error);
      return false;
    });
  }


  DatabaseController(SharedPreferences prefs) {
    ///it's easier to get it injected rather than messing it up trying to await it's future.
    _prefs = prefs;
    //make sure prefs will not throw exceptions
    fillPrefs();
  }

  ///prefs:



  /// some nice utility functions

  List<E> _parseList<E>(List list, Parser<E> parser) {
    return list.map<E>((item) => parser(item)).toList();
  }

  Future<List<E>> _getListFromFile<E>(File f, Parser<E> parser,
      {bool tried: false}) {
    return f.readAsString().then((contents) {
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
      print(
          "error getting list from file ${f.path
              .split("/")
              .last}, trying again.");
      return _getListFromFile(f, parser, tried: true);
    });
  }

  Future<bool> hasConversation(String conversationId) =>
      filesController
          .getConversationFile(conversationId)
          .then((file) => file.exists())
          .catchError((error) => false);

  Future<num> getAverage() =>
      grades.then((grades) {
        if (grades.isEmpty) {
          return 0;
        } else {
          Iterable<int> gradesNum = grades.where((g) => g.grade != 0).map((
              g) => g.grade);
          int len = gradesNum.length;
          return gradesNum.reduce((n1, n2) => n1 + n2) / len;
        }
      });


  Future<int> todayLessonsCount() {
    int today = DateTime
        .now()
        .weekday;
    today = today == 7 ? 1 : today + 1;
    return timetable.then(
            (lessons) =>
        lessons.isEmpty ? 0 :
        lessons
            .where((lesson) => lesson.day == today)
            .length);
  }
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
    if (!_prefs.getKeys().contains("pictureSet")) {
      _prefs.setBool("pictureSet", false);
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

  Future<bool> setContactsGroup(dynamic contacts, int groupId) async =>
      filesController
          .getContactsGroupFile("$groupId")
          .then((file) => _setFile(file, contacts))
          .catchError((error) => false);

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

  Future getApiData(Api api, {Map data}) {
    if (data["overview"]) {
      switch (api) {
//        case Api.Homework:
//          return homework;
        case Api.MessagesCount:
          if (messagesCount != null) {
            return Future.value(messagesCount.newMessages);
          } else {
            return Future.value(0);
          }
          break;
        case Api.Grades:
          if (data.containsKey("amount")) {
            return grades.then((grades) => grades.length);
          }
          return grades.then((grades) {
            if (grades.isEmpty) {
              return 0;
            } else {
              Iterable<int> gradesNum = grades /*.where((g) => g.grade != 0)*/
                  .map((g) => g.grade);
              int len = gradesNum.length;
              return gradesNum.reduce((n1, n2) => n1 + n2) / len;
            }
          });
//        case Api.Groups:
//          return groups;
        case Api.Timetable:
        //returns today's lessons count
          int today = DateTime
              .now()
              .weekday;
          today = today == 7 ? 1 : today + 1;
          return timetable.then(
                  (lessons) =>
              lessons.isEmpty ? 0 :
              lessons
                  .where((lesson) => lesson.day == today)
                  .length);
//        case Api.Alfon:
//          if (data != null) if (data.containsKey("groupId"))
//            return getContacts(groupId: data["groupId"]);
//          return getContacts();
        case Api.BagrutGrades:
        //just like grades
          if (data.containsKey("amount")) {
            return grades.then((grades) => grades.length);
          }
          return grades.then((grades) {
            if (grades.isEmpty) {
              return 0;
            } else {
              Iterable<int> gradesNum = grades /*.where((g) => g.grade != 0)*/
                  .map((g) => g.grade);
              int len = gradesNum.length;
              return gradesNum.reduce((n1, n2) => n1 + n2) / len;
            }
          });
        case Api.BehaveEvents:
        //justified/un-justified
          if (data.containsKey("justified")) {
            return behaveEvents.then((events) =>
            events
                .where((e) => e.justificationId != 0)
                .length);
          } else {
            return behaveEvents.then((events) =>
            events
                .where((e) => e.justificationId == 0)
                .length);
          }
          break;
//        case Api.Messages:
//          return conversations;
//        case Api.Maakav:
//          return maakavReports;
//        case Api.Hatamot:
//          return hatamot;
//          break;
        default:
          print(
              "error: trying to get overview of api $api. returning -1");
          return Future.value(-1);
      }
    } else {
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
          break;
        default:
          print(
              "error: trying to get list api ${api
                  .toString()} $api. returning grades");
          return grades;
      }
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

  bool hasCredentials() =>
      username.isNotEmpty && password.isNotEmpty && school != null && year != 0;
}
