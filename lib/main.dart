import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/features/cloud_synchronisation/cloud_provider.dart';
import 'package:virkey/features/settings/settings_provider.dart';
import 'package:virkey/routing/router.dart';
import 'package:virkey/utils/platform_helper.dart';
import 'package:window_size/window_size.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // define minimal window size for desktop
  WidgetsFlutterBinding.ensureInitialized();

  if (PlatformHelper.isDesktop) {
    setWindowMinSize(const Size(830, 580));
  }

  // run the app
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ChangeNotifierProvider(create: (_) => CloudProvider())
    ],
    child: const App(),
  ));

  // cloud-synchronization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // create & retrieve application directory for user generated files
  print(await createFolder());
}

Future<String> createFolder() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }

  // final dir = Directory(
  //     '${(Platform.isAndroid ? (await getExternalStorageDirectories(type: StorageDirectory.documents)) //FOR ANDROID
  //             : await getApplicationSupportDirectory() //FOR IOS
  //         )}/$cow');

  final Directory dir = Directory('/storage/emulated/0/Documents/VirKey');

  if ((await dir.exists())) {
    return dir.path;
  } else {
    dir.create();
    return dir.path;
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      title: 'VirKey',
      theme: ThemeData(
        primaryColor: AppColors.secondary,
        primarySwatch: Colors.grey,
        fontFamily: AppFonts.primary,
      ),
    );
  }
}
