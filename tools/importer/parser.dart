import 'dart:io';

class Parser {
  static Future<String> read(File file) async {
    return file.readAsString();
  }
}
