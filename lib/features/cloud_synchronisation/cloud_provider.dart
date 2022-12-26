import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CloudProvider extends ChangeNotifier {
  final Cloud _cloud = Cloud(loggedIn: false);

  Cloud get cloud => _cloud;

  CloudProvider() {
    checkAuthStatus();

    // _cloud.db = FirebaseFirestore.instance;
  }

  void checkAuthStatus() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        _cloud.loggedIn = false;
      } else {
        // do not print user on windows => causes exception
        // print(user);
        print('User is signed in!');
        _cloud.loggedIn = true;
        _cloud.user = user;
      }
      notifyListeners();
    });
  }

  void reload() async {
    FirebaseAuth.instance.currentUser?.reload();
    notifyListeners();
  }
}

class Cloud {
  Cloud({required this.loggedIn});

  bool loggedIn;
  User? user;
}
