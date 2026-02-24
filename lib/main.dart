import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'screens/startup_screen.dart';
import 'utils/storage.dart';
import 'utils/app_lifecycle_manager.dart';
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

  // Initialize app lifecycle manager for security features
  final lifecycleManager = AppLifecycleManager();
  await lifecycleManager.initialize();

  runApp(MyApp(lifecycleManager: lifecycleManager));
}

class MyApp extends StatefulWidget {
  final AppLifecycleManager lifecycleManager;

  const MyApp({super.key, required this.lifecycleManager});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.light;
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    loadTheme();
    _setupLifecycleCallbacks();
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

  /// Setup lifecycle callbacks for security
  void _setupLifecycleCallbacks() {
    widget.lifecycleManager.navigatorKey = navigatorKey;
    widget.lifecycleManager.onAppResumed = _handleAppResumed;
  }

  /// Handle when app resumes from background
  void _handleAppResumed() {
    debugPrint('Forcing user to re-authenticate');
    // Navigate back to startup screen which will route to login
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/startup',
      (route) => false,
    );
  }

  @override
  void dispose() {
    widget.lifecycleManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1E88E5);
    const accentOrange = Color(0xFFFF7043);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      routes: {
        '/startup': (context) => StartupScreen(onToggleTheme: toggleTheme),
      },
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
