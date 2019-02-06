import 'package:flutter/material.dart';
import 'package:mashov_api/src/controller/api_controller.dart';
import 'package:unofficial_mashov/contollers/refresh_controller.dart';
import 'package:unofficial_mashov/inject.dart';

typedef Builder<E> = Widget Function(BuildContext context, E item);

class DataList<E> extends StatefulWidget {
  final Builder<E> builder;
  final Api api;
  final List<E> initialData;
  final Map additionalData;

  DataList(
      {Key key,
      this.initialData,
      this.builder,
      @required this.api,
      this.additionalData})
      : super(key: key);

  @override
  DataListState createState() {
    return new DataListState();
  }
}

class DataListState<E> extends State<DataList> implements Callback {
  DataListState();

  List<E> _data = List();
  bool _updated = false;
  bool _isLoading = false;
  String _message = "טוען מידע...";

  @override
  Widget build(BuildContext context) {
    _isLoading = (_updated && _data.isEmpty) || (widget.initialData.isEmpty);
    if (!_isLoading && _message.isNotEmpty) {
      String m = _message;
      return Column(
        children: <Widget>[
          Container(
              margin: EdgeInsets.all(100), child: CircularProgressIndicator()),
          Text(m)
        ],
      );
    } else if (_isLoading) {
      return Container(
          margin: EdgeInsets.all(100), child: CircularProgressIndicator());
    } else if (_message.isNotEmpty) {
      String m = _message;
      _message = "";
      return Text(m);
    }
    List<E> data = _updated ? _data : widget.initialData;
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int i) =>
            widget.builder(context, data[i]));
  }

  @override
  void initState() {
    super.initState();
    Inject.refreshController.attach(this);
  }

  @override
  void dispose() {
    super.dispose();
    Inject.refreshController.detach(this);
  }

  @override
  onFail(Api api) {
    if (api == widget.api) {
      //show dialog?
      //for now, print error
      setState(() {
        print("failed to fetch data - onFail callback of DataList");
      });
    }
  }

  @override
  onLogin() {
    //currently logging in.
    //simply show a circular progress view.
    setState(() {
      print("onLogin from DataList");
      _message = "מבצע התחברות מחדש";
      _isLoading = true;
    });
  }

  @override
  onLoginFail() {
    setState(() {
      _message = "ההתחברות מחדש נכשלה";
      print("login fail from DataList");
    });
  }

  @override
  onSuccess(Api api) {
    setState(() {
      _isLoading = false;
      _data = Inject.databaseController
          .getApiData(api, data: widget.additionalData);
      print("success fetching data from DataList");
    });
  }

  @override
  onSuspend() {
    setState(() {
      _message = "בעיה בשרת המשוב.";
      print("onSuspend from DataList");
    });
  }

  @override
  onUnauthorized() {
    setState(() {
      _message = "פרטי ההתחברות השתנו. אנא נסו להתחבר מחדש";
    });
  }
}
