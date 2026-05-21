import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/theme.dart';
import 'utils/storage.dart';
import 'screens/screens.dart';

// Global theme notifier — 'system' means follow device setting
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();

  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('pref_theme_mode') ?? 'system';
  themeNotifier.value = saved == 'dark' ? ThemeMode.dark
      : saved == 'light' ? ThemeMode.light
      : ThemeMode.system;

  runApp(const FarmConnectApp());
}

class FarmConnectApp extends StatelessWidget {
  const FarmConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) => MaterialApp(
        title: 'FarmConnect',
        debugShowCheckedModeBanner: false,
        theme:     buildAppTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: mode,
        initialRoute: _initialRoute(),
        routes: {
          '/auth':         (ctx) => AuthScreen(onAuth: () {
            final counties = StorageService.instance.getCounties();
            Navigator.pushReplacementNamed(ctx, counties.isEmpty ? '/county-setup' : '/home');
          }),
          '/county-setup': (_) => const CountySetupScreen(),
          '/home':         (_) => const HomeScreen(),
        },
      ),
    );
  }

  String _initialRoute() {
    final user = StorageService.instance.getCurrentUser();
    if (user == null) return '/auth';
    final counties = StorageService.instance.getCounties();
    return counties.isEmpty ? '/county-setup' : '/home';
  }
}
