// lib/features/subscriptions/data/remote/subscription_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:restock/core/constants/api_constants.dart';

class SubscriptionService {
  /// Actualiza la suscripción de un usuario
  /// planType: 1 = Anual, 2 = Semestral
  Future<void> updateSubscription({
    required int userId,
    required String token,
    required int planType,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.userSubscription(userId)}',
      );

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'subscription': planType}),
      );

      if (response.statusCode == HttpStatus.ok) {
        return;
      }

      throw HttpException('Unexpected HTTP Status: ${response.statusCode}');
    } on SocketException {
      throw const SocketException('Failed to establish network connection');
    }
  }
}
