import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'constant.dart';

class FolderManager {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<String> get appRoot async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<String> get tempFolderPath async {
    final path = await _localPath;
    String pathStr = '$path/${Constant.tempFolderSubPath}/';
    await Directory(pathStr).create(recursive: true);
    return pathStr;
  }

  Future<String> get createFolderWithCurrentDatetimePath async {
    final appDocsDirPath = await _localPath;
    var projectRoot = Directory("$appDocsDirPath/Projects");
    projectRoot.createSync();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd-kk-mm').format(now);
    var firstPath = projectRoot.path + "/$formattedDate/";
    await Directory(firstPath).create(recursive: true);
    // Name the file, create the file, and save in byte form.
    return firstPath;
  }
}
