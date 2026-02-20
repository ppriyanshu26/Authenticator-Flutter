import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'screens/startup_screen.dart';
import 'utils/storage.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setMinimumSize(const Size(400, 600));
      await windowManager.setSize(const Size(700, 800));
      await windowManager.show();
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  Future<void> loadTheme() async {
    final isDark = await Storage.isDarkMode();
    setState(() {
      themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void toggleTheme() async {
    final isDark = themeMode == ThemeMode.dark;
    await Storage.setDarkMode(!isDark);
    setState(() {
      themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1E88E5);
    const accentOrange = Color(0xFFFF7043);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: primaryBlue,
        colorScheme: const ColorScheme.light(
          primary: primaryBlue,
          secondary: accentOrange,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accentOrange,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: primaryBlue,
        colorScheme: const ColorScheme.dark(
          primary: primaryBlue,
          secondary: accentOrange,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accentOrange,
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: themeMode,
      home: StartupScreen(onToggleTheme: toggleTheme),
    );
  }
}
