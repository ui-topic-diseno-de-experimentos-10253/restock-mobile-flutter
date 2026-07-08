// lib/core/services/push_token_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:restock/core/constants/api_constants.dart';

/// Sends the FCM device token to the Restock backend.
/// Endpoint: PUT /api/v1/mobile/push-token
class PushTokenService {
  Future<void> registerPushToken({
    required int userId,
    required String pushToken,
    String platform = 'ANDROID',
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.pushTokenEndpoint}',
      );

      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'platform': platform,
          'pushToken': pushToken,
        }),
      );

      if (response.statusCode == HttpStatus.ok ||
          response.statusCode == HttpStatus.created ||
          response.statusCode == HttpStatus.noContent) {
        return;
      }

      throw HttpException(
        'Failed to register push token. HTTP ${response.statusCode}: ${response.body}',
      );
    } on SocketException {
      throw const SocketException('No network connection to register push token');
    }
  }
}
