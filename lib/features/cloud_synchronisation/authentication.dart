import 'package:firebase_auth/firebase_auth.dart';

class AppAuthentication {
  static User? user() {
    return FirebaseAuth.instance.currentUser;
  }

  static Future<List> logIn(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
      return [
        true,
        '${FirebaseAuth.instance.currentUser?.displayName ?? 'User'} is logged in.'
      ];
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return [false, 'No user found for that email.'];
      } else if (e.code == 'wrong-password') {
        return [false, 'Wrong password provided for that user.'];
      }
      return [false, e.code];
    }
  }

  static void logout() {
    FirebaseAuth.instance.signOut();
  }

  static Future<List> signUp(
      String username, String emailAddress, String password) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      await FirebaseAuth.instance.currentUser?.updateDisplayName(username);
      return await sendVerificationEmail();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return [false, 'The password provided is too weak.'];
      } else if (e.code == 'email-already-in-use') {
        return [false, 'The account already exists for that email.'];
      }
      return [false, e.code];
    } catch (e) {
      return [false, e];
    }
  }

  static Future<List> sendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      return [true, 'Verify E-Mail sent!'];
    } on FirebaseAuthException catch (e) {
      return [false, e.code];
    } catch (e) {
      return [false, e];
    }
  }

  static Future<List> sendResetPasswordEmail(String emailAddress) async {
    try {
      if (emailAddress.isEmpty) {
        return [false, 'Enter your E-Mail!'];
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailAddress);
      return [true, 'Rest E-mail sent!'];
    } on FirebaseAuthException catch (e) {
      return [false, e.code];
    } catch (e) {
      return [false, e];
    }
  }

  static Future<List> deleteAccount(String password) async {
    try {
      await reauthenticate(password);
      await FirebaseAuth.instance.currentUser?.delete();
      return [true, 'Account deleted!'];
    } on FirebaseAuthException catch (e) {
      return [false, e.code];
    } catch (e) {
      return [false, e];
    }
  }

  static Future<void> reauthenticate(String password) async {
    await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(
        EmailAuthProvider.credential(
            email: FirebaseAuth.instance.currentUser?.email ?? '',
            password: password));
  }

  static Future<List> updatePassword(
      String password, String newPassword) async {
    try {
      await reauthenticate(password);
      await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
      logout();
      return [true, 'Password updated!'];
    } on FirebaseAuthException catch (e) {
      return [false, e.code];
    } catch (e) {
      return [false, e];
    }
  }

  static Future<List> updateEmail(String newEmail, String password) async {
    try {
      await reauthenticate(password);
      await FirebaseAuth.instance.currentUser?.updateEmail(newEmail);
      logout();
      return [true, 'E-Mail updated!'];
    } on FirebaseAuthException catch (e) {
      return [false, e.code];
    } catch (e) {
      return [false, e];
    }
  }

  static Future<List> updateUsername(String newUsername) async {
    try {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(newUsername);
      return [true, 'Username updated!'];
    } on FirebaseAuthException catch (e) {
      return [false, e.code];
    } catch (e) {
      return [false, e];
    }
  }
}
