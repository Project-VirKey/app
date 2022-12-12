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

  static Future<String?> basePath() async {
    const folderName = 'VirKey';
    if (Platform.isAndroid) {
      // TODO: check correct path
      return '/storage/emulated/0/Documents/$folderName';
    } else if (Platform.isIOS) {
      // https://stackoverflow.com/a/74457977/17399214, 11.12.2022
      return (await getApplicationDocumentsDirectory()).path;
    } else if (Platform.isWindows) {
      // TODO: check correct path
      return '/storage/emulated/0/Documents/$folderName';
    } else if (Platform.isMacOS) {
      // TODO: check correct path
      return (await getApplicationDocumentsDirectory()).path;
    } else {
      return null;
    }
  }

  static Future<String?> createFolder() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    String? path = await basePath();

    if (path == null) {
      return null;
    }

    Directory? dir = Directory(path);

    if ((await dir.exists())) {
      return dir.path;
    } else {
      dir.create();
      return dir.path;
    }
  }
}
