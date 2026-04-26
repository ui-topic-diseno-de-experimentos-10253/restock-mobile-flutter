 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/features/resource/orders/domain/models/order.dart';
import 'package:restock/features/resource/orders/domain/models/order_state.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_bloc.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_state.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onTap,
  }) : super(key: key);

  String _labelForState(OrderState state) {
    switch (state) {
      case OrderState.onHold:
        return 'On hold';
      case OrderState.preparing:
        return 'Preparing';
      case OrderState.onTheWay:
        return 'On the way';
      case OrderState.delivered:
        return 'Delivered';
    }
  }

  Color _colorForState(OrderState state) {
    switch (state) {
      case OrderState.onHold:
        return const Color(0xFFFFF4E0); // Amarillo claro
      case OrderState.preparing:
        return const Color(0xFFE3F2FD); // Azul claro
      case OrderState.onTheWay:
        return const Color(0xFFFFF3E0); // Naranja claro
      case OrderState.delivered:
        return const Color(0xFFE8F5E9); // Verde claro
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        final restaurantName = state.getRestaurantName(order.adminRestaurantId);
        
        return InkWell(
          onTap: onTap,
          child: Card(
            color: _colorForState(order.state),
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Columna izquierda: Estado y situación
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _labelForState(order.state),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.situation.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Columna derecha: Información del restaurante
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurantName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.requestedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: S/ ${order.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}