import 'package:firebase_auth/firebase_auth.dart';

class AppAuthentication {
  static bool loggedIn = false;

  // static void checkAuthStatus() {
  //   FirebaseAuth.instance.authStateChanges().listen((User? user) {
  //     if (user == null) {
  //       print('User is currently signed out!');
  //       loggedIn = false;
  //     } else {
  //       print(user);
  //       print('User is signed in!');
  //       loggedIn = true;
  //     }
  //   });
  // }

  static Future<List> logIn(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
      return [true, '${credential.user?.displayName ?? 'User'} is logged in.'
      ];
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        return [false, 'No user found for that email.'];
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        return [false, 'Wrong password provided for that user.'];
      }
      return [false, e.code];
    }
  }

  static void logout() {
    FirebaseAuth.instance.signOut();
  }
}
