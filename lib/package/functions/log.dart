part of flutter_easy_tools;

void p(dynamic object, {Object? error, StackTrace? stackTrace}) {
  final name = DateTime.now().toString().split(" ")[1];
  log("$object", name: name, error: error, stackTrace: stackTrace);
}
