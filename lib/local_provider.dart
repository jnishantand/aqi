// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// final localeProvider = StateNotifierProvider<LocaleController, Locale?>(
//   (ref) => LocaleController(),
// );
//
// class LocaleController extends StateNotifier<Locale?> {
//   LocaleController() : super(null) {
//     loadLocale();
//   }
//
//   Future<void> loadLocale() async {
//     final prefs = await SharedPreferences.getInstance();
//     final code = prefs.getString('lang_code');
//     if (code != null) {
//       state = Locale(code);
//     }
//   }
//
//   Future<void> switchLanguage(String code) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('lang_code', code);
//
//     state = Locale(code);
//   }
// }
