import 'dart:async';

import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/contollers/database_controller.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/providers/api_provider.dart';

class RefreshController {
  ApiController _apiController;
  DatabaseController _databaseController;
  List<Api> _runningRequests = List();
  List<Api> _queuedRequests = List();
  bool _isPerformingLogin = false;
  bool _shouldPerformLogin = false;

  RefreshController() {
    _apiController = Inject.apiController;
    _databaseController = Inject.db;
    _apiController.attachDataProcessor((dynamic data, Api api) {
      if (api != Api.MessagesCount && Inject.providers.containsKey(api)) {
        Inject.providers[api].setData(data);
      }
      if (api == Api.Login) {
        _databaseController.setLoginData(data);
      } else if (api == Api.MessagesCount) {
        //had some weird casting problems
        //but we're all good now
        (Inject.providers[Api.MessagesCount] as ApiProvider<MessagesCount>)
            .setData([data as MessagesCount]);
      }
    });
  }

  Future<bool> refresh(Api api, {Map data}) async {
    print("refresh called with api $api\n");
    if (_shouldPerformLogin) {
      _queuedRequests.add(api);
      loginDB();
    }
    if (_runningRequests.contains(api) || _queuedRequests.contains(api))
      return Future.value(false);
    if (_isPerformingLogin) {
      _queuedRequests.add(api);
      return Future.value(false);
    } else {
      return _refreshInternal(api, data: data);
    }
  }

  Future<void> refreshAll(List<Api> apis, {Map<Api, Map> data}) {
    if (data != null) {
      return Future.wait(apis.map((api) =>
          refresh(api, data: data.containsKey(api) ? data[api] : null)));
    }
    return Future.wait(apis.map((api) => refresh(api)));
  }

  Future<bool> _refreshInternal(Api api, {Map data}) async {
    _runningRequests.add(api);
    Future<Result> request;
    String userId = _databaseController.userId;
    switch (api) {
      case Api.Alfon:
        request = _apiController.getContacts(userId, data["id"] ?? "-1");
        break;
      case Api.Bagrut:
        request = _apiController.getBagrut(userId);
        break;
      case Api.BehaveEvents:
        request = _apiController.getBehaveEvents(userId);
        break;
      case Api.Grades:
        request = _apiController.getGrades(userId);
        break;
      case Api.Groups:
        request = _apiController.getGroups(userId);
        break;
      case Api.Messages:
        request = _apiController.getMessages(data["skip"] ?? 0);
        break;
      case Api.Timetable:
        request = _apiController.getTimeTable(userId);
        break;
      case Api.Homework:
        request = _apiController.getHomework(userId);
        break;
      case Api.MessagesCount:
        request = _apiController.getMessagesCount();
        break;
      case Api.Maakav:
        request = _apiController.getMaakav(userId);
        break;
      case Api.Hatamot:
        request = _apiController.getHatamot(userId);
        break;
      case Api.HatamotBagrut:
        request = _apiController.getHatamotBagrut(userId);
        break;
      default:
        break;
    }
    if (request != null) {
      return request.then((result) {
//        print("request of api $api was ${result.isSuccess}");
        if (result.isSuccess) {
          _runningRequests.remove(api);
          return true;
//          _callbacks.forEach((c) => c.onSuccess(api));
        } else if (result.isNeedToLogin) {
          loginDB();
        } else if (result.isForbidden) {
          _runningRequests.remove(api);
//          _callbacks.forEach((c) => c.onSuspend());
        } else {
          _runningRequests.remove(api);
//          _callbacks.forEach((c) => c.onFail(api));
        }
        return false;
      });
    }
    return Future.value(false);
  }

  Future<bool> loginDB() =>
      _login(
          _databaseController.school,
          _databaseController.username,
          _databaseController.password,
          _databaseController.year);

  Future<bool> login(String username, String password) {
    //assuming we have school and year inside db
    if (Inject.selectedSchool == null || Inject.selectedYear == null) {
      print("inject selected school or year is null? returning false on login");
      return Future.value(false);
    }
    return _login(
        Inject.selectedSchool, username, password, Inject.selectedYear);
  }

  Future<bool> _login(School school, String username, String password, int year,
      {int tries: 1}) async {
    if (!_isPerformingLogin) {
      _isPerformingLogin = true;
      _queuedRequests += _runningRequests;
      _runningRequests.clear();
      await _databaseController.clearData();
      return _apiController
          .login(school, username, password, year)
          .then((result) {
        if (result.isSuccess) {
          LoginData data = result.value.data;
          Student student = result.value.students.first;
          _databaseController
            ..sessionId = data.sessionId
            ..userId = data.userId
            ..classCode = student.classCode
            ..classNum = student.classNum.toString()
            ..privateName = student.privateName
            ..familyName = student.familyName;
          _isPerformingLogin = false;
          _shouldPerformLogin = false;
          _queuedRequests.forEach((api) => _refreshInternal(api));
          _queuedRequests.clear();
          return refreshAll(
              [Api.Homework, Api.Timetable, Api.Grades, Api.MessagesCount])
              .then((_) => true);
        } else {
          print("Error logging in($tries): ${result.exception}");
          if (result.isNeedToLogin) {
            _isPerformingLogin = _shouldPerformLogin = false;
            if (tries > 3) {
              print("quitting.");
              _queuedRequests.clear();
              _runningRequests.clear();
              /*if (result.isNeedToLogin) {
                _databaseController.clearData();
                _callbacks.forEach((c) => c.onUnauthorized());
              } else if (result.isForbidden) {
                _callbacks.forEach((c) => c.onSuspend());
              } else {
                _shouldPerformLogin = true;
                _callbacks.forEach((c) => c.onLoginFail());
              }*/
              return false;
            }
            print("trying to login again.");
            return _login(school, username, password, year, tries: tries + 1);
          } else {
            //something bad happened
            print(
                "some REALLY bad error. I mean, you should contact a real programmer or something.\n");
            print("debug info: ${result.exception}");
            return false;
          }
        }
      });
    }
    return Future.value(false);
  }
}
