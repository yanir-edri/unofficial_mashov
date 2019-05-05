import 'dart:async';

import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/contollers/bloc.dart';
import 'package:unofficial_mashov/contollers/database_controller.dart';

class RefreshController {
  ApiController _apiController;
  DatabaseController _databaseController;
  List<Callback> _callbacks = List();
  List<Api> _runningRequests = List();
  List<Api> _queuedRequests = List();
  bool _isPerformingLogin = false;
  bool _shouldPerformLogin = false;

  RefreshController() {
    _apiController = bloc.apiController;
    _databaseController = bloc.db;
    _apiController.attachRawDataProcessor((dynamic data, Api api) {
//      print("proccessing raw data of api $api, data=$data");
      switch (api) {
        case Api.Grades:
          _databaseController.grades = data;
          break;
        case Api.BagrutGrades:
          _databaseController.bagrutGrades = data;
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
          _databaseController.conversations = data;
          break;
        case Api.Message:
          _databaseController.setConversation(data);
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
          print("login is $data\n");
          break;
        default:
          break;
      }
    });
    _apiController.attachDataProcessor((dynamic data, Api api) {
      if (api == Api.Login) {
        _databaseController.setLoginData(data);
      } else if (api == Api.MessagesCount) {
        _databaseController.messagesCount = data;
      }
    });
  }

  bool refresh(Api api, {Map data}) {
    print("refresh called with api $api\n");
    if (_shouldPerformLogin) {
      _queuedRequests.add(api);
      login();
    }
    if (_runningRequests.contains(api) || _queuedRequests.contains(api))
      return false;
    if (_isPerformingLogin) {
      _queuedRequests.add(api);
      return false;
    } else {
      _refreshInternal(api, data: data);
      return true;
    }
  }

  refreshAll(List<Api> apis, {Map data}) {
    apis.forEach((api) => refresh(api, data: data));
  }

  _refreshInternal(Api api, {Map data}) {
    _runningRequests.add(api);
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
      case Api.Homework:
        request = _apiController.getHomework(userId);
        break;
      case Api.MessagesCount:
        request = _apiController.getMessagesCount();
        break;
      default:
        break;
    }
    if (request != null) {
      request.then((result) {
//        print("request of api $api was ${result.isSuccess}");
        if (result.isSuccess) {
          _runningRequests.remove(api);
          _callbacks.forEach((c) => c.onSuccess(api));
        } else if (result.isNeedToLogin) {
          login();
        } else if (result.isForbidden) {
          _runningRequests.remove(api);
          _callbacks.forEach((c) => c.onSuspend());
        } else {
          _runningRequests.remove(api);
          _callbacks.forEach((c) => c.onFail(api));
        }
      });
    }
  }

  Future<bool> login() {
    if (!_isPerformingLogin) {
      _isPerformingLogin = true;
      _queuedRequests += _runningRequests;
      _runningRequests.clear();
      return _apiController
          .login(_databaseController.school, _databaseController.username,
          _databaseController.password, _databaseController.year)
          .then((result) {
        if (result.isSuccess) {
          if (result.isOk) {
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
            _callbacks.forEach((c) => c.onLogin());
            return true;
          } else {
            _isPerformingLogin = false;
            _shouldPerformLogin = false;
            _queuedRequests.clear();
            _runningRequests.clear();
            if (result.isNeedToLogin) {
              _databaseController.clearData();
              _callbacks.forEach((c) => c.onUnauthorized());
            } else if (result.isForbidden) {
              _callbacks.forEach((c) => c.onSuspend());
            } else {
              _shouldPerformLogin = true;
              _callbacks.forEach((c) => c.onLoginFail());
            }
            return false;
          }
        } else {
          //something bad happened
          print(
              "some REALLY bad error. I mean, you should contact a programmer or something.\n");
          return false;
        }
      });
    }
    return Future.value(true);
  }

  attach(Callback callback) {
//    print("attaching callback");
    detach(callback);
    _callbacks.add(callback);
  }

  detach(Callback callback) {
    if (_callbacks.contains(callback)) {
//      print("detaching callback");
      _callbacks.remove(callback);
    }
  }
}

class Callback {
  onSuccess(Api api) {}

  onFail(Api api) {}

  onLoginFail() {}

  onSuspend() {}

  onUnauthorized() {}

  onLogin() {}
}

