import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:unofficial_mashov/providers/api_provider.dart';

import 'contollers/database_controller.dart';
import 'contollers/files_controller.dart';
import 'contollers/refresh_controller.dart';

typedef Builder = Widget Function(BuildContext context, dynamic item);

class Inject {
  static ApiController _apiController = MashovApi.getController();
  static DatabaseController _databaseController;
  static RefreshController _refreshController;
  static bool _loginCredentialsSaved = false;
  static bool _loggedOut = false;

  static Future<bool> isConnected() =>
      Connectivity()
          .checkConnectivity()
          .then((result) => result != ConnectivityResult.none)
          .catchError((error) => false);

  static Future<bool> setup() =>
      isConnected().then((connected) {
        print("is connected equals $connected");
        if (!connected) return false;
        if (_loggedOut) return Future.value(true);
        return SharedPreferences.getInstance()
            .then((prefs) {
          _databaseController = DatabaseController(prefs);
          _refreshController = RefreshController();
          return filesController.initStorage();
        })
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

  static bool get loginCredentialsSaved => _loginCredentialsSaved;

  static List<School> get schools => _schools;

  static ApiController get apiController => _apiController;

  static RefreshController get refreshController => _refreshController;

  static DatabaseController get db => _databaseController;
  static List<School> _schools;

  static setYearAndSchool(School school, int year) {
    db
      ..school = school
      ..year = year;
  }

  static List<School> getSuggestions(String pattern) =>
      _schools
          .where((school) =>
      school.name.startsWith(pattern) ||
          school.id.toString().startsWith(pattern))
          .toList();

  static Future<bool> tryLogin(String username, String password,
      void onComplete(bool success)) {
    db
      ..username = username
      ..password = password;
    return _refreshController.loginDB().then((isSuccess) {
      onComplete(isSuccess);
      return isSuccess;
    });
  }

  static Future<bool> tryLoginFromDB(void onComplete(bool success)) =>
      tryLogin(db.username, db.password, onComplete);

  static bool hasCredentials() => db.hasCredentials();

  static logout(BuildContext context) {
    _loggedOut = true;
    _changeProviders(_currentRoute, "");
    _currentRoute = "/home";
    db.clearData().then((b) {
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacementNamed(context, "/");
    });
  }

  static String _currentRoute = "/home";

  static List<Api> _routeToAPIs(String route) {
    if (route == "/home") return [Api.Grades, Api.Homework, Api.Timetable];
    if (route == "/grades") return [Api.Grades];
    if (route == "/bagrut") return [Api.Bagrut];
    if (route == "/behave") return [Api.BehaveEvents];
    if (route == "/timetable") return [Api.Timetable];
    if (route == "/maakav") return [Api.Maakav];
    if (route == "/hatamot") return [Api.Hatamot];
    if (route == "/hatamotBagrut") return [Api.HatamotBagrut];
    if (route == "/homework") return [Api.Homework];
    print("no apis on route \"$route\"");
    return [];
  }

  ///changes all needed providers when going from route "from" to route "to"
  ///an example when not needing to clear all is from home to grades
  static _changeProviders(String from, String to) {
    List<Api> p = List();
    //List all active providers
    p.addAll(_routeToAPIs(from));
    //List all going-to-be active providers
    _routeToAPIs(to).forEach((api) {
      if (p.contains(api)) {
        //if already active, we won't need to clear them
        p.remove(api);
      } else {
        //if not active, we will want them to have data
        Inject.providers[api].requestData();
      }
    });
    p.forEach((api) => Inject.providers[api].clear());
  }

  static Widget routeTile(BuildContext context, String title, String route) =>
      ListTile(
        title: Text(title),
        onTap: () {
          closeDrawerAndNavigate(context, route);
        },
      );

  static Widget getDrawer(BuildContext context) =>
      Drawer(
          child: ListView(padding: EdgeInsets.zero, children: <Widget>[
            UserAccountsDrawerHeader(
                accountName: Text(db.displayName),
                accountEmail: Text(db.displayClass),
                currentAccountPicture: getPicture()),
            routeTile(context, "בית", "/home"),
            routeTile(context, "ציונים", "/grades"),
            routeTile(context, "ציוני בגרות", "/bagrut"),
            routeTile(context, "אירועי התנהגות", "/behave"),
            routeTile(context, "שיעורי בית", "/homework"),
            routeTile(context, "מערכת שעות", "/timetable"),
            routeTile(context, "הערות מעקב", "/maakav"),
            routeTile(context, "התאמות", "/hatamot"),
            routeTile(context, "התאמות בגרות", "/hatamotBagrut"),
            ListTile(
                title: const Text("התנתק/י"),
                onTap: () {
                  logout(context);
                })
          ]));

  static void closeDrawerAndNavigate(BuildContext context, String route) {
    _changeProviders(_currentRoute, route);
    _currentRoute = route;
    Navigator.pop(context);
    //TODO: remove replacement and store route history so we could go back
    Navigator.pushReplacementNamed(context, route);
  }

  //If picture is set, return it. Otherwise, return future builder
  static Widget getPicture() =>
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

  static Widget decoratePicture(File picture) =>
      Center(
          child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.fill, image: FileImage(picture)))));

  static SimpleDialog createDialog<E>(List<E> data, String itemTitle,
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

  static Future<E> displayDialog<E>(List<E> data, String title,
      BuildContext context,
      {TextAlign align: TextAlign.right}) =>
      showDialog<E>(
          context: context,
          builder: (c) => createDialog(data, title, c, align: align))
          .catchError((error) => null);

  //Wraps a widget with RTL directionality.
  static Widget rtl(Widget w) =>
      Directionality(textDirection: TextDirection.rtl, child: w);

  static Widget wrapper(Widget w) {
    return rtl(Scaffold(
        appBar: AppBar(title: Text("התחברות למשוב"), centerTitle: true),
        body: Container(margin: EdgeInsets.all(16.0), child: w)));
  }

  static PreferredSizeWidget appbar() =>
      PreferredSize(
          preferredSize: Size.fromHeight(150),
          child: AppBar(
              title: Column(
                children: <Widget>[
                  Center(child: Text("משוב")),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Text("average"),
                        Spacer(),
                        Text("hours")
                      ],
                    ),
                  )
                ],
              )));

  //turn YYYY-MM-DD'T'HH:MM:SS into DD/MM/YYYY
  static String dateTimeToDateString(DateTime d) =>
      d
          .toIso8601String()
          .split("T")
          .first
          .split("-")
          .reversed
          .join("/");

  static const double margin = 24.0;

  static Builder timetableBuilder() =>
          (BuildContext context, dynamic l) {
        Lesson lesson = l;
        Widget Function(String subject, List<String> teachers) builder =
            (String subject, List<String> teachers) =>
            ListTile(
                title: Text(subject),
                subtitle: Text(teachers.join(", ")),
                contentPadding: EdgeInsets.only(left: 4.0, right: 4.0));
        //if there is only one lesson, it should be right next to the hour.
        //otherwise, we want a spacer and a divider
        List<Widget> content = List();
        if (!lesson.subject.contains("|||")) {
          content.add(builder(lesson.subject, lesson.teachers));
        } else {
          List<String> subjects = lesson.subject.split("|||");
          int teachersIndex = 0;
          for (int i = 0; i < subjects.length; i++) {
            List<String> teachers = List();
            while (teachersIndex < lesson.teachers.length &&
                lesson.teachers[teachersIndex] != "|||") {
              teachers.add(lesson.teachers[teachersIndex++]);
            }
            teachersIndex++;
            //add one to skip ||| for the next one
            content.add(builder(subjects[i], teachers));
          }
        }
        return ListTile(
          leading: CircleAvatar(
            child: Text("${lesson.hour}",
                style:
                Theme
                    .of(context)
                    .textTheme
                    .body1
                    .copyWith(fontSize: 18)),
            backgroundColor: Colors.transparent,
          ),
          title: Column(children: content),
          contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
          dense: true,
        );
      };

  static List<E> timetableDayProcess<E>(List<E> data, bool isDemo) {
    //the days of the mashov go from 1 to 7, not from 0 to 6.
    List<Lesson> timetable = List.from([...data]);
    if (isDemo) {
      if (today == 7) {
        //get some sleep on saturday!
        timetable = [];
        for (int i = 0; i < 6; i++) {
          timetable.add(Lesson(
              groupId: 0,
              day: 7,
              subject: "לישון",
              hour: i + 1,
              teachers: [],
              room: ""));
        }
      } else {
        //just a normal day
        //setting temp variable just to avoid calculation of today a lot of times
        int day = today;
        timetable = timetable.where((lesson) => lesson.day == day).toList();
      }
    }
    //TODO: Bagrut grades Button
    if (today != 7) {
      timetable
          .sort((lesson1, lesson2) => lesson1.hour.compareTo(lesson2.hour));
      for (int i = 0; i < timetable.length - 1; i++) {
        if (timetable[i].hour == timetable[i + 1].hour) {
          if (!timetable[i].teachers.contains(timetable[i + 1].teachers)) {
            timetable[i]
                .teachers
                .addAll(["|||", ...(timetable[i + 1].teachers)]);
            timetable[i].subject += "|||${timetable[i + 1].subject}";
          }
          timetable.removeAt(i + 1);
        }
      }
    }
    return timetable as List<E>;
  }

  static int get today {
    int day = DateTime
        .now()
        .weekday;
    return day == 7 ? 1 : day + 1;
  }

  //might have more formatting issues in the future.
  static String formatMessage(String src) => src.replaceAll("<br>", "\n");

  static Future<bool> canWriteToExternalStorage() =>
      SimplePermissions.checkPermission(Permission.WriteExternalStorage);

  static Future<bool> askPermissionExternalStorage() =>
      SimplePermissions.requestPermission(Permission.WriteExternalStorage)
          .then((status) => status == PermissionStatus.authorized);

  static Future<File> _downloadFile(String maakavId, Attachment attachment) =>
      filesController
          .getDownloadFile(attachment.name)
          .then((file) =>
          _apiController.getMaakavAttachment(
              maakavId, db.userId, attachment.id, attachment.name, file))
          .catchError((err) {
        print("Error fetching file: $err");
        return null;
      });

  static Future<File> downloadFile(String maakavId,
      Attachment attachment) async {
    if (!await canWriteToExternalStorage()) {
      if (await askPermissionExternalStorage()) {
        _downloadFile(maakavId, attachment);
      } else
        return null;
    }
    return _downloadFile(maakavId, attachment);
  }

  static Future<void> Function({Map additionalData}) _requestApi(Api api,
      {Map additionalData}) =>
          ({Map additionalData}) =>
          refreshController.refresh(api, data: additionalData);

  static Map<Api, ApiProvider> providers = {
    Api.Grades: ApiProvider<Grade>(
        requestData: _requestApi(Api.Grades),
        overviewsBuilder: (grades) =>
        {
          "כמות מבחנים": "${grades.length > 0 ? grades.length : ""}",
          "ממוצע":
          "${grades.length > 0 ? (grades.map((g) => g.grade).reduce((a,
              b) => a + b) / grades.length).toStringAsPrecision(2) : ""}"
        }),
    Api.BehaveEvents: ApiProvider<BehaveEvent>(
        requestData: _requestApi(Api.BehaveEvents),
        overviewsBuilder: (events) {
          int justified = 0,
              unjustified = 0;
          events.forEach((event) {
            if (event.justificationId == 0 || event.justificationId == -1)
              unjustified++;
            else
              justified++;
          });
          return {"מוצדקים": "$justified", "לא מוצדקים": "$unjustified"};
        }),
    Api.Timetable: ApiProvider<Lesson>(
        requestData: _requestApi(Api.Timetable),
        overviewsBuilder: (lessons) =>
        {
          "שעות להיום":
          "${lessons.length > 0 ? lessons
              .where((l) => l.day == today)
              .map((l) => l.hour)
              .toSet()
              .length : ""}"
        }),
    Api.Homework: ApiProvider<Homework>(
        requestData: _requestApi(Api.Homework),
        overviewsBuilder: (hw) => {}),
    Api.Maakav: ApiProvider<Maakav>(
        requestData: _requestApi(Api.Maakav),
        overviewsBuilder: (mk) => {}),
    Api.Bagrut: ApiProvider<Bagrut>(
        requestData: _requestApi(Api.Bagrut),
        overviewsBuilder: (grades) {
          List<int> testGrades = grades
              .where((g) => g.testGrade > 0)
              .map((g) => g.testGrade)
              .toList();
          return {
            "כמות מבחנים": "${testGrades.length}",
            "ממוצע": testGrades.length > 0
                ? (testGrades.reduce((a, b) => a + b) / testGrades.length)
                .toStringAsPrecision(2)
                : ""
          };
        }),
    Api.Hatamot: ApiProvider<Hatama>(
      overviewsBuilder: (hatamot) => {},
      requestData: _requestApi(Api.Hatamot),
    ),
    Api.HatamotBagrut: ApiProvider<HatamatBagrut>(
        overviewsBuilder: (hatamot) => {},
        requestData: _requestApi(Api.HatamotBagrut)),
    Api.MessagesCount: ApiProvider<MessagesCount>(
        overviewsBuilder: (messagesCount) => {
          "הודעות חדשות":
          "${messagesCount.length > 0 ? messagesCount.first.newMessages : ""}"
        },
        requestData: _requestApi(Api.MessagesCount))
  };

  static String bagrutDate(String date) {
    String year = date.substring(0, 4);
    String month = date.substring(4);
    String monthStr = "";

    switch (month) {
      case "06":
        monthStr = "קיץ";
        break;
      case "08":
        monthStr = "קיץ מועד ב";
        break;
      default:
      //we still don't know how these work - we'll soon know!
        monthStr = "חורף";
        break;
    }
//    print("month is $month so monthstr is $monthStr");
    return "$year $monthStr";
  }

  static List<E> cloneTimetable<E>(List<E> data) {
    List<Lesson> timetable = List.from(data);
    return List.generate(
        timetable.length,
            (i) =>
            Lesson(
            groupId: timetable[i].groupId,
            day: timetable[i].day,
            hour: timetable[i].hour,
            subject: "${timetable[i].subject}",
                teachers: List.generate(timetable[i].teachers.length,
                        (j) => "${timetable[i].teachers[j]}"),
                room: "${timetable[i].room}")).toList() as List<E>;
  }
}
