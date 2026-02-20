import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getaqi/extras/appPath.dart';
import 'package:getaqi/providers/countProviders/counter_provider.dart';
import 'package:getaqi/screens/one_tap_auth_screen.dart';
import 'package:getaqi/ui/homePage.dart' show HomePage;
import 'package:getaqi/ui/login/login.dart' hide PNVDemoScreen;
import 'package:getaqi/ui/users/users_list.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';

Future<void> main() async {
  // ✅ THIS LINE IS CRITICAL - Initialize Flutter binding first
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Then initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Finally run your app
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      routerConfig: _goRouter,
    );
  }
}

final GoRouter _goRouter = GoRouter(
  routes: [
    GoRoute(path: AppPath.homePage, builder: (c, s) => HomePage()),
    GoRoute(path: AppPath.userPage, builder: (c, s) => UsersList()),
    GoRoute(path: AppPath.login, builder: (c, s) => PNVDemoScreen()),
    GoRoute(path: AppPath.login_bloc, builder: (c, s) => PNVDemoScreen()),


  ],
);
