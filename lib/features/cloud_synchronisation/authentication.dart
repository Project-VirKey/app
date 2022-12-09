import 'package:firebase_auth/firebase_auth.dart';

class AppAuthentication {
  static bool loggedIn = false;

  static void checkAuthStatus() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        loggedIn = false;
      } else {
        print(user);
        print('User is signed in!');
        loggedIn = true;
      }
    });
  }

  static Future<void> logIn(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  static void logout() {
    FirebaseAuth.instance.signOut();
  }
}
