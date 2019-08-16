import 'dart:async';

import 'package:fab_menu/fab_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/providers/api_provider.dart';
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

  MenuFilter({this.filter,
    this.futureFilter,
    @required this.icon,
    @required this.label}) {
    assert(this.filter != null || this.futureFilter != null,
    "Menu Filter error: either filter or future filter mustn't be null.");
  }
}

class DataListPage<E> extends StatelessWidget {
  final Builder builder;
  final Map additionalData;
  final List<MenuFilter> filters;
  final String title;
  final String notFoundMessage;

  DataListPage({Key key,
    @required this.builder,
    @required this.notFoundMessage,
    this.filters,
    this.additionalData,
    this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ApiProvider<E> provider = Provider.of<ApiProvider<E>>(context);
    List<OverviewItem> overviews = List();
    provider
        .getFilteredOverviews()
        .forEach((a, b) =>
        overviews.add(OverviewItem(title: a, data: provider.hasData ? b : "")));
    Widget test = NestedScrollView(
      headerSliverBuilder: (context, innerBoxScrolled) =>
      [overviews.length > 0
          ? SliverAppBar(
        //height needed to be exactly on the line of the drawer
          expandedHeight: 161.0,
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
                child: Row(children: <Widget>[
                  Spacer(),
                  for (OverviewItem o in overviews) ...[o, Spacer()]
                ]),
              )))
          : SliverAppBar(
        title: Text(title),
      )
      ],
      body: RefreshIndicator(
        onRefresh: () {
          return provider.refresh();
        },
        child: DataList<E>(
          builder: builder,
          isDemo: false,
          additionalData: additionalData,
          notFoundMessage: notFoundMessage,
        ),
      ),
    );
    return Inject.rtl(Scaffold(
        drawer: Inject.getDrawer(context),
        body: test,
        floatingActionButton: filters != null
            ? FabMenu(
          mainIcon: Icons.filter_list,
          maskColor: Colors.transparent,
          menus: filters
              .map((menuFilter) =>
              MenuData(menuFilter.icon,
                      (context, data) => _handleFab(context, data.labelText),
                  labelText: menuFilter.label))
              .toList(),
        )
            : null));
  }

  _handleFab(BuildContext context, String label) {
    ApiProvider provider = Provider.of<ApiProvider<E>>(context, listen: false);
    MenuFilter item =
    filters.firstWhere((f) => f.label == label, orElse: () => null);
    if (item != null) {
      if (item.filter != null) {
        provider.filter = (items) => Future.value(item.filter(items));
      } else {
        provider.filter = item.futureFilter;
      }
    } else {
      print("error filtering data: no filter with label $label");
    }
  }
}
