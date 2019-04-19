import 'package:mashov_api/mashov_api.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unofficial_mashov/contollers/bloc.dart';

class ApiPublishSubject {
  final Api api;
  final Map data;
  final PublishSubject<List> ps;
  final Updater updater;
  List cache;

  //The filter might filter some items, or sort them in a specific order.
  //The default one does absolutely nothing.
  List Function(List items) filter = (items) => items;

  update() {
    updater(api, data: data).then((list) {
      cache = list;
      ps.sink.add(filter(cache));
    });
  }

  flush() {
    if ((cache != null && cache.isNotEmpty)) {
      ps.sink.add(filter(cache));
    } else {
      ps.sink.add(List());
    }
  }

  setFilter(List Function(List items) filter) {
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
