// lib/features/resource/orders/presentation/pages/order_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/features/resource/orders/domain/models/order.dart';
import 'package:restock/features/resource/orders/domain/models/order_state.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_bloc.dart';
import 'package:restock/features/resource/orders/presentation/pages/edit_order_page.dart';

class OrderDetailPage extends StatelessWidget {
  final Order order;
  final bool showEditButton;

  const OrderDetailPage({
    Key? key,
    required this.order,
    this.showEditButton = false,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info general de la orden
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Date: ${order.requestedDate}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Products: ${order.requestedProductsCount}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tabla de productos
            const Text(
              'Supplies',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildSuppliesTable(),

            const SizedBox(height: 16),
            Text(
              'Total price: S/ ${order.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),

            const SizedBox(height: 24),
            const Text(
              'Order description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey.shade50,
              ),
              child: Text(
                order.description?.isEmpty == true 
                    ? 'No description provided' 
                    : order.description ?? 'No description provided',
                style: const TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Estimated delivery date',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey.shade50,
              ),
              child: Text(
                order.estimatedShipDate?.isEmpty == true 
                    ? 'Not set' 
                    : order.estimatedShipDate ?? 'Not set',
                style: const TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Estimated delivery time',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey.shade50,
              ),
              child: Text(
                order.estimatedShipTime?.isEmpty == true 
                    ? 'Not set' 
                    : order.estimatedShipTime ?? 'Not set',
                style: const TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'State',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _labelForState(order.state),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),

            const SizedBox(height: 32),
            
            // Botones según si puede editar o no
            if (showEditButton)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('CLOSE'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<OrdersBloc>(),
                              child: EditOrderPage(order: order),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('EDIT'),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('CLOSE'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuppliesTable() {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(flex: 3, child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(width: 8),
            SizedBox(width: 60, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(width: 8),
            SizedBox(width: 70, child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(width: 8),
            SizedBox(width: 80, child: Text('Accept', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        const Divider(thickness: 1.5),
        ...order.batchItems.map((item) {
          final supplyName = item.batch?.customSupply?.supply?.name ?? 'Product';
          final unitPrice = item.batch?.customSupply?.price ?? 0.0;
          final subtotal = unitPrice * item.quantity;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplyName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'S/ ${unitPrice.toStringAsFixed(2)} each',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: Text(
                    item.quantity.toStringAsFixed(1),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 70,
                  child: Text(
                    'S/ ${subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: Icon(
                    item.accepted ? Icons.check_circle : Icons.cancel,
                    color: item.accepted ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}