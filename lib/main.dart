import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/features/app_introduction/introduction_provider.dart';
import 'package:virkey/features/cloud_synchronisation/cloud_provider.dart';
import 'package:virkey/features/midi_device/midi_device_provider.dart';
import 'package:virkey/features/piano/piano_provider.dart';
import 'package:virkey/features/recordings/recordings_provider.dart';
import 'package:virkey/features/settings/settings_provider.dart';
import 'package:virkey/routing/router.dart';
import 'package:virkey/utils/file_system.dart';
import 'package:virkey/utils/platform_helper.dart';
import 'package:window_size/window_size.dart';
import 'features/settings/settings_shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (PlatformHelper.isDesktop) {
    // define minimal window size for desktop
    if (PlatformHelper.isDesktop) {
      setWindowMinSize(const Size(830, 580));
    }
  }

  // initialize folders for user content (recordings, ...)
  await AppFileSystem.initFolders();

  AppSharedPreferences.loadedSharedPreferences =
      await AppSharedPreferences.loadData();

  // run the app
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ChangeNotifierProvider(create: (_) => IntroductionProvider()),
      ChangeNotifierProxyProvider<SettingsProvider, RecordingsProvider>(
          create: (BuildContext context) => RecordingsProvider(
              Provider.of<SettingsProvider>(context, listen: false)),
          update: (BuildContext context, SettingsProvider settingsProvider,
              RecordingsProvider? recordingsProvider) {
            recordingsProvider?.setSettingsProvider(settingsProvider);
            return recordingsProvider ?? RecordingsProvider(settingsProvider);
          }),
      ChangeNotifierProxyProvider<SettingsProvider, PianoProvider>(
          create: (BuildContext context) => PianoProvider(
              Provider.of<SettingsProvider>(context, listen: false)),
          update: (BuildContext context, SettingsProvider settingsProvider,
              PianoProvider? pianoProvider) {
            pianoProvider?.setSettingsProvider(settingsProvider);
            return pianoProvider ?? PianoProvider(settingsProvider);
          }),
      ChangeNotifierProxyProvider<PianoProvider, MidiDeviceProvider>(
          create: (BuildContext context) => MidiDeviceProvider(
              Provider.of<PianoProvider>(context, listen: false)),
          update: (BuildContext context, PianoProvider pianoProvider,
              MidiDeviceProvider? midiDeviceProvider) {
            midiDeviceProvider?.setPianoProvider(pianoProvider);
            return midiDeviceProvider ?? MidiDeviceProvider(pianoProvider);
          }),
      ChangeNotifierProxyProvider<SettingsProvider, CloudProvider>(
          create: (BuildContext context) => CloudProvider(
              Provider.of<SettingsProvider>(context, listen: false)),
          update: (BuildContext context, SettingsProvider settingsProvider,
              CloudProvider? cloudProvider) {
            cloudProvider?.setSettingsProvider(settingsProvider);
            return cloudProvider ?? CloudProvider(settingsProvider);
          })
    ],
    child: const App(),
  ));
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
