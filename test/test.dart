main() {
  f().listen((i) => print("stopping animation"));
  print("animation is running");
}

Stream<int> f() async* {
  await Future.delayed(Duration(seconds: 2));
  yield 3;
}
