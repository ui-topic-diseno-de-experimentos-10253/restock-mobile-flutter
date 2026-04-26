
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:restock/core/constants/api_constants.dart';
import 'package:restock/features/alerts/data/models/alert_dto.dart';

class AlertService {
  final http.Client client;

  AlertService({http.Client? client}) : client = client ?? http.Client();

  Uri _uri(String path) => Uri.parse('${ApiConstants.baseUrl}/$path');

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
      };

  Future<List<AlertDto>> getAlertsBySupplierId(int supplierId) async {
    final response = await client.get(
      _uri('alerts/supplier/$supplierId'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((e) => AlertDto.fromJson(e)).toList();
    }
    throw Exception('Failed to load supplier alerts. Status: ${response.statusCode}');
  }

  Future<List<AlertDto>> getAlertsByAdminRestaurantId(int adminId) async {
    final response = await client.get(
      _uri('alerts/admin-restaurant/$adminId'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((e) => AlertDto.fromJson(e)).toList();
    }
    throw Exception('Failed to load restaurant admin alerts. Status: ${response.statusCode}');
  }
}
