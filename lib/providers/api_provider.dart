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

  ApiProvider(
      {@required Map<String, String> Function(List<E> data) overviewsBuilder,
      List<E> Function(List<E> data) processor}) {
    _buildOverviews = overviewsBuilder;
    if (processor != null) {
      _processor = processor;
    }
  }

  List<E> get data => _filtered;

  //we're not checking filtered because filtered might be empty but cache might
  //hold data. this could be used to display or not display a loading circle.
  bool get hasData => _cache.isNotEmpty;

  set data(List<E> data) {
    if (data == null || data.isEmpty) {
      print("set data is empty, returning on $E");
      return;
    }
    if (_processor != null) {
      //might want to process the data, but not to filter it.
      //in this case, we'll use a processor.
      _cache = _processor(_cache);
    } else {
      _cache = data;
    }
    _filter(_cache).then((filtered) {
      _filtered = filtered;
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
