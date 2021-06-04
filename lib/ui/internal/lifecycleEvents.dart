// Flutter
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Add this to any Widget in the App to detect if
// the app is inactive, paused, detached or resumed
class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallBack;
  final AsyncCallback suspendingCallBack;

  static bool isAppActive = true;

  LifecycleEventHandler({
    this.resumeCallBack,
    this.suspendingCallBack
  });

  @override
  Future<Null> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        isAppActive = true;
        if (resumeCallBack != null) {
          await resumeCallBack();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        isAppActive = false;
        if (suspendingCallBack != null) {
          await suspendingCallBack();
        }
        break;
    }
  }
}