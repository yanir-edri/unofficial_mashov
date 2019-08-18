import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unofficial_mashov/ui/data_list_page.dart';

class ApiProvider<E> with ChangeNotifier {
  List<E> _cache = List();
  List<E> _filtered = List();
  FutureFilter _filter = (items) => Future.value(items);
  Map<String, String> Function(List<E> data) _buildOverviews;
  List<E> Function(List<E> data) _processor;

  Map<String, String> getFilteredOverviews() => _buildOverviews(_filtered);

  Map<String, String> getUnfilteredOverviews() => _buildOverviews(_cache);

  bool _requesting = false;
  bool _refreshing = false;
  Future<void> Function({Map additionalData}) _requestData;

  String _error = "";

  String get error => _error;

  bool get hasError => _error.isNotEmpty;

  bool get isRequesting => _requesting;

  bool get isRefreshing => _refreshing;

  Future<void> requestData({Map additionalData}) {
    if (!_requesting) {
      _requesting = true;
      return _requestData(additionalData: additionalData);
    }
    return Future.value(0);
  }

  refresh({Map additionalData}) {
    _refreshing = true;
    _clear();
    return requestData(additionalData: additionalData);
  }


  clear() {
    _cache.clear();
    _filtered.clear();
  }

  //this clear is used when refreshing
  //we notify listeners too
  _clear() {
    clear();
    notifyListeners();
  }

  ApiProvider(
      {@required Map<String, String> Function(List<E> data) overviewsBuilder,
        @required Function requestData,
        List<E> Function(List<E> data) processor}) {
    _buildOverviews = overviewsBuilder;
    if (processor != null) {
      _processor = processor;
    }
    _requestData = requestData;
  }

  List<E> get data => _filtered;

  //we're not checking filtered because filtered might be empty but cache might
  //hold data. this could be used to display or not display a loading circle.
  bool get hasData => _cache.isNotEmpty;

  void setData(List<E> data, {String error = ""}) {

    if (error.isNotEmpty) {
      print("set data is empty, returning on $E");
      _cache = List();
      _filtered = List();
      _error = error;
      notifyListeners();
      return;
    }
    _error = "";
    _cache = data;
    if (_processor != null) {
      //might want to process the data, but not to filter it.
      //in this case, we'll use a processor.
      _cache = _processor(data);
    } else {
      _cache = data.reversed.toList();
    }
    _filter(_cache).then((filtered) {
      _filtered = filtered;
      _requesting = false;
      _refreshing = false;
      notifyListeners();
    });
  }

  set filter(FutureFilter f) {
    if (f == null) return;
    _filter = f;
    f(_cache).then((filtered) {
      _filtered = filtered;
      notifyListeners();
    });
  }
}