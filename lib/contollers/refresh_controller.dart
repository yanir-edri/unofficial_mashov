import 'dart:collection';

import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/contollers/database_controller.dart';
import 'package:unofficial_mashov/inject.dart';

class RefreshController {
  ApiController _apiController;
  DatabaseController _databaseController;
  HashMap<int, Callback> callbacks = HashMap();
  List<Api> runningRequests = List();
  List<Api> queuedRequests = List();
  bool isPerformingLogin = false;
  bool shouldPerformLogin = false;

  RefreshController() {
    _apiController = Inject.apiController;
    _databaseController = Inject.databaseController;
    _apiController.attachDataProcessor((dynamic data, Api api) {
      switch (api) {
        case Api.Grades:
          _databaseController.grades = data;
          break;
        case Api.BagrutGrades:
          break;
        case Api.BehaveEvents:
          _databaseController.behaveEvents = data;
          break;
        case Api.Groups:
          _databaseController.groups = data;
          break;
        case Api.Timetable:
          _databaseController.timetable = data;
          break;
        case Api.Alfon:
          _databaseController.contacts = data;
          break;
        case Api.Messages:
          _databaseController.conversation = data;
          break;
        case Api.Message:
          _databaseController.conversation = data;
          break;
        case Api.Maakav:
          _databaseController.maakavReports = data;
          break;
        case Api.Homework:
          _databaseController.homework = data;
          break;
        case Api.Hatamot:
          _databaseController.hatamot = data;
          break;
        case Api.Login:
          _databaseController.setLoginData(data);
          break;
        default:
          break;
      }
    });
  }

  bool refresh(Api api, {Map data}) {
    if (shouldPerformLogin) {
      queuedRequests.add(api);
      login();
    }
    if (runningRequests.contains(api) || queuedRequests.contains(api))
      return false;
    if (isPerformingLogin) {
      queuedRequests.add(api);
      return false;
    } else {
      refreshInternal(api, data: data);
      return true;
    }
  }

  refreshAll(List<Api> apis, {Map data}) {
    apis.forEach((api) => refresh(api, data: data));
  }

  refreshInternal(Api api, {Map data}) {
    runningRequests.add(api);
    Future<Result> request;
    String userId = _databaseController.userId;
    switch (api) {
      case Api.Alfon:
        request = _apiController.getContacts(userId, data["group"] ?? "-1");
        break;
      case Api.BagrutGrades:
        request = _apiController.getBagrutGrades(userId);
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
      default:
        break;
    }
    if (request != null) {
      request.then((result) {
        if (result.isSuccess) {
          runningRequests.remove(api);
          callbacks.values.forEach((c) => c.onSuccess(api));
        } else if (result.isNeedToLogin) {
          login();
        } else if (result.isForbidden) {
          runningRequests.remove(api);
          callbacks.values.forEach((c) => c.onSuspend());
        } else {
          runningRequests.remove(api);
          callbacks.values.forEach((c) => c.onFail(api));
        }
      });
    }
  }

  login() {
    if (!isPerformingLogin) {
      isPerformingLogin = true;
      queuedRequests += runningRequests;
      runningRequests.clear();
      _apiController
          .login(_databaseController.school, _databaseController.username,
              _databaseController.password, _databaseController.year)
          .then((result) {
        if (result.isSuccess) {
          Login login = result.value;
          if (result.isOk) {
            _databaseController
              ..sessionId = login.data.sessionId
              ..year = login.data.year;
            isPerformingLogin = false;
            shouldPerformLogin = false;
            queuedRequests.forEach((api) => refreshInternal(api));
            queuedRequests.clear();
          } else {
            isPerformingLogin = false;
            shouldPerformLogin = false;
            queuedRequests.clear();
            runningRequests.clear();
            if (result.isNeedToLogin) {
              _databaseController.clearData();
              callbacks.values.forEach((c) => c.onUnauthorized());
            } else if (result.isForbidden) {
              callbacks.values.forEach((c) => c.onSuspend());
            } else {
              shouldPerformLogin = true;
              callbacks.values.forEach((c) => c.onLoginFail());
            }
          }
        } else {
          //something bad happened
        }
      });
    }
  }

  attachCallback(int id, Callback callback) {
    callbacks[id] = callback;
  }

  detachCallback(int id) {
    callbacks.remove(callbacks[id]);
  }
}

abstract class Callback {
  onSuccess(Api api);

  onFail(Api api);

  onLoginFail();

  onSuspend();

  onUnauthorized();

  onLogin();

  onOldApi();
}
