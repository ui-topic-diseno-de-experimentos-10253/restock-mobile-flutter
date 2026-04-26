// lib/features/resource/orders/presentation/pages/edit_order_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/features/resource/orders/domain/models/order.dart';
import 'package:restock/features/resource/orders/domain/models/order_state.dart';
import 'package:restock/features/resource/orders/domain/models/order_situation.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_bloc.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_event.dart';

class EditOrderPage extends StatefulWidget {
  final Order order;

  const EditOrderPage({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<EditOrderPage> createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
  late TextEditingController _descriptionController;
  DateTime? _shipDate;
  TimeOfDay? _shipTime;
  late OrderState _selectedState;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.order.description ?? '');
    _selectedState = widget.order.state;

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

  String _labelForState(OrderState s) {
    switch (s) {
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

  void _onSave() {
    final bloc = context.read<OrdersBloc>();
  
    // 1) Actualizar description + fechas (sin tocar state)
    final updatedOrder = widget.order.copyWith(
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      estimatedShipDate: _shipDate != null
          ? _shipDate!.toIso8601String().split('T').first
          : null,
      estimatedShipTime: _shipTime != null
          ? '${_shipTime!.hour.toString().padLeft(2, '0')}:${_shipTime!.minute.toString().padLeft(2, '0')}:00'
          : null,
    );
  
    bloc.add(OrderUpdateRequested(updatedOrder));
  
    // 2) Si cambió el state, llamar también al endpoint /state
    if (_selectedState != widget.order.state) {
      bloc.add(
        OrderStateUpdateRequested(
          orderId: widget.order.id,
          newState: _selectedState,
          newSituation: widget.order.situation,
        ),
      );
    }
  
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Order'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info de la orden (read-only)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${widget.order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Date: ${widget.order.requestedDate}'),
                  Text('Products: ${widget.order.requestedProductsCount}'),
                  Text('Total: S/ ${widget.order.totalPrice.toStringAsFixed(2)}'),
                ],
              ),
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

            const SizedBox(height: 24),
            const Text(
              'State',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: OrderState.values.map((s) {
                final bool selected = s == _selectedState;
                return ChoiceChip(
                  label: Text(_labelForState(s)),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedState = s),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('SAVE CHANGES'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}