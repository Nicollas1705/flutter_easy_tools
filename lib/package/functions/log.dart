import 'dart:developer';

void p(dynamic object, {Object? error, StackTrace? stackTrace}) {
  final name = DateTime.now().toString().split(" ")[1];
  log("$object", name: name, error: error, stackTrace: stackTrace);
}
