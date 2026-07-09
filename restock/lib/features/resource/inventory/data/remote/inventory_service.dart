import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:restock/core/constants/api_constants.dart';
import 'package:restock/features/auth/data/local/auth_storage.dart';
import 'package:restock/features/resource/inventory/data/models/batch_dto.dart';
import 'package:restock/features/resource/inventory/data/models/custom_supply_dto.dart';
import 'package:restock/features/resource/inventory/data/models/custom_supply_request_dto.dart';
import 'package:restock/features/resource/inventory/data/models/supply_dto.dart'; 

class InventoryService {
  final http.Client client;
  final AuthStorage authStorage;

  InventoryService({http.Client? client, AuthStorage? authStorage})
      : client = client ?? http.Client(),
        authStorage = authStorage ?? AuthStorage();

  // helpers
  Uri _uri(String path) => Uri.parse('${ApiConstants.baseUrl}/$path');

  Future<Map<String, String>> _headers() async {
    final token = await authStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<SupplyDto>> getSupplies() async {
    final headers = await _headers();
    final response = await client.get(_uri('supplies'), headers: headers);

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((e) => SupplyDto.fromJson(e)).toList();
    }
    throw Exception('Failed to load supplies (${response.statusCode})');
  }

  Future<List<CustomSupplyDto>> getCustomSupplies() async {
    final headers = await _headers();
    final response =
        await client.get(_uri('custom-supplies'), headers: headers);

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((e) => CustomSupplyDto.fromJson(e)).toList();
    }
    throw Exception('Failed to load custom supplies (${response.statusCode})');
  }

  Future<List<CustomSupplyDto>> getCustomSuppliesByUserId(int userId) async {
    final headers = await _headers();
    final response = await client.get(
      _uri('custom-supplies/user/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((e) => CustomSupplyDto.fromJson(e)).toList();
    }
    throw Exception(
      'Failed to load custom supplies by user (${response.statusCode})',
    );
  }

  Future<List<BatchDto>> getBatches() async {
    final headers = await _headers();
    final response = await client.get(_uri('batches'), headers: headers);

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((e) => BatchDto.fromJson(e)).toList();
    }
    throw Exception('Failed to load batches (${response.statusCode})');
  }

  Future<List<BatchDto>> getBatchesByUserId(int userId) async {
    final headers = await _headers();
    final response =
        await client.get(_uri('batches/user/$userId'), headers: headers);

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((e) => BatchDto.fromJson(e)).toList();
    }
    throw Exception(
      'Failed to load batches by user (${response.statusCode})',
    );
  }

  Future<BatchDto?> createBatch(BatchDto dto) async {
    final headers = await _headers();
    final response = await client.post(
      _uri('batches'),
      headers: headers,
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return BatchDto.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<BatchDto?> updateBatch(String id, BatchDto dto) async {
    final headers = await _headers();
    final response = await client.put(
      _uri('batches/$id'),
      headers: headers,
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      return BatchDto.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<void> deleteBatch(String id) async {
    final headers = await _headers();
    await client.delete(_uri('batches/$id'), headers: headers);
  }

  Future<CustomSupplyDto?> createCustomSupply(
    CustomSupplyRequestDto dto,
  ) async {
    final headers = await _headers();
    final response = await client.post(
      _uri('custom-supplies'),
      headers: headers,
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CustomSupplyDto.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<CustomSupplyDto?> updateCustomSupply(
    int id,
    CustomSupplyRequestDto dto,
  ) async {
    final headers = await _headers();
    final response = await client.put(
      _uri('custom-supplies/$id'),
      headers: headers,
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      return CustomSupplyDto.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<void> deleteCustomSupply(int id) async {
    final headers = await _headers();
    await client.delete(
      _uri('custom-supplies/$id'),
      headers: headers,
    );
  }
}

