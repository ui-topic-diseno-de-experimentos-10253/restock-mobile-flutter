import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:restock/core/constants/api_constants.dart';
import 'package:restock/features/profiles/data/models/profile_dto.dart';
import 'package:restock/features/profiles/domain/models/profile.dart';

class ProfileService {
  Future<Profile> getProfile(String token, int userId) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/profiles/$userId',
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final profileDto = ProfileDto.fromJson(data);
        return profileDto.toDomain();
      }

      if (response.statusCode == HttpStatus.notFound) {
        throw HttpException(
          'Profile not found for userId $userId.'
        );
      }

      throw HttpException('Failed to load profile: ${response.statusCode}');
    } on SocketException {
      throw const SocketException('Failed to establish network connection');
    }
  }

  Future<void> updateAvatarUrl(
    String token,
    int userId,
    Profile currentProfile,
    String avatarUrl,
  ) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/profiles/$userId/personal',
      );


      final requestBody = {
        'firstName': currentProfile.firstName,
        'lastName': currentProfile.lastName,
        'email': currentProfile.email,
        'phone': currentProfile.phone,
        'address': currentProfile.address,
        'country': currentProfile.country,
        'avatar': avatarUrl,
      };


      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );


      if (response.statusCode == HttpStatus.ok) {
        return;
      }

      throw HttpException('Failed to update avatar: ${response.statusCode} - ${response.body}');
    } on SocketException catch (e) {
      throw const SocketException('Failed to establish network connection');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount(String token, int userId) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/profiles/$userId',
      );

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == HttpStatus.ok ||
          response.statusCode == HttpStatus.noContent) {
        return;
      }

      throw HttpException('Failed to delete account: ${response.statusCode}');
    } on SocketException {
      throw const SocketException('Failed to establish network connection');
    }
  }
}
