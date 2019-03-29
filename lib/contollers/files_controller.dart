import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

final filesController = new FilesController._new();

class FilesController {
  Directory _messagesDir;
  Directory _contactsDir;
  Directory _root;

  Future<bool> initStorage() {
    print("storage is initializing");
    return getApplicationDocumentsDirectory()
        .then((directory) {
      _root = directory;
      _messagesDir = Directory("${_root.path}/messages");
      _messagesDir.exists().then((isExist) {
        if (!isExist) _messagesDir.create();
      });
      _contactsDir = Directory("${_root.path}/contacts");
      _contactsDir.exists().then((isExist) {
        if (!isExist) _contactsDir.create();
      });
      print("storage is done initializing");
    })
        .then((n) => true)
        .catchError((error) => false);
  }

  FilesController._new();

  //Returns file with the name given,
  Future<File> getFile(String name) async {
    //if contains file
    File file = File("${_root.path}/$name");
    return file.exists().then((exists) {
      if (exists) return file;
      return file.create();
    });
  }

  Future<File> getConversationFile(String conversationId) async {
    File file = File("${_messagesDir.path}/$conversationId.json");
    if (!file.existsSync()) {
      file.createSync();
    }
    return file;
  }

  Future<File> getContactsGroupFile(String groupId) async {
    File file = File("${_contactsDir.path}/$groupId.json");

    if (!file.existsSync()) {
      file.createSync();
    }
    return file;
  }

  Future<bool> clear() async =>
      _root
          .delete(recursive: true)
          .then((v) => _root.create())
          .then((v) => _messagesDir.create())
          .then((v) => initStorage())
          .catchError((error) {
        print(error);
        return false;
      });
}
