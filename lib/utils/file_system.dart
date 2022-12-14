import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AppFileSystem {
  static Future<File?> filePicker(
      {required String title, List<String>? allowedExtensions}) async {
    FilePickerResult? result;
    if (allowedExtensions == null) {
      result = await FilePicker.platform.pickFiles(dialogTitle: title);
    } else {
      result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: allowedExtensions,
          dialogTitle: title);
    }

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path as String);
    } else {
      // User canceled the picker
      return null;
    }
  }

  static Future<String?> getBasePath() async {
    const folderName = 'VirKey';
    if (Platform.isAndroid) {
      // TODO: check correct path
      return '/storage/emulated/0/Documents/$folderName';
    } else if (Platform.isIOS) {
      // https://stackoverflow.com/a/74457977/17399214, 11.12.2022
      return (await getApplicationDocumentsDirectory()).path;
    } else if (Platform.isWindows) {
      return '${(await getApplicationDocumentsDirectory()).path}$platformDirectorySlash$folderName';
    } else if (Platform.isMacOS) {
      // TODO: check correct path
      return (await getApplicationDocumentsDirectory()).path;
    } else {
      return null;
    }
  }

  static String? basePath;
  static String recordingsFolder = 'Recordings';
  static String soundLibrariesFolder = 'Sound-Libraries';
  static String platformDirectorySlash = Platform.isWindows ? '\\' : '/';

  static Future<void> initFolders() async {
    basePath = await getBasePath();

    if (basePath != null && Platform.isWindows) {
      await createFolder('');
    }

    await createFolder(recordingsFolder);
    await createFolder(soundLibrariesFolder);

    // print(await createFile('recordings.txt', recordingsFolder, 'Test Content'));
    // print(await listFilesInFolder(recordingsFolder));
  }

  // check permission for accessing device storage
  static Future<bool> checkPermission() async {
    var status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    } else {
      return (await Permission.storage.request()).isGranted;
    }
  }

  // check if base path is set (/exists)
  static bool checkBasePath() {
    return basePath != null;
  }

  static Future<String?> createFolder(String folderName) async {
    if (!(checkBasePath() && await checkPermission())) {
      return null;
    }

    Directory? dir = Directory('$basePath$platformDirectorySlash$folderName');

    if ((await dir.exists())) {
      return dir.path;
    } else {
      dir.create();
      return dir.path;
    }
  }

  static Future<String?> createFile(String fileName, String path,
      [String? content]) async {
    if (!(checkBasePath() && await checkPermission())) {
      return null;
    }

    File? file = File(
        '$basePath$platformDirectorySlash$path$platformDirectorySlash$fileName');

    if ((await file.exists())) {
      return file.path;
    } else {
      file.create();
      if (content != null) {
        file.writeAsString(content);
      }
      return file.path;
    }
  }

  static Future<List<FileSystemEntity>?> listFilesInFolder(
      String folderName) async {
    if (!(checkBasePath() && await checkPermission())) {
      return null;
    }

    Directory? dir = Directory('$basePath$platformDirectorySlash$folderName');
    return dir.listSync();
  }
}
