import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:unofficial_mashov/inject.dart';

class LoginForm extends StatefulWidget {
  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _schoolController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  School _school;
  int year = -1;
  List<School> schools = Inject.schools;
  Future<Result<Login>> loginFuture;
  bool done = false;
  Result<Login> loginValue;

  @override
  void dispose() {
    _schoolController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey we created above
    List<Widget> widgetList = new List();
    widgetList.add(buildLoginForm(context));
    if(loginFuture != null) {
      widgetList.add(displayProgress());
    }
    return Stack(children: widgetList);
  }

  Widget displayProgress() {
    if(!done) {
      return Stack(children: <Widget>[
        Opacity(opacity: 0.3, child: ModalBarrier(dismissible: false, color: Colors.grey[300])),
        Center(child: CircularProgressIndicator())
      ]);
    }
    if(done) {
      if(loginValue.isSuccess) {
        //move on to next screen.
        //for now, we can do well with some text displayed.
        Student me = loginValue.value.students.first;
        String name = "${me.privateName} ${me.familyName}";
        return SimpleDialog(title: Text("היי, $name"));
      } else {
        return SimpleDialog(title: Text("ההתחברות נכשלה"));
      }
    }
  }

  Widget buildLoginForm(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TypeAheadFormField<School>(
                  suggestionsBoxVerticalOffset: 15.0,
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: this._schoolController,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.school), labelText: 'בית ספר'),
                  ),
                  noItemsFoundBuilder: (context) {
                    return Center(child: Text("לא נמצאו בתי ספר"));
                  },
                  suggestionsCallback: (pattern) {
                    if (schools.isEmpty) {
                      //maybe we should try fetching it again
                      schools = Inject.schools;
                    }
                    return schools
                        .where((school) => school.name.contains(pattern))
                        .toList();
                  },
                  itemBuilder: (BuildContext context, dynamic suggestion) {
                    if (suggestion is School) {
                      return ListTile(title: Text(suggestion.name));
                    } else {
                      //we have no idea what to do!
                      throw Exception("suggestion is not school");
                    }
                  },
                  onSuggestionSelected: (dynamic suggestion) {
                    if (suggestion is School) {
                      suggestion.years.sort();
                      this._schoolController.text = suggestion.name;
                      this._school = suggestion;
                      //we need to choose a year
                      showDialog<int>(
                          context: context,
                          builder: (BuildContext _) {
                            return NumberPickerDialog.integer(
                                minValue: suggestion.years.first,
                                maxValue: suggestion.years.last,
                                title: Text("בחר שנה"),
                                initialIntegerValue: suggestion.years.last);
                          }).then((value) => year = value);
                    } else {
                      this._schoolController.text = suggestion.toString();
                    }
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'אנא בחר בית ספר';
                    }
                  }),
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
                          if (_formKey.currentState.validate() && year != -1) {
                            // If the form is valid, we want to login
                            // school is _school
                            // username is _usernameController.text
                            //password is _passwordController.text
                            //year is $year
                            setState(() {
                              done = false;
                              loginValue = null;
                              loginFuture = MashovApi.getController().login(_school, _usernameController.text, _passwordController.text, year);
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
                      )
                  )
              )
            ]));
  }
} //
/*

*/
