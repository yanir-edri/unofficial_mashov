import 'package:fab_menu/fab_menu.dart';
import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/contollers/bloc.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/ui/data_list.dart';

typedef Builder = Widget Function(BuildContext context, dynamic item);

class MenuFilter {
  final List Function(List items) filter;
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

  const DataListPage(
      {Key key,
      @required this.title,
      @required this.builder,
      @required this.api,
      this.filters,
      this.additionalData})
      : super(key: key);

  @override
  _DataListPageState<E> createState() => _DataListPageState<E>();
}

class _DataListPageState<E> extends State<DataListPage> {
  @override
  Widget build(BuildContext context) {
    return Inject.rtl(Scaffold(
        drawer: bloc.getDrawer(context),
        appBar: AppBar(title: Text(widget.title)),
        body: DataList(
            key: widget.key,
            builder: widget.builder,
            api: widget.api,
            isDemo: false,
            additionalData: widget.additionalData),
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
    for (int i = 0; i < widget.filters.length; i++) {
      MenuFilter filter = widget.filters[i];
      if (filter.label == label) {
        bloc.filterData(widget.api, filter.filter);
        break;
      }
    }
  }
}
