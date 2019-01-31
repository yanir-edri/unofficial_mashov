import 'package:flutter/material.dart';
import 'package:mashov_api/mashov_api.dart';

class Inject {
  static ApiController _controller = MashovApi.getController();
  static List<School> _schools = List();
  
  static Future<bool> setup() {
    return _controller.getSchools().then((result) {
      if(result.isSuccess) {
        _schools = result.value;
        return true;
      }
      return false;
    }).catchError((error) => false);
  }
  static List<School> get schools => _schools;

  //Wraps a widget with RTL directionality.
  static Widget rtl(Widget w) => Directionality(textDirection: TextDirection.rtl, child: w);
}