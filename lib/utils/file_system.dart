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
    await loadBasePath();

    if (basePath != null && (PlatformHelper.isDesktop || Platform.isAndroid)) {
      await createFolder('');
    }

    await createFolder(recordingsFolder);
    await createFolder(soundLibrariesFolder);

    List<FileSystemEntity>? folderSoundLibraries =
        (await AppFileSystem.listFilesInFolder(
            AppFileSystem.soundLibrariesFolder));
    print(folderSoundLibraries);

    // print(await createFile('recordings.txt', recordingsFolder, 'Test Content'));
    // print(await listFilesInFolder(recordingsFolder));
  }

  static Future<void> loadBasePath() async {
    basePath = await getBasePath();
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

  static Future<String?> createFile(String fileName, String folderName,
      [String? content]) async {
    if (!(checkBasePath() && await checkPermission())) {
      return null;
    }

    File? file = File(
        '$basePath${Platform.pathSeparator}$folderName${Platform.pathSeparator}$fileName');

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

  static Future<FileSystemEntity> deleteFile(
      String fileName, String folderName) async {
    return await File(
            '$basePath${Platform.pathSeparator}$folderName${Platform.pathSeparator}$fileName')
        .delete();
  }

  static Future<File> renameFile(File file, String fileName) async {
    List<String> pathFilename = file.path.split(Platform.pathSeparator);
    pathFilename.removeLast();
    String path = pathFilename.join(Platform.pathSeparator);

    print(file.path);
    print(
        '$path${Platform.pathSeparator}$fileName.${getFileExtensionFromPath(file.path)}');

    return await file.rename(
        '$path${Platform.pathSeparator}$fileName.${getFileExtensionFromPath(file.path)}');
  }

  static Future<List<FileSystemEntity>?> listFilesInFolder(
      String folderName) async {
    if (!(checkBasePath() && await checkPermission())) {
      return null;
    }

    Directory? dir = Directory('$basePath${Platform.pathSeparator}$folderName');

    if (Platform.isMacOS) {
      return dir.listSync().where((file) => getFilenameFromPath(file.path) != '.DS_Store').toList();
    }

    return dir.listSync();
  }

  static Future<String> copyFileToFolder(File file, String folderName,
      [String? newFilename]) async {
    // if newFilename is set -> use it with the file extension from the original file
    // else use the original filename
    return (await file.copy(
            '$basePath${Platform.pathSeparator}$folderName${Platform.pathSeparator}${newFilename == null ? getFilenameFromPath(file.path) : '$newFilename.${getFileExtensionFromPath(file.path)}'}'))
        .path;
  }

  static String getFilenameFromPath(String path) {
    return path.split(Platform.pathSeparator).last;
  }

  static String? getFilenameWithoutExtension(String? path) {
    return path?.split(Platform.pathSeparator).last.split('.').first;
  }

  static String getFileExtensionFromPath(String path) {
    return path.split('.').last;
  }

  static Future<List?> getPlaybackFromRecording(String recordingTitle) async {
    List<FileSystemEntity>? folderSoundLibraries =
        (await AppFileSystem.listFilesInFolder(AppFileSystem.recordingsFolder));

    List? playbackAndTitle;

    folderSoundLibraries?.forEach((element) {
      String? filename = getFilenameWithoutExtension(element.path);
      if (filename == null) {
        return;
      }

      List<String> filenameSeparated = filename.split('${recordingTitle}_');

      // if title of recording will be found (at first position -> empty string)
      if (filenameSeparated[0].isEmpty) {
        if (filenameSeparated.length == 2) {
          // if playback title is not equal to the recording title
          // -> recording title found once (+ rest) -> array of 2 positions & last position equals to playback title + 'Playback'
          List<String> titlePlayback = filenameSeparated[1].split('_');
          if (titlePlayback.last == 'Playback') {
            // if separated playback + Playback title has 'Playback' at last position
            titlePlayback.removeLast();
            playbackAndTitle = [File(element.path), titlePlayback.join('_')];
          }
        } else if (filenameSeparated.length == 3) {
          // if playback title is equal to the title of the recording
          // title of recording will be found twice (+ rest) -> array of 3 positions & last position equals to 'Playback'
          if (filenameSeparated.last == 'Playback') {
            playbackAndTitle = [File(element.path), recordingTitle];
          }
        }
      }
    });

    return playbackAndTitle;
  }

  static Future<String?> savePlaybackFile(
      File playback, String recordingTitle) async {
    return await copyFileToFolder(playback, recordingsFolder,
        '${recordingTitle}_${getFilenameWithoutExtension(playback.path)}_Playback');
  }
}
