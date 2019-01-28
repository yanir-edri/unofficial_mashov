import 'dart:io';
import 'package:path_provider/path_provider.dart';

final filesController = new FilesController._new();

class FilesController {
  Directory _messagesDir;
  Directory _root;

  void _initStorage() {
    getApplicationDocumentsDirectory().then((directory) {
      _root = directory;
      _messagesDir = Directory("${_root.path}/messages");
      _messagesDir.exists().then((isExist) {
        if (!isExist) _messagesDir.create();
      });
    });
  }

  FilesController._new() {
    _initStorage();
  }

  //Returns file with the name given, false otherwise
  File getFile(String name) {
    //if contains file
    File file = File("${_root.path}/$name");
    if(!file.existsSync()) {
      file.createSync();
    }
    return file;
  }
  File getConversationFile(String conversationId) {
    File file = File("${_messagesDir.path}/$conversationId.json");
    if(!file.existsSync()) {
      file.createSync();
    }
    return file;
  }

  void clear() {
    _root.delete(recursive: true);
    _root.create().then((dir) => _messagesDir.create());
  }
}
