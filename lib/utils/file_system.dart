import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:virkey/utils/platform_helper.dart';

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
      // folder: [Phone]/Documents/VirKey/
      return '/storage/emulated/0/Documents/$folderName';
    } else if (Platform.isIOS) {
      // folder: [Application]/Data/Application/[...]/Documents/VirKey

      // add key/value in Info.plist to view application folder in files app on iOS
      // key: UISupportsDocumentBrowser | value: true
      // ./ios/Runner/Info.plist
      // https://stackoverflow.com/a/74457977/17399214, 11.12.2022
      return (await getApplicationDocumentsDirectory()).path;
    } else if (Platform.isWindows) {
      // folder: Documents\VirKey\
      return '${(await getApplicationDocumentsDirectory()).path}${Platform.pathSeparator}$folderName';
    } else if (Platform.isMacOS) {
      // folder: /Applications/VirKey/

      // remove standard app-sandbox security option to create folders/files outside of application folder
      // ./macos/Runner/: DebugProfile.entitlements & Release.entitlements
      // https://stackoverflow.com/a/70557520/17399214, 14.12.2022
      // https://developer.apple.com/documentation/security/app_sandbox, 14.12.2022
      return '/Applications/$folderName';
    } else {
      return null;
    }
  }

  static String? basePath;
  static String recordingsFolder = 'Recordings';
  static String soundLibrariesFolder = 'Sound-Libraries';

  static Future<void> initFolders() async {
    basePath = await getBasePath();

    if (basePath != null && (PlatformHelper.isDesktop || Platform.isAndroid)) {
      await createFolder('');
    }

    await createFolder(recordingsFolder);
    await createFolder(soundLibrariesFolder);

    // print(await createFile('recordings.txt', recordingsFolder, 'Test Content'));
    // print(await listFilesInFolder(recordingsFolder));
  }

  // check permission for accessing device storage
  static Future<bool> checkPermission() async {
    if (PlatformHelper.isDesktop) {
      return true;
    }

    // check Permission for storage (iOS) or for manageExternalStorage (android)
    // var status = Platform.isIOS ? await Permission.storage.status : await Permission.manageExternalStorage.status;
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

    Directory? dir = Directory('$basePath${Platform.pathSeparator}$folderName');

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
        '$basePath${Platform.pathSeparator}$path${Platform.pathSeparator}$fileName');

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

    Directory? dir = Directory('$basePath${Platform.pathSeparator}$folderName');
    return dir.listSync();
  }
}
