import 'dart:async';

import 'package:mashov_api/mashov_api.dart';
import 'package:rxdart/rxdart.dart';

typedef Future<E> Updater<E>(Api api, {Map data});

class ApiPublishSubject<E> {
  final Api api;
  final Map data;
  final PublishSubject<E> ps;
  final Updater<E> updater;
  E cache;

  //The filter might filter some items, or sort them in a specific order.
  //The default one does absolutely nothing.
  E Function(E data) filter = (data) => data;

  update() {
    updater(api, data: data).then((data) {
      cache = data;
      ps.sink.add(filter(cache));
    });
  }

  flush() {
    if ((cache != null && cache != null)) {
      ps.sink.add(filter(cache));
    } else {
      ps.sink.add(null);
    }
  }

  setFilter(E Function(E data) filter) {
    if (filter != null) {
      this.filter = filter;
      ps.sink.add(filter(cache));
    } else {
      print("Error: filter is null");
    }
  }

  ApiPublishSubject(this.ps, this.api, this.updater, {this.data}) {
    update();
  }
}
