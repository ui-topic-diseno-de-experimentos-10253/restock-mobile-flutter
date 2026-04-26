import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:restock/core/constants/api_constants.dart';
import 'package:restock/features/profiles/data/models/category_dto.dart';
import 'package:restock/features/profiles/domain/models/business_category.dart';

class CategoryService {
  Future<List<BusinessCategory>> getCategories(String token) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/business-categories',
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => CategoryDto.fromJson(json).toDomain())
            .toList();
      }

      throw HttpException('Failed to load categories: ${response.statusCode}');
    } on SocketException {
      throw const SocketException('Failed to establish network connection');
    }
  }
}
