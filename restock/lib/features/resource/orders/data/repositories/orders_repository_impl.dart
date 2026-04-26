// lib/features/resources/orders/data/repositories/orders_repository_impl.dart
 
import 'package:restock/features/resource/orders/data/models/order_request_dto.dart';
import 'package:restock/features/resource/orders/data/remote/orders_service.dart';
import 'package:restock/features/resource/orders/domain/models/order.dart';
import 'package:restock/features/resource/orders/domain/models/order_situation.dart';
import 'package:restock/features/resource/orders/domain/models/order_state.dart';
import 'package:restock/features/resource/orders/domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersService service;

  OrdersRepositoryImpl({required this.service});

  @override
  Future<List<Order>> getAllOrders() async {
    try {
      final dtos = await service.getAllOrders();
      final orders = dtos.map((e) => e.toDomain()).toList();
      print(' Repository: Converted ${orders.length} orders to domain');
      return orders;
    } catch (e) {
      print(' Repository getAllOrders error: $e');
      return [];
    }
  }

  @override
  Future<List<Order>> getOrdersByAdminRestaurantId(
      int adminRestaurantId) async {
    try {
      final dtos = await service.getOrdersByAdminRestaurantId(
        adminRestaurantId,
      );
      final orders = dtos.map((e) => e.toDomain()).toList();
      print(' Repository: Converted ${orders.length} orders to domain');
      return orders;
    } catch (e) {
      print(' Repository getOrdersByAdminRestaurantId error: $e');
      return [];
    }
  }

  @override
  Future<List<Order>> getOrdersBySupplierId(int supplierId) async {
    print(' Repository: Getting orders for supplier $supplierId');
    
    try {
      final dtos = await service.getOrdersBySupplierId(supplierId);
      print(' Repository: Received ${dtos.length} DTOs from service');
      
      final orders = dtos.map((e) => e.toDomain()).toList();
      print(' Repository: Converted ${orders.length} orders to domain');
      
      // Debug: imprime la primera orden
      if (orders.isNotEmpty) {
        final first = orders.first;
        print('🔍 First order: id=${first.id}, situation=${first.situation}, state=${first.state}');
      }
      
      return orders;
    } catch (e, stackTrace) {
      print(' Repository getOrdersBySupplierId error: $e');
      print(' StackTrace: $stackTrace');
      rethrow; //  MUY IMPORTANTE: Relanza el error para que el BLoC lo capture
    }
  }

  @override
  Future<Order?> getOrderById(int orderId) async {
    try {
      final dto = await service.getOrderById(orderId);
      return dto?.toDomain();
    } catch (e) {
      print(' Repository getOrderById error: $e');
      return null;
    }
  }

  @override
  Future<Order?> createOrder(Order order) async {
    try {
      final dto = OrderRequestDto.fromDomain(order);
      final responseDto = await service.createOrder(dto);
      return responseDto?.toDomain();
    } catch (e) {
      print(' Repository createOrder error: $e');
      return null;
    }
  }

  @override 
  Future<Order?> updateOrder(Order order) async {
    try {
      // ahora usamos el método nuevo
      final responseDto = await service.updateOrderDetails(order);
      return responseDto?.toDomain();
    } catch (e) {
      print(' Repository updateOrder error: $e');
      return null;
    }
  }

  @override
  Future<void> deleteOrder(int orderId) async {
    try {
      await service.deleteOrder(orderId);
    } catch (e) {
      print(' Repository deleteOrder error: $e');
    }
  }

  @override
  Future<Order> updateOrderState({
    required int orderId,
    required OrderState newState,
    required OrderSituation newSituation,
  }) =>
      service.updateOrderState(
        orderId: orderId,
        newState: newState,
        newSituation: newSituation,
      );

  
}

