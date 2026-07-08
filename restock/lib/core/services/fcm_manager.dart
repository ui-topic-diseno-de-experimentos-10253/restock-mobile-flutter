// lib/core/services/fcm_manager.dart
import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:restock/core/services/push_token_service.dart';

/// Top-level background message handler.
/// Must be a top-level function (not a class method) for FCM background processing.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized when this runs.
  log('[FCM] Background message received: ${message.messageId}');
}

/// Manages all Firebase Cloud Messaging functionality for the Restock Flutter app.
///
/// Responsibilities:
/// - Request notification permissions (Android 13+)
/// - Fetch the FCM token and register it with the backend
/// - Handle token refresh events and re-register
/// - Show a local notification when a message arrives in the foreground
/// - Provide deep-link navigation when a notification is tapped
class FcmManager {
  FcmManager({
    required this.pushTokenService,
    required this.navigatorKey,
  });

  final PushTokenService pushTokenService;
  final GlobalKey<NavigatorState> navigatorKey;

  // Local notifications plugin for foreground messages.
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'inventory_alerts_channel';
  static const String _channelName = 'Alertas de Inventario';
  static const String _channelDescription =
      'Notificaciones automáticas sobre stock bajo y vencimiento de insumos';

  // ─────────────────────────────────────────────
  // Initialization
  // ─────────────────────────────────────────────

  /// Call once in `main()` before `runApp()`.
  Future<void> initialize() async {
    // Register background handler BEFORE FirebaseMessaging is used.
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permissions (iOS / Android 13+).
    await _requestPermissions();

    // Set up local notifications channel.
    await _initLocalNotifications();

    // Listen for foreground messages → show local notification.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // App opened from a background notification tap.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // App launched from a terminated state via notification.
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // Slight delay so the widget tree is ready before navigating.
      Future.delayed(const Duration(milliseconds: 800), () {
        _navigateFromNotification(initialMessage.data);
      });
    }
  }

  // ─────────────────────────────────────────────
  // Token Registration
  // ─────────────────────────────────────────────

  /// Call after a successful login with the logged-in user's ID.
  /// Fetches the current FCM token and sends it to the backend.
  Future<void> syncToken(int userId) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        log('[FCM] Token obtained for user $userId: ${token.substring(0, 20)}...');
        await _sendTokenToBackend(userId, token);
      } else {
        log('[FCM] No FCM token available');
      }

      // Subscribe to token refresh events.
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        log('[FCM] Token refreshed for user $userId');
        _sendTokenToBackend(userId, newToken);
      });
    } catch (e) {
      log('[FCM] Error syncing token: $e');
    }
  }

  Future<void> _sendTokenToBackend(int userId, String token) async {
    try {
      await pushTokenService.registerPushToken(
        userId: userId,
        pushToken: token,
      );
      log('[FCM] Token successfully registered with backend for user $userId');
    } catch (e) {
      log('[FCM] Failed to register token with backend: $e');
    }
  }

  // ─────────────────────────────────────────────
  // Permissions
  // ─────────────────────────────────────────────

  Future<void> _requestPermissions() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    log('[FCM] Notification permission status: ${settings.authorizationStatus}');
  }

  // ─────────────────────────────────────────────
  // Local Notifications
  // ─────────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    const androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettings = InitializationSettings(
      android: androidInitSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Tapping a local (foreground) notification.
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _navigateFromPayload(payload);
        }
      },
    );

    // Create the Android notification channel (required for Android 8+).
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ─────────────────────────────────────────────
  // Message Handlers
  // ─────────────────────────────────────────────

  void _handleForegroundMessage(RemoteMessage message) {
    log('[FCM] Foreground message received: ${message.messageId}');

    final data = message.data;
    final title = message.notification?.title ??
        data['title'] ??
        'Alerta de Inventario';
    final body = message.notification?.body ??
        data['body'] ??
        'Tienes una actualización relevante en tu inventario.';

    // Build a payload string: "batchId|customSupplyId|type"
    final batchId = data['batchId'] ?? '';
    final customSupplyId = data['customSupplyId'] ?? '';
    final type = data['type'] ?? 'stock_low';
    final payload = '$batchId|$customSupplyId|$type';

    _showLocalNotification(title, body, payload);
  }

  void _handleNotificationTap(RemoteMessage message) {
    log('[FCM] Notification tapped (background): ${message.messageId}');
    _navigateFromNotification(message.data);
  }

  // ─────────────────────────────────────────────
  // Local Notification Display
  // ─────────────────────────────────────────────

  void _showLocalNotification(String title, String body, String payload) {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // ─────────────────────────────────────────────
  // Deep-Link Navigation
  // ─────────────────────────────────────────────

  /// Navigates from a FCM data map (background / terminated tap).
  void _navigateFromNotification(Map<String, dynamic> data) {
    final customSupplyId = data['customSupplyId']?.toString() ?? '';
    final batchId = data['batchId']?.toString() ?? '';
    final type = data['type']?.toString() ?? 'stock_low';

    log('[FCM] Deep-link → customSupplyId=$customSupplyId, batchId=$batchId, type=$type');

    final context = navigatorKey.currentContext;
    if (context == null) {
      log('[FCM] No navigator context available for deep-link');
      return;
    }

    if (customSupplyId.isNotEmpty) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/inventory',
        (route) => route.settings.name == '/home' || route.isFirst,
      );
      Navigator.of(context).pushNamed(
        '/supply_detail_by_id',
        arguments: {'customSupplyId': customSupplyId},
      );
    } else if (batchId.isNotEmpty) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/inventory',
        (route) => route.settings.name == '/home' || route.isFirst,
      );
      Navigator.of(context).pushNamed(
        '/inventory_detail',
        arguments: {'batchId': batchId},
      );
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/inventory',
        (route) => route.settings.name == '/home' || route.isFirst,
      );
    }
  }

  /// Navigates from a local notification payload string ("batchId|customSupplyId|type").
  void _navigateFromPayload(String payload) {
    final parts = payload.split('|');
    final batchId = parts.isNotEmpty ? parts[0] : '';
    final customSupplyId = parts.length > 1 ? parts[1] : '';
    final type = parts.length > 2 ? parts[2] : 'stock_low';

    _navigateFromNotification({
      'batchId': batchId,
      'customSupplyId': customSupplyId,
      'type': type,
    });
  }
}
