import 'package:flutter/material.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/routes/login/school.dart';

void main() =>
    runApp(
        MaterialApp(home: MyApp()
        )
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("משוב"), centerTitle: true),
        body: Container(
            child: FutureBuilder<bool>(
                future: Inject.setup(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    print("snapshot.data equals ${snapshot.data}");
                    if (snapshot.data) return ChooseSchoolRoute();

                    return AlertDialog(
                        title: Text("ההתחברות לשרת המשוב נכשלה"),
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("אוקיי"),
                          )
                        ]);
                  }
                  return Center(child: CircularProgressIndicator());
                }),
            margin: EdgeInsets.all(16)));
  }
}
