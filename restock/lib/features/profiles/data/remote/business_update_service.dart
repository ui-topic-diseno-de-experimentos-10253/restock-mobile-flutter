import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:restock/core/constants/api_constants.dart';
import 'package:restock/features/profiles/domain/models/business_category.dart';

class BusinessUpdateService {
  Future<void> updateBusinessInfo({
    required String token,
    required int userId,
    required String businessName,
    required String businessAddress,
    required String description,
    required List<String> categoryIds,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/profiles/$userId/business',
      );

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'businessName': businessName,
          'businessAddress': businessAddress,
          'description': description,
          'businessCategoryIds': categoryIds,
        }),
      );

      if (response.statusCode == HttpStatus.ok) {
        return;
      }

      throw HttpException('Failed to update business data: ${response.statusCode}');
    } on SocketException {
      throw const SocketException('Failed to establish network connection');
    }
  }

  // Alias for backward compatibility
  Future<void> updateBusinessData({
    required String token,
    required int userId,
    required String businessName,
    required String businessAddress,
    required String description,
    required List<BusinessCategory> categories,
  }) async {
    return updateBusinessInfo(
      token: token,
      userId: userId,
      businessName: businessName,
      businessAddress: businessAddress,
      description: description,
      categoryIds: categories.map((c) => c.id).toList(),
    );
  }
}
