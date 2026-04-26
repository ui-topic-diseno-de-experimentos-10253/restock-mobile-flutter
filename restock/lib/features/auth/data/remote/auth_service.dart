// lib/features/auth/data/remote/auth_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:restock/core/constants/api_constants.dart';
import 'package:restock/features/auth/data/models/auth_response_dto.dart';
import 'package:restock/features/auth/domain/models/user.dart';

class AuthService {
  // LOGIN -------------------------
  Future<User> login(String username, String password) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}',
      );

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == HttpStatus.ok) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // aquí asumimos que el JSON del backend es el mismo
        // que usabas en Kotlin para AuthResponseDto
        final authResponse = AuthResponseDto.fromJson(data);
        return authResponse.toDomain(); // -> User
      }

      throw HttpException('Unexpected HTTP Status: ${response.statusCode}');
    } on SocketException {
      throw const SocketException('Failed to establish network connection');
    }
  }

  // REGISTER ----------------------
  Future<void> register({
    required String username,
    required String password,
    required int roleId,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.registerEndpoint}',
      );

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'roleId': roleId,
        }),
      );

      if (response.statusCode == HttpStatus.ok ||
          response.statusCode == HttpStatus.created) {
        return;
      }

      throw HttpException('Unexpected HTTP Status: ${response.statusCode}');
    } on SocketException {
      throw const SocketException('Failed to establish network connection');
    }
  }
}
