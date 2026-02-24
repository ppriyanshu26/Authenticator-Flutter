import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';
import 'runtime_key.dart';

class AppLifecycleManager extends WidgetsBindingObserver {
  static final AppLifecycleManager inst = AppLifecycleManager._internal();

  factory AppLifecycleManager() {
    return inst;
  }

  AppLifecycleManager._internal();

  AppLifecycleState? lastState;
  bool inBg = false;
  VoidCallback? onAppResumed;
  GlobalKey<NavigatorState>? navigatorKey;

  Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(this);

    if (Platform.isAndroid) {
      try {
        await ScreenProtector.preventScreenshotOn();
        await ScreenProtector.protectDataLeakageOn();
      } catch (e) {
        //
      }
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    lastState = state;

    if (state == AppLifecycleState.resumed && inBg) {
      handleAppResumedFromBackground();
      inBg = false;
    } else if (state == AppLifecycleState.paused) {
      handleAppPaused();
    }
  }

  void handleAppResumedFromBackground() {
    if (onAppResumed != null) {
      onAppResumed!();
    }
  }

  void handleAppPaused() {
    inBg = true;
    RuntimeKey.rawPassword = null;
  }

  bool get isAppActive => lastState == AppLifecycleState.resumed;
}
