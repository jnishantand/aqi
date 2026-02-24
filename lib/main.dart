import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getaqi/background/background_worker.dart';
import 'package:getaqi/l10n/app_localizations.dart';
import 'package:getaqi/providers/providers.dart';
import 'package:workmanager/workmanager.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  await Workmanager().registerPeriodicTask(
    "aqiTaskId",
    aqiTask,
    frequency: const Duration(minutes: 5),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSettingsAsync = ref.watch(userSettingsProvider);

    //preseting values from firebase user specific
    userSettingsAsync.whenData((data) {
      Future.microtask(() {
        final language = data['language'] ?? 'en';
        final darkMode = data['darkMode'] ?? false;

        if (ref.read(localeProvider) != Locale(language)) {
          ref.read(localeProvider.notifier).state = Locale(language);
        }

        final newTheme = darkMode ? ThemeMode.dark : ThemeMode.light;
        if (ref.read(themeProvider) != newTheme) {
          ref.read(themeProvider.notifier).state = newTheme;
        }
      });
    });

    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      darkTheme: ThemeData.dark(),
      themeMode: theme,
    );
  }
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    // Watch the Firestore user settings stream
    final userSettingsAsync = ref.watch(userSettingsProvider);

    userSettingsAsync.whenData((data) {
      final language = data['language'] ?? 'en';
      final darkMode = data['darkMode'] ?? false;

      Future.microtask(() {
        // Only update if different from current provider value
        if (ref.read(localeProvider) != Locale(language)) {
          ref.read(localeProvider.notifier).state = Locale(language);
        }

        final currentTheme = ref.read(themeProvider);
        final newTheme = darkMode ? ThemeMode.dark : ThemeMode.light;
        if (currentTheme != newTheme) {
          ref.read(themeProvider.notifier).state = newTheme;
        }
      });
    });

    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      darkTheme: ThemeData.dark(),
      themeMode: theme,
    );
  }
}
