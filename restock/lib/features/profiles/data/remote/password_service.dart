import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:restock/core/constants/api_constants.dart';

class PasswordService {
  Future<void> changePassword({
    required String token,
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/profiles/$userId/password',
      );

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == HttpStatus.noContent || response.statusCode == HttpStatus.ok) {
        return;
      }

      if (response.statusCode == HttpStatus.unauthorized) {
        throw Exception('Current password is incorrect');
      }

      throw HttpException('Failed to change password: ${response.statusCode}');
    } on SocketException {
      throw const SocketException('Failed to establish network connection');
    }
  }
}
