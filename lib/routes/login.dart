import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/inject.dart';

class LoginRoute extends StatefulWidget {
  final School school;
  final int year;

  LoginRoute({Key key, @required this.school, @required this.year})
      : super(key: key);

  @override
  LoginRouteState createState() {
    return LoginRouteState(school: school, year: year);
  }
}

class LoginRouteState extends State<LoginRoute> {
  LoginRouteState({this.school, this.year}) : super();

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  School school;
  int year = 2019;
  Future<Result<Login>> loginFuture;
  bool done = false;
  Result<Login> loginValue;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                  controller: this._usernameController,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.person), labelText: 'שם משתמש'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "אנא הכנס שם משתמש או ת.ז.";
                    }
                  }),
              TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.lock), labelText: 'סיסמה'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "אנא הכנס סיסמה";
                    }
                  },
                  obscureText: true),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                      child: RaisedButton(
                    color: Colors.lightBlue,
                    textColor: Colors.white,
                    highlightColor: Colors.lightBlueAccent,
                    onPressed: () {
                      // Validate will return true if the form is valid, or false if
                      // the form is invalid.
                      if (_formKey.currentState.validate()) {
                        // If the form is valid, we want to login
                        // school is _school
                        // username is _usernameController.text
                        //password is _passwordController.text
                        //year is $year
                        setState(() {
                          done = false;
                          loginValue = null;
                          loginFuture = MashovApi.getController().login(
                              school,
                              _usernameController.text,
                              _passwordController.text,
                              year);
                          loginFuture.then((value) {
                            setState(() {
                              loginValue = value;
                              done = true;
                            });
                          });
                        });
                        print("signing in, ${loginFuture.hashCode}");
                      }
                    },
                    child: Text('התחבר'),
                  )))
            ]));
    return Scaffold(
        appBar: AppBar(title: Text("התחברות למשוב"), centerTitle: true),
        body: Inject.rtl(Container(
            child: body,
            margin: EdgeInsets.all(16))));
  }
}
