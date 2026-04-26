// lib/features/resource/orders/data/remote/orders_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:restock/core/constants/api_constants.dart';
import 'package:restock/features/auth/data/local/auth_storage.dart';
import 'package:restock/features/resource/orders/data/models/order_dto.dart';
import 'package:restock/features/resource/orders/data/models/order_request_dto.dart';
import 'package:restock/features/resource/orders/domain/models/order.dart';
import 'package:restock/features/resource/orders/domain/models/order_situation.dart';
import 'package:restock/features/resource/orders/domain/models/order_state.dart';

class OrdersService {
  final http.Client client;
  final AuthStorage _authStorage;

  OrdersService({
    http.Client? client,
    AuthStorage? authStorage,
  })  : client = client ?? http.Client(),
        _authStorage = authStorage ?? AuthStorage();

  Uri _uri(String path) => Uri.parse('${ApiConstants.baseUrl}$path');

  Future<Map<String, String>> _headers() async {
    final token = await _authStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<OrderDto>> getAllOrders() async {
    final url = _uri(ApiConstants.ordersEndpoint);
    print('GET: $url');
    
    final response = await client.get(url, headers: await _headers());
    
    print('Status: ${response.statusCode}');
    print(' Body: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => OrderDto.fromJson(e)).toList().cast<OrderDto>();
    }
    throw HttpException('Failed to load orders (${response.statusCode})');
  }

  Future<List<OrderDto>> getOrdersByAdminRestaurantId(
      int adminRestaurantId) async {
    final url = _uri(ApiConstants.ordersByAdminRestaurantId(adminRestaurantId));
    print('GET: $url');
    
    final response = await client.get(url, headers: await _headers());
    
    print('Status: ${response.statusCode}');
    print(' Body: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => OrderDto.fromJson(e)).toList().cast<OrderDto>();
    }
    throw HttpException(
        'Failed to load orders by admin (${response.statusCode})');
  }

  Future<List<OrderDto>> getOrdersBySupplierId(int supplierId) async {
    final url = _uri(ApiConstants.ordersBySupplierId(supplierId));
    print('GET: $url');
    print('Headers: ${await _headers()}');
    
    final response = await client.get(url, headers: await _headers());
    
    print('Status: ${response.statusCode}');
    print(' Body: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      print('Parsed ${data.length} orders');
      return data.map((e) => OrderDto.fromJson(e)).toList().cast<OrderDto>();
    }
    throw HttpException(
        'Failed to load orders by supplier (${response.statusCode}): ${response.body}');
  }

  Future<OrderDto?> getOrderById(int orderId) async {
    final response = await client.get(
      _uri(ApiConstants.orderById(orderId)),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return OrderDto.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<OrderDto?> createOrder(OrderRequestDto dto) async {
    final response = await client.post(
      _uri(ApiConstants.ordersEndpoint),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return OrderDto.fromJson(jsonDecode(response.body));
    }
    throw HttpException(
        'Failed to create order (${response.statusCode}): ${response.body}');
  }

  Future<OrderDto?> updateOrder(int id, OrderRequestDto dto) async {
    final response = await client.put(
      _uri(ApiConstants.orderById(id)),
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      return OrderDto.fromJson(jsonDecode(response.body));
    }
    throw HttpException(
        'Failed to update order (${response.statusCode}): ${response.body}');
  }

  Future<void> deleteOrder(int id) async {
    final response = await client.delete(
      _uri(ApiConstants.orderDelete(id)),
      headers: await _headers(),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw HttpException(
          'Failed to delete order (${response.statusCode}): ${response.body}');
    }
  }

  Future<Order> updateOrderState({
    required int orderId,
    required OrderState newState,
    required OrderSituation newSituation,
  }) async {
    final response = await client.put(
      _uri(ApiConstants.orderUpdateState(orderId)),
      headers: await _headers(),
      body: jsonEncode({
        "orderId": orderId,
        "newState": newState.apiValue,
        "newSituation": newSituation.apiValue,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return OrderDto.fromJson(data).toDomain();
    }

    throw HttpException(
      'Error updating order: ${response.statusCode} ${response.body}',
    );
  }

  Future<OrderDto?> updateOrderDetails(Order order) async {
    final url = _uri(ApiConstants.orderById(order.id));

    // Usamos directamente lo que viene del dominio
    final body = {
      'description': (order.description?.isEmpty ?? true)
          ? null
          : order.description,
      'estimatedShipDate': (order.estimatedShipDate?.isEmpty ?? true)
          ? null
          : order.estimatedShipDate,           // ya viene 'yyyy-MM-dd'
      'estimatedShipTime': (order.estimatedShipTime?.isEmpty ?? true)
          ? null
          : order.estimatedShipTime,           // ya viene 'HH:mm:00'
      'batchItems': order.batchItems.map((item) {
        return {
          'batchId': item.batchId,
          'accept': item.accepted,
        };
      }).toList(),
    };

    print('PUT: $url');
    print('BODY: $body');

    final response = await client.put(
      url,
      headers: await _headers(),
      body: jsonEncode(body),
    );

    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      return OrderDto.fromJson(jsonDecode(response.body));
    }

    throw HttpException(
      'Failed to update order details (${response.statusCode}): ${response.body}',
    );
  }
}