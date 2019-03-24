import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mashov_api/mashov_api.dart';
import 'package:unofficial_mashov/contollers/bloc.dart';
import 'package:unofficial_mashov/inject.dart';

class ChooseSchoolRoute extends StatelessWidget {
  final TextEditingController _schoolController = TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<School>> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    print("building schools route, schools size is ${Inject.schools.length}");
    return Inject.wrapper(Container(child: Form(child: _field(context))));
  }

  Widget _field(BuildContext context) {
    return TypeAheadField(
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
            bloc.setYearAndSchool(school, year);
            Navigator.pushNamed(context, '/login');
          }
        });
      },
    );
  }

//  Widget _field(BuildContext context) {
//    return AutoCompleteTextField<School>(
//      key: _key,
//      suggestions: schools,
//      itemBuilder: (BuildContext context, School suggestion) =>
//          ListTile(
//            title: Text(suggestion.name), subtitle: Text("${suggestion.id}"),),
//      itemFilter: (school, query) =>
//      school.name.startsWith(query) || "${school.id}".startsWith(query),
//      itemSorter: (school1, school2) => school1.name.compareTo(school2.name),
//      itemSubmitted: (school) {
//        school.years.sort();
////          this._schoolController.text = school.name;
//          showDialog(context: context,
//              builder: (context) => getYearsDialog(context, school))
//              .then((year) {
//            if(year != null) {
//              bloc.setYearAndSchool(school, year);
//              Navigator.pushNamed(context, '/login');
//            }
//          });
//      },
//    );
//  }

//  Widget _field(BuildContext context) {
//    return TypeAheadFormField(
//      debounceDuration: Duration.zero,
//      getImmediateSuggestions: true,
//      textFieldConfiguration: TextFieldConfiguration(
//          controller: this._schoolController,
//          decoration: const InputDecoration(
//              icon: Icon(Icons.school), labelText: "בחר בית ספר:")
//      ),
//      noItemsFoundBuilder: (context) {
//        print("noItemsFoundBuilder is called");
//        return Center(child: Text("לא נמצאו בתי ספר"),);
//      },
//      suggestionsCallback: (pattern) {
//        print("suggestionsCallback is called with pattern $pattern");
//        return schools.where((school) => school.name.contains(pattern) || "${school.id}".contains(pattern))
//            .toList();
//      },
//      onSuggestionSelected: (dynamic suggestion) {
//        if (suggestion is School) {
//          suggestion.years.sort();
//          this._schoolController.text = suggestion.name;
//          showDialog(context: context,
//              builder: (context) => getYearsDialog(context, suggestion))
//              .then((year) {
//            if(year != null) {
//              //suggestion is school
//              //year is year
//              bloc.setYearAndSchool(suggestion, year);
//              Navigator.pushNamed(context, '/login');
//            }
//          });
//        }
//      },
//      itemBuilder: (BuildContext context, dynamic suggestion) {
//        if (suggestion is School) {
//          return ListTile(title: Text(suggestion.name));
//        }
//        throw Exception("suggestion is not a school.");
//      },
//    );
//  }

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
