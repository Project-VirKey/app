import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/features/cloud_synchronisation/cloud_provider.dart';
import 'package:virkey/features/midi_device/midi_device_provider.dart';
import 'package:virkey/features/piano/piano_provider.dart';
import 'package:virkey/features/recordings/recordings_provider.dart';
import 'package:virkey/features/settings/settings_provider.dart';
import 'package:virkey/routing/router.dart';
import 'package:virkey/utils/file_system.dart';
import 'package:virkey/utils/platform_helper.dart';
import 'package:window_size/window_size.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/cloud_synchronisation/firestore.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // define minimal window size for desktop
  WidgetsFlutterBinding.ensureInitialized();

  if (PlatformHelper.isDesktop) {
    setWindowMinSize(const Size(830, 580));
  }

  // initialize folders for user content (recordings, ...)
  await AppFileSystem.initFolders();

  // cloud-synchronization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // reload authentication on start-up
  try {
    await FirebaseAuth.instance.currentUser?.reload();
  } catch (e) {
    print(e);
  }

  // load firestore document
  await AppFirestore.initialLoad();

  // run the app
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ChangeNotifierProvider(create: (_) => RecordingsProvider()),
      ChangeNotifierProvider(create: (_) => PianoProvider()),
      ChangeNotifierProxyProvider<SettingsProvider, CloudProvider>(
          create: (BuildContext context) =>
              CloudProvider(
                  Provider.of<SettingsProvider>(context, listen: false)),
          update: (BuildContext context, SettingsProvider settingsProvider,
              CloudProvider? cloudProvider) {
            cloudProvider?.setSettingsProvider(settingsProvider);
            return cloudProvider ?? CloudProvider(settingsProvider);
          })
    ],
    child: const App(),
  ));

  // AppMidiTest.test();
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
