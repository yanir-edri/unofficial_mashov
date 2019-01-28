import 'package:mashov_api/mashov_api.dart';

class Inject {
  static ApiController _controller = MashovApi.getController();
  static List<School> _schools = List();
  static void setup() async {
    _schools = await _controller.getSchools().then((result) {
      if(result.isSuccess) return result.value;
      else throw Exception("cannot fetch schools");
    });
  }
  static List<School> get schools => _schools;
}