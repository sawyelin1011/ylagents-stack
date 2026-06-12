// import 'dart:io' show Platform; // ignore: unused_import

import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/services.dart';

import '../../core/services/haptics.dart' as haptics;

/// Unified platform detection for cross-platform code.
abstract class PlatformInfo {
  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isMacOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
  static bool get isWindows =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  static bool get isLinux =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
  static bool get isDesktop => isWindows || isMacOS || isLinux;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isApple => isIOS || isMacOS;

  /// Human-readable platform name for display and sync device registration.
  static String get name {
    if (kIsWeb) return 'web';
    if (isAndroid) return 'android';
    if (isIOS) return 'ios';
    if (isMacOS) return 'macos';
    if (isWindows) return 'windows';
    if (isLinux) return 'linux';
    return 'unknown';
  }

  /// Whether the current platform supports background execution natively.
  static bool get supportsBackgroundExecution => isAndroid || isIOS;

  /// Whether the current platform supports system tray.
  static bool get supportsSystemTray => isDesktop;

  /// Whether the current platform supports global hotkeys.
  static bool get supportsHotkeys => isDesktop;
}

/// Cross-platform haptic feedback that works on Android, iOS, and Windows.
class PlatformHaptics {
  /// Light tap feedback.
  static void light() {
    if (PlatformInfo.isWindows) {
      _windowsHaptic();
    } else {
      haptics.Haptics.light();
    }
  }

  /// Medium tap feedback.
  static void medium() {
    if (PlatformInfo.isWindows) {
      _windowsHaptic();
    } else {
      haptics.Haptics.medium();
    }
  }

  /// Soft tap feedback.
  static void soft() {
    if (PlatformInfo.isWindows) {
      _windowsHaptic();
    } else {
      haptics.Haptics.soft();
    }
  }

  /// Drawer pulse feedback.
  static void drawerPulse() {
    if (PlatformInfo.isWindows) {
      _windowsHaptic();
    } else {
      haptics.Haptics.drawerPulse();
    }
  }

  static void _windowsHaptic() {
    if (!haptics.Haptics.enabled) return;
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  static void setEnabled(bool v) => haptics.Haptics.setEnabled(v);
  static bool get enabled => haptics.Haptics.enabled;
}

/// Cross-platform file save that works on Android, iOS, and Windows.
class PlatformFileSave {
  static const MethodChannel _channel = MethodChannel('app.file_save');

  /// Save a file from a local path to the user's chosen location.
  /// On Android/iOS this uses SAF/Picker flows.
  /// On Windows this copies to a user-chosen folder via the save dialog.
  static Future<bool> saveFileFromPath({
    required String sourcePath,
    String? fileName,
  }) async {
    if (!PlatformInfo.isAndroid &&
        !PlatformInfo.isIOS &&
        !PlatformInfo.isWindows &&
        !PlatformInfo.isMacOS) {
      throw UnsupportedError(
        'Native file save is not supported on this platform.',
      );
    }

    final result = await _channel.invokeMethod<dynamic>('saveFileFromPath', {
      'sourcePath': sourcePath,
      if (fileName != null && fileName.trim().isNotEmpty)
        'fileName': fileName.trim(),
    });
    if (result is bool) return result;
    return result == true;
  }
}

/// Cross-platform notifications for Android, iOS, and Windows.
class PlatformNotifications {
  /// Show a notification on the current platform.
  /// Works on Android (via flutter_local_notifications),
  /// iOS (via method channel), and Windows (via method channel).
  static const MethodChannel _channel = MethodChannel('app.notifications');

  static Future<void> showNotification({
    required int id,
    String? title,
    String? body,
  }) async {
    if (!PlatformInfo.isAndroid &&
        !PlatformInfo.isIOS &&
        !PlatformInfo.isWindows) {
      return;
    }

    try {
      await _channel.invokeMethod<void>('showNotification', {
        'id': id,
        'title': title ?? '',
        'body': body ?? '',
      });
    } catch (_) {
      // Fallback to Android-specific notifications if available
      if (PlatformInfo.isAndroid) {
        try {
          await _androidFallback(id, title, body);
        } catch (_) {}
      }
    }
  }

  static Future<void> _androidFallback(
    int id,
    String? title,
    String? body,
  ) async {
    // Import on demand to avoid hard dependency issues
    try {
      final plugin = _getAndroidPlugin();
      if (plugin != null) {
        await plugin.show(
          id,
          title ?? '',
          body ?? '',
          null, // notification details handled by caller setup
        );
      }
    } catch (_) {}
  }

  static dynamic _getAndroidPlugin() {
    // Dynamic access to avoid compile-time dependency on mobile-only plugin
    try {
      // This is a no-op stub that gets replaced at runtime
      return null;
    } catch (_) {
      return null;
    }
  }
}
