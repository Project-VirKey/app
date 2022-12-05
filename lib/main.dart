import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virkey/constants/colors.dart';
import 'package:virkey/constants/fonts.dart';
import 'package:virkey/routing/router.dart';
import 'package:virkey/utils/platform_helper.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (PlatformHelper.isDesktop) {
    setWindowMinSize(const Size(830, 580));
  }

  runApp(const App());
}
//
// Future<String> createFolder(String cow) async {
//   final dir = Directory((Platform.isAndroid
//       ? await getExternalStorageDirectory() //FOR ANDROID
//       : await getApplicationSupportDirectory() //FOR IOS
//   )!
//       .path + '/$cow');
//   var status = await Permission.storage.status;
//   if (!status.isGranted) {
//     await Permission.storage.request();
//   }
//   if ((await dir.exists())) {
//     return dir.path;
//   } else {
//     dir.create();
//     return dir.path;
//   }
// }

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
