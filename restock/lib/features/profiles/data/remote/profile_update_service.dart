import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:restock/core/constants/api_constants.dart';

class ProfileUpdateService {
  Future<void> updatePersonalInfo({
    required String token,
    required int userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String country,
    String? avatar,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/profiles/$userId/personal',
      );

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'address': address,
          'country': country,
          'avatar': avatar ?? '',
        }),
      );

      if (response.statusCode == HttpStatus.ok) {
        return;
      }

      throw HttpException('Failed to update personal data: ${response.statusCode}');
    } on SocketException {
      throw const SocketException('Failed to establish network connection');
    }
  }

  // Alias for backward compatibility
  Future<void> updatePersonalData({
    required String token,
    required int userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String country,
    String? avatar,
  }) async {
    return updatePersonalInfo(
      token: token,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      address: address,
      country: country,
      avatar: avatar,
    );
  }
}
