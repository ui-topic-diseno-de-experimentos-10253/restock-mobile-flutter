// lib/features/resource/orders/presentation/pages/manage_order_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/features/resource/orders/domain/models/order.dart';
import 'package:restock/features/resource/orders/domain/models/order_batch_item.dart';
import 'package:restock/features/resource/orders/domain/models/order_state.dart';
import 'package:restock/features/resource/orders/domain/models/order_situation.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_bloc.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_event.dart';

class ManageOrderPage extends StatefulWidget {
  final Order order;

  const ManageOrderPage({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<ManageOrderPage> createState() => _ManageOrderPageState();
}

class _ManageOrderPageState extends State<ManageOrderPage> {
  late List<OrderBatchItem> _items;
  late TextEditingController _descriptionController;
  DateTime? _shipDate;
  TimeOfDay? _shipTime;

  @override
  void initState() {
    super.initState();
    _items = List<OrderBatchItem>.from(widget.order.batchItems);
    _descriptionController =
        TextEditingController(text: widget.order.description ?? '');

    if (widget.order.estimatedShipDate?.isNotEmpty == true) {
      _shipDate = DateTime.tryParse(widget.order.estimatedShipDate!);
    }
    if (widget.order.estimatedShipTime?.isNotEmpty == true) {
      final parts = widget.order.estimatedShipTime!.split(':');
      if (parts.length >= 2) {
        _shipTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _shipDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (result != null) {
      setState(() => _shipDate = result);
    }
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _shipTime ?? TimeOfDay.now(),
    );
    if (result != null) {
      setState(() => _shipTime = result);
    }
  }

  void _onApprove() {
    final bloc = context.read<OrdersBloc>();

    // 1) construir la orden actualizada
    final updatedOrder = widget.order.copyWith(
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      estimatedShipDate: _shipDate != null
          ? _shipDate!.toIso8601String().split('T').first
          : widget.order.estimatedShipDate,
      estimatedShipTime: _shipTime != null
          ? '${_shipTime!.hour.toString().padLeft(2, '0')}:${_shipTime!.minute.toString().padLeft(2, '0')}'
          : widget.order.estimatedShipTime,
      batchItems: _items, // aquí ya vienen con accepted = true/false
    );

    // 2) primero actualizamos detalles + accepted
    bloc.add(OrderUpdateRequested(updatedOrder));

    // 3) luego actualizamos state/situation
    bloc.add(
      OrderStateUpdateRequested(
        orderId: widget.order.id,
        newState: OrderState.onHold,
        newSituation: OrderSituation.approved,
      ),
    );

    Navigator.of(context).pop();
  }

  void _onDecline() {
    context.read<OrdersBloc>().add(
          OrderStateUpdateRequested(
            orderId: widget.order.id,
            newState: widget.order.state,
            newSituation: OrderSituation.declined,
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Order'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabla de productos
            const Text(
              'Supplies',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildSuppliesTable(),

            const SizedBox(height: 16),
            Text(
              'Total price: S/ ${widget.order.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),

            const SizedBox(height: 24),
            const Text(
              'Order description for restaurant',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText:
                    'Write here extra details about delivery, partial acceptance, etc.',
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Estimated date',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _shipDate != null
                          ? '${_shipDate!.day}/${_shipDate!.month}/${_shipDate!.year}'
                          : 'Select date',
                    ),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Estimated hour',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _shipTime != null
                          ? _shipTime!.format(context)
                          : 'Select hour',
                    ),
                    const Icon(Icons.access_time, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _onDecline,
                    style:
                        OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                    child: const Text('DECLINE'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onApprove,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('APPROVE'),
                  ),
                ),
              ],
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
        ..._items.map((item) {
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
                  child: Checkbox(
                    value: item.accepted,
                    onChanged: (value) {
                      setState(() {
                        final idx = _items.indexOf(item);
                        _items[idx] = item.copyWith(
                          accepted: value ?? false,
                        );
                      });
                    },
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