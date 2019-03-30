import 'package:flutter/material.dart';
import 'package:unofficial_mashov/contollers/bloc.dart';
import 'package:unofficial_mashov/inject.dart';


class LoginRoute extends StatefulWidget {

  @override
  LoginRouteState createState() {
    return LoginRouteState();
  }
}

class LoginRouteState extends State<LoginRoute> {

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (bloc.hasCredentials()) {
      _usernameController.text = bloc.db.username;
      _passwordController.text = bloc.db.password;
      bloc.tryLoginFromDB((isSuccessful) {
        if (isSuccessful) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          showFailedDialog();
        }
      });
    }
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
                            bloc.tryLogin(_usernameController.text,
                                _passwordController.text, (isSuccessful) {
                                  if (isSuccessful) {
                                    Navigator.pushReplacementNamed(
                                        context, '/home');
                                  } else {
                                    showFailedDialog();
                                  }
                                });
                          }
                        },
                        child: Text('התחבר'),
                      )))
            ]));
    return Scaffold(
        appBar: AppBar(title: Text("התחברות למשוב"), centerTitle: true),
        body: Inject.rtl(Container(child: body, margin: EdgeInsets.all(16))));
  }

  showFailedDialog() {
    showDialog(
        context: context, builder: (context) {
      return SimpleDialog(
        title: Inject.rtl(Text("ההתחברות נכשלה")),
        children: <Widget>[
          SimpleDialogOption(
            child: Text("אוקיי"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      );
    });
  }
}
