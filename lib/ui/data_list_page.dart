import 'dart:async';

import 'package:fab_menu/fab_menu.dart';
import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unofficial_mashov/contollers/bloc.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/ui/data_list.dart';
import 'package:unofficial_mashov/ui/overview_item.dart';

typedef Builder = Widget Function(BuildContext context, dynamic item);
typedef Filter = List Function(List data);
typedef FutureFilter = Future<List> Function(List data);
class MenuFilter {
  final Filter filter;
  final FutureFilter futureFilter;
  final IconData icon;
  final String label;

  MenuFilter(
      {this.filter, this.futureFilter, @required this.icon, @required this.label}) {
    assert(this.filter != null || this.futureFilter !=
        null, "Menu Filter error: either filter or future filter mustn't be null.");
  }
}

class DataListPage<E> extends StatefulWidget {
  final String title;
  final Builder builder;
  final Api api;
  final Map additionalData;
  final List<MenuFilter> filters;

  DataListPage({Key key,
    @required this.title,
    @required this.builder,
    @required this.api,
    this.filters,
    this.additionalData})
      : super(key: key);

  @override
  _DataListPageState<E> createState() {
    return _DataListPageState();
  }

}

class _DataListPageState<E> extends State<DataListPage<E>> {

  PublishSubject<List<E>> _contentSubject;
  List<E> _cache;
  List<E> _filteredCache;
  FutureFilter _filter = (items) => Future.value(items);


  @override
  Widget build(BuildContext context) {
    Widget body = NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 150.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                background: Padding(
                    padding: const EdgeInsets.only(top: 80.0),
                    /*
                    This is problematic because this header is called a lot of times (every scroll)
                    and might cause some performance issues
                    might want to replace this in the future to something more performance-wise
                    this cannot be replaced with something static becuase filters might stream new data
                    and yet stream builder is.. not small
                    */
                    child: buildOverview(
                        _contentSubject.stream, widget.api, _filteredCache)
                ),
              ),
            )
          ];
        },
        body: DataList(api: widget.api,
            builder: widget.builder,
            isDemo: false,
            additionalData: widget.additionalData,
            stream: _contentSubject.stream)
    );


    return Inject.rtl(Scaffold(
        drawer: bloc.getDrawer(context),
        body: body,
        floatingActionButton: widget.filters != null
            ? FabMenu(
          mainIcon: Icons.filter_list,
          maskColor: Colors.transparent,
          menus: widget.filters
              .map((menuFilter) => MenuData(menuFilter.icon,
                  (context, data) => _handleFab(context, data.labelText),
              labelText: menuFilter.label))
              .toList(),
        )
            : null));
  }

  _handleFab(BuildContext context, String label) {
    MenuFilter item =
    widget.filters.firstWhere((f) => f.label == label, orElse: () => null);
    if (item != null) {
      if (item.filter != null) {
        _filter = (items) => Future.value(item.filter(items));
      } else {
        _filter = item.futureFilter;
      }
      _update();
    } else {
      print("error filtering data: no filter with label $label");
    }
  }

  @override
  void initState() {
    super.initState();
    bloc.getApiData(widget.api, data: widget.additionalData).listen((data) {
      _cache = data;
      _update();
    });
    _contentSubject = PublishSubject<List<E>>();
  }

  _update() {
    _filter(_cache).then((data) {
      _contentSubject.sink.add(data);
      _filteredCache = data;
    });
//    _contentSubject.sink.add(_filter(_cache));
  }

  @override
  void dispose() {
    _contentSubject.close();
    _filter = null;
    super.dispose();
  }

  Widget buildOverview<E>(Stream<List<E>> data, Api api, List<E> initialData) {
    print("Stream builder builded");
    return StreamBuilder<List<E>>(
        stream: data, initialData: initialData, builder: (context, snap) {
      if (!snap.hasData || snap.data == null) return Text("");
      switch (api) {
        case Api.Grades:
          List<Grade> grades = snap.data.cast();
          Iterable<int> gradesNum = grades.where((g) => g.grade != 0)
              .map((g) => g.grade);
          int len = gradesNum.length;
          double average = gradesNum.reduce((n1, n2) => n1 + n2) / len;
          return Row(children: <Widget>[
            Spacer(),
            OverviewItem(title: "כמות מבחנים", data: snap.data.length),
            Spacer(),
            OverviewItem(title: "ממוצע", data: average, precision: 1),
            Spacer()
          ]);
        case Api.BehaveEvents:
          List<BehaveEvent> events = snap.data.cast();
          int justified = events
              .where((e) => e.justificationId > 0)
              .length;
          return Row(children: <Widget>[
            Spacer(),
            OverviewItem(title: "מוצדקים", data: justified),
            Spacer(),
            OverviewItem(title: "לא מוצדקים", data: events.length - justified),
            Spacer()
          ]);

        default:
          print("no overviews set for api $api, breaking");
          return Text("no overview set");
      }
    });
  }


}


