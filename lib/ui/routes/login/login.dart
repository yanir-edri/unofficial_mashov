import 'package:flutter/material.dart';
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
  bool rememberMe = false;
  bool hasCredentials = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Inject.hasCredentials()) {
        _usernameController.text = Inject.db.username;
        _passwordController.text = Inject.db.password;
        showLoadingDialog(context);
        Inject.tryLoginFromDB((isSuccessful) {
          Navigator.pop(context);
          if (isSuccessful) {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            showFailedDialog();
          }
        });
      }
    });
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
                    return null;
                  }),
              TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.lock), labelText: 'סיסמה'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "אנא הכנס סיסמה";
                    }
                    return null;
                  },
                  obscureText: true),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: _CheckBoxButton(
                  initialValue: Inject.hasCredentials(),
                  text: "זכור סיסמה",
                  onChanged: (v) {
                    rememberMe = v;
                  },
                ),
              ),
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
                            showLoadingDialog(context);
                            Inject.tryLogin(
                                _usernameController.text,
                                _passwordController.text,
                                rememberMe, (isSuccessful) {
                              Navigator.pop(context);
                              print("isSuccessful=$isSuccessful");
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
        context: context,
        builder: (context) {
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

  showLoadingDialog(BuildContext context) =>
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              Center(
                  child: SizedBox(
                      height: 40.0,
                      width: 40.0,
                      child: CircularProgressIndicator())));
}

class _CheckBoxButton extends StatefulWidget {
  final String text;
  final Function(bool active) onChanged;
  final bool initialValue;

  _CheckBoxButton({@required this.text,
    @required this.onChanged,
    @required this.initialValue});

  @override
  _CheckBoxButtonState createState() {
    return _CheckBoxButtonState(initialValue: initialValue);
  }
}

class _CheckBoxButtonState extends State<_CheckBoxButton> {
  bool _active;

  _CheckBoxButtonState({@required bool initialValue}) {
    _active = initialValue;
  }

  changeActiveState(bool newState) {
    setState(() {
      _active = newState;
    });
    widget.onChanged(newState);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Checkbox(value: _active, onChanged: changeActiveState),
        Text(widget.text)
      ],
    );
  }
}
