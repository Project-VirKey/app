import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:virkey/utils/file_system.dart';

class AppCloudStorage {
  /* rule for cloud storage -> permission for all users to access all files
    rules_version = '2';
    service firebase.storage {
      match /b/{bucket}/o {
        match /{allPaths=**} {
          allow read, write: if
              request.time < timestamp.date(2023, 12, 16);
        }
      }
    }
   */

  // https://firebase.google.com/docs/rules/basics?authuser=1#content-owner_only_access
  /* rule for cloud storage -> permission only for the folder with the userId
    rules_version = '2';
    service firebase.storage {
      match /b/{bucket}/o {
        // Files look like: "<UID>/path/to/file.txt"
        match /{userId}/{allPaths=**} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
      }
    }
   */

  static Reference storageRef = FirebaseStorage.instance.ref();

  static Future<void> initialLoad() async {
    if (FirebaseAuth.instance.currentUser?.uid == null) {
      return;
    }

    print('cloud storage initialLoad');

    storageRef =
        storageRef.child(FirebaseAuth.instance.currentUser?.uid as String);

    // String testFileName = 'winning-elevation-111355.mp3';

    // downloadFile(testFileName, AppFileSystem.soundLibrariesFolderPath);

    // print(await uploadFromFile(
    //     '${AppFileSystem.soundLibrariesFolderPath}$testFileName'));

    // listAllFiles();

    // deleteFile(testFileName);
  }

  static Future<void> downloadFile(
      String fileName, String destinationPath) async {
    final cloudFileRef = storageRef.child(fileName);
    final file = File('$destinationPath$fileName');

    final downloadTask = cloudFileRef.writeToFile(file);

    downloadTask.snapshotEvents.listen((taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          // TODO: Handle this case.
          break;
        case TaskState.paused:
          // TODO: Handle this case.
          break;
        case TaskState.success:
          // TODO: Handle this case.
          break;
        case TaskState.canceled:
          // TODO: Handle this case.
          break;
        case TaskState.error:
          // TODO: Handle this case.
          break;
      }
    });
  }

  static Future<String?> uploadFromFile(String filePath) async {
    File file = File(filePath);

    try {
      Reference destinationReference =
          storageRef.child(AppFileSystem.getFilenameFromPath(filePath));

      await destinationReference.putFile(file);
      return destinationReference.name;
    } on FirebaseException catch (e) {
      print(e);
      return null;
    }

    // TODO: snapshotEvents
  }

  static Future<void> deleteFile(String fileName) async {
    // Create a reference to the file to delete
    Reference desertRef = storageRef.child(fileName);

    // Delete the file
    await desertRef.delete();
  }

  static Future<void> listAllFiles() async {
    final listResult = await storageRef.listAll();
    for (var prefix in listResult.prefixes) {
      // The prefixes under storageRef.
      // You can call listAll() recursively on them.
      print('prefix - $prefix');

      // a prefix is a path, which can contain items
    }
    for (var item in listResult.items) {
      // The items (/ files) under storageRef.
      print('item - $item');
    }
  }
}
