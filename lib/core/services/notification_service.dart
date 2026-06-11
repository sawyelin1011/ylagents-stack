import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../shared/platform/platform_adapters.dart';

/// Cross-platform notification service for Android, iOS, and Windows.
///
/// Uses flutter_local_notifications for Android and iOS,
/// and a custom method channel for Windows notification toasts.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _inited = false;
  static const MethodChannel _windowsChannel = MethodChannel(
    'app.notifications',
  );

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'kelivo_bg_chat_v2',
    'Chat Background',
    description: 'Notifications for chat generation status',
    importance: Importance.high,
    playSound: true,
  );

  static Future<void> ensureInitialized() async {
    if (_inited) return;

    // Initialize Android
    if (PlatformInfo.isAndroid) {
      const AndroidInitializationSettings androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings init = InitializationSettings(
        android: androidInit,
      );
      await _plugin.initialize(init);

      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        await android.createNotificationChannel(_channel);
      }
    }

    // Initialize iOS
    if (PlatformInfo.isIOS) {
      const IOSInitializationSettings iosInit = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const InitializationSettings init = InitializationSettings(iOS: iosInit);
      await _plugin.initialize(init);
    }

    // Initialize Windows (no plugin needed, uses method channel)
    if (PlatformInfo.isWindows) {
      try {
        await _windowsChannel.invokeMethod<void>('init');
      } catch (_) {}
    }

    _inited = true;
  }

  /// Ensure notification permissions are granted.
  static Future<bool> ensurePermissions() async {
    await ensureInitialized();

    if (PlatformInfo.isAndroid) {
      return _ensureAndroidPermission();
    }

    if (PlatformInfo.isIOS) {
      return _ensureIOSPermission();
    }

    if (PlatformInfo.isWindows) {
      return true; // Windows notifications don't require runtime permission
    }

    return true;
  }

  static Future<bool> _ensureAndroidPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return true;
    try {
      final enabled = await android.areNotificationsEnabled();
      if (enabled == true) return true;
    } catch (_) {}
    try {
      final ok = await android.requestNotificationsPermission();
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _ensureIOSPermission() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios == null) return true;
    try {
      final ok = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Show a notification on the current platform.
  static Future<void> showChatCompleted({String? title, String? body}) async {
    await ensureInitialized();

    final notificationTitle = title ?? 'Generation complete';
    final notificationBody = body ?? 'Assistant reply has been generated';

    if (PlatformInfo.isAndroid) {
      await _showAndroidNotification(notificationTitle, notificationBody);
    } else if (PlatformInfo.isIOS) {
      await _showIOSNotification(notificationTitle, notificationBody);
    } else if (PlatformInfo.isWindows) {
      await _showWindowsNotification(notificationTitle, notificationBody);
    }
  }

  static Future<void> _showAndroidNotification(
    String title,
    String body,
  ) async {
    await _plugin.show(
      2001,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          category: AndroidNotificationCategory.message,
          visibility: NotificationVisibility.public,
          ticker: 'Kelivo',
          styleInformation: const DefaultStyleInformation(true, true),
        ),
      ),
    );
  }

  static Future<void> _showIOSNotification(String title, String body) async {
    await _plugin.show(
      2001,
      title,
      body,
      const NotificationDetails(
        iOS: IOSNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          categoryIdentifier: 'kelivo_chat',
        ),
      ),
    );
  }

  static Future<void> _showWindowsNotification(
    String title,
    String body,
  ) async {
    try {
      await _windowsChannel.invokeMethod<void>('show', {
        'title': title,
        'body': body,
      });
    } catch (_) {
      // Windows notifications via method channel - silently fail if not implemented
    }
  }

  /// Show an arbitrary notification.
  static Future<void> show({
    required int id,
    String? title,
    String? body,
  }) async {
    await ensureInitialized();

    if (PlatformInfo.isAndroid) {
      await _plugin.show(
        id,
        title ?? '',
        body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
      );
    } else if (PlatformInfo.isIOS) {
      await _plugin.show(
        id,
        title ?? '',
        body ?? '',
        const NotificationDetails(
          iOS: IOSNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } else if (PlatformInfo.isWindows) {
      await _showWindowsNotification(title ?? '', body ?? '');
    }
  }
}
