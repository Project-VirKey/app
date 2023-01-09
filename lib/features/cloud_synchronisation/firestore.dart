import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppFirestore {
// update firebase access rules
// only the user who created the document is able to delete & update his own document
// https://stackoverflow.com/a/57511389/17399214, 19.12.2022
/*
    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        match /users/{userId} {
          allow read, update, delete: if request.auth.uid == userId;
          allow create: if request.auth.uid != null;
        }
      }
    }
   */

  static FirebaseFirestore? db = FirebaseFirestore.instance;

  static Map<String, dynamic>? document;

  static Future<bool> checkUserDocumentExists() async {
    // check if document exists
    // https://stackoverflow.com/a/62735067/17399214, 19.12.2022
    return (await db
                ?.collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid as String)
                .get())
            ?.exists ??
        false;
  }

  static void createDocument(Map<String, dynamic> document) {
    // create document with userId (uid) as title
    // https://stackoverflow.com/a/61724209/17399214, 19.12.2022
    db
        ?.collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid as String)
        .set(document);
  }

  static Future<Map<String, dynamic>?> getDocument() async {
    return (await db
            ?.collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .get())
        ?.data() as Map<String, dynamic>;
  }

  static Future<void> initialLoad() async {
    document = (await getDocument())!;

    // if (await checkUserDocumentExists()) {
    //   document = (await getDocument())!;
    // } else {
    //   document = defaultDocument;
    //   createDocument(defaultDocument);
    // }
  }
}
