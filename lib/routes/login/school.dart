import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:unofficial_mashov/inject.dart';
import 'package:unofficial_mashov/routes/login.dart';

class ChooseSchoolRoute extends StatelessWidget {
  final List<School> schools = Inject.schools;
  final TextEditingController _schoolController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Inject.rtl(Container(
          child: Form(
              child: TypeAheadFormField(
                debounceDuration: Duration.zero,
                textFieldConfiguration: TextFieldConfiguration(
                    controller: this._schoolController,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.school), labelText: "בחר בית ספר:")
                ),
                noItemsFoundBuilder: (context) =>
                    Center(child: Text("לא נמצאו בתי ספר"),),
                suggestionsCallback: (pattern) =>
                    schools.where((school) => school.name.contains(pattern))
                        .toList(),
                onSuggestionSelected: (dynamic suggestion) {
                  if (suggestion is School) {
                    suggestion.years.sort();
                    this._schoolController.text = suggestion.name;
                    showDialog(context: context,
                        builder: (context) => getYearsDialog(context, suggestion))
                        .then((year) {
                          if(year != null) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginRoute(
                                school: suggestion,
                                year: year
                            )));
                          }
                    });
                  }
                },
                itemBuilder: (BuildContext context, dynamic suggestion) {
                  if (suggestion is School) {
                    return ListTile(title: Text(suggestion.name));
                  }
                  throw Exception("suggestion is not a school.");
                },
              ))));
  }

  SimpleDialog getYearsDialog(BuildContext context, School school) =>
      SimpleDialog(
        title: Inject.rtl(Text("בחר שנה:", textAlign: TextAlign.center)),
        children: school.years.reversed
            .map((year) =>
            SimpleDialogOption(
                child: Text("$year", textAlign: TextAlign.center, style:
                  TextStyle(
                    fontSize: 18
                  )),
                onPressed: () {
                  Navigator.pop(context, year);
                }))
            .toList(),

      );
}
