// Providers
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:getaqi/extras/appPath.dart';
import 'package:getaqi/features/sensor_read/view/sensor_view.dart';
import 'package:getaqi/features/tax80g/view/tax_80g_screen.dart';
import 'package:getaqi/riverpod_clean/user_ui/users_list.dart';
import 'package:getaqi/ui/homePage.dart';
import 'package:getaqi/ui/login/login.dart';
import 'package:getaqi/ui/logs/log_screen.dart';
import 'package:getaqi/ui/news/news.dart';
import 'package:getaqi/ui/profile/profile.dart';
import 'package:getaqi/ui/setting/setting_screen.dart';
import 'package:go_router/go_router.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// StreamProvider to listen to Firestore for user settings
final userSettingsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final authState = ref.watch(authStateProvider); // <-- Watch login/logout
  final user = authState.value;
  if (user == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.data() ?? {});
});

// GoRouter
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    redirect: (context, state) {
      final user = authState.value;
      final isLoginRoute = state.matchedLocation == AppPath.login;

      if (user == null) return isLoginRoute ? null : AppPath.login;
      if (isLoginRoute) return AppPath.homePage;
      return null;
    },
    routes: [
      GoRoute(path: AppPath.tax80GScreen, builder: (c, s) => Tax80GScreen()),
      GoRoute(path: AppPath.homePage, builder: (c, s) => HomePage()),
      GoRoute(path: AppPath.login, builder: (c, s) => LoginScreen()),
      GoRoute(path: AppPath.setting, builder: (c, s) => const SettingScreen()),
      GoRoute(path: AppPath.profile, builder: (c, s) => Profile()),
      GoRoute(path: AppPath.logScreen, builder: (c, s) => LogScreen()),
      GoRoute(path: AppPath.userScreen, builder: (c, s) => UsersList()),
      GoRoute(path: AppPath.sensorScreen, builder: (c, s) => SensorScreen()),

      GoRoute(
        path: AppPath.news,
        builder: (c, s) => Scaffold(
          appBar: AppBar(title: Text("News")),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(children: [AqiNewsWidget()]),
            ),
          ),
        ),
      ),
    ],
  );
});
