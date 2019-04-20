import 'package:fab_menu/fab_menu.dart';
import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unofficial_mashov/contollers/bloc.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/ui/data_list.dart';

typedef Builder = Widget Function(BuildContext context, dynamic item);
typedef Filter = List Function(List data);
class MenuFilter {
  final Filter filter;
  final IconData icon;
  final String label;

  MenuFilter(
      {@required this.filter, @required this.icon, @required this.label});
}

class DataListPage<E> extends StatefulWidget {
  final String title;
  final Builder builder;
  final Api api;
  final Map additionalData;
  final List<MenuFilter> filters;

  DataListPage(
      {Key key,
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
  Filter _filter = (items) => items;
  @override
  Widget build(BuildContext context) {
    return Inject.rtl(Scaffold(
        drawer: bloc.getDrawer(context),
        appBar: AppBar(title: Text(widget.title)),
        body: DataList(api: widget.api,
            builder: widget.builder,
            isDemo: false,
            additionalData: widget.additionalData,
            stream: _contentSubject.stream),
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
      _filter = item.filter;
      _update();
//      widget._dataList.filter(item.filter);
//      bloc.filterData(widget.api, item.filter, data: widget.additionalData);
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
    _contentSubject.sink.add(_filter(_cache));
  }

  @override
  void dispose() {
    _contentSubject.close();
    super.dispose();
  }


}
