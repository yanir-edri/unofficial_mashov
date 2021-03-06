import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/inject.dart';

class ChooseSchoolRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Inject.wrapper(Container(child: Form(child: _field(context))));
  }

  Widget _field(BuildContext context) {
    return TypeAheadField(
      noItemsFoundBuilder: (ctxt) => Text(""),
      debounceDuration: Duration.zero,
      textFieldConfiguration: TextFieldConfiguration(
          autofocus: true,
          decoration: const InputDecoration(
              icon: Icon(Icons.school), labelText: "בחר בית ספר:")),
      suggestionsCallback: (pattern) {
        return Inject.schools
            .where((school) =>
        (school.name.startsWith(pattern) ||
            school.id.toString().startsWith(pattern)))
            .toList();
      },
      itemBuilder: (context, suggestion) {
//        suggestion as School;
        return ListTile(
          title: Text(suggestion.name),
          subtitle: Text("${suggestion.id}"),
        );
      },
      onSuggestionSelected: (school) {
        school.years.sort();
        showDialog(
            context: context,
            builder: (context) => getYearsDialog(context, school)).then((year) {
          if (year != null) {
            Inject.setYearAndSchool(school, year);
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      },
    );
  }

  SimpleDialog getYearsDialog(BuildContext context, School school) =>
      SimpleDialog(
        title: Inject.rtl(Text("בחר שנה:", textAlign: TextAlign.center)),
        children: school.years.reversed
            .map((year) =>
            SimpleDialogOption(
                child: Text("$year",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18)),
                onPressed: () {
                  Navigator.pop(context, year);
                }))
            .toList(),
      );
}
