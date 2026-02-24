import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:getaqi/providers/providers.dart';
import '../../l10n/app_localizations.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final theme = ref.watch(themeProvider);
    final isEnglish = locale.languageCode == 'en';
    final isDarkMode = theme == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text("Language"),
              trailing: Switch(
                value: isEnglish,
                onChanged: (val) async {
                  ref.read(localeProvider.notifier).state = Locale(
                    val ? 'en' : 'hi',
                  );

                  //setting also in backend
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({'language': val ? 'en' : 'hi'});
                  }
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: Text(AppLocalizations.of(context)!.darkMode),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (val) async {
                  ref.read(themeProvider.notifier).state = val
                      ? ThemeMode.dark
                      : ThemeMode.light;

                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({'darkMode': val});
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
