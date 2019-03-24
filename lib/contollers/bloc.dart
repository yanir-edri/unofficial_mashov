import 'package:mashov_api/mashov_api.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unofficial_mashov/inject.dart';

class MasterBloc {
  setYearAndSchool(School school, int year) {
    Inject.databaseController
      ..school = school
      ..year = year;
  }

  List<School> _schools;

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

  tryLogin(String username, String password, void onComplete(bool success)) {
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

  List<PublishSubject<List>> _publishSubjects = List();

  Observable<List> getApiData(Api api, {Map data}) {
    print("Get api data is called with api $api");
    PublishSubject<List> ps = PublishSubject();
    Function listener = (list) {
      print("sinking data to ps of size ${list.length}");
      ps.sink.add(list);
    };
    if (data != null) {
      Inject.databaseController.getApiData(api, data: data).listen(listener);
      Inject.refreshController.refresh(api, data: data);
    } else {
      Inject.databaseController.getApiData(api).listen(listener);
      Inject.refreshController.refresh(api);
    }
    _publishSubjects.add(ps);
    return ps.stream;
  }

  dispose() {
    _publishSubjects.forEach((ps) => ps.close());
  }
}

MasterBloc bloc = MasterBloc();
