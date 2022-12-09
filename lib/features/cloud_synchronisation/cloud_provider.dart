import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class CloudProvider extends ChangeNotifier {
  Cloud _cloud = Cloud(loggedIn: false);

  Cloud get cloud => _cloud;

  CloudProvider() {
    checkAuthStatus();
  }

  void checkAuthStatus() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        _cloud.loggedIn = false;
      } else {
        print(user);
        print('User is signed in!');
        _cloud.loggedIn = true;
      }
      notifyListeners();
    });
  }
}

class Cloud {
  Cloud({required this.loggedIn});

  bool loggedIn = false;
}
