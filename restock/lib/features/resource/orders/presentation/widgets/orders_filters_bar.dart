// lib/features/resource/orders/presentation/widgets/orders_filters_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/features/resource/orders/domain/models/order_state.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_bloc.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_event.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_state.dart';
import 'package:restock/features/resource/orders/presentation/widgets/state_filter_bottom_sheet.dart';

class OrdersFiltersBar extends StatelessWidget {
  const OrdersFiltersBar({Key? key}) : super(key: key);

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
    return Column(
      children: [
        // Buscador
        BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            return TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search orders...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                context.read<OrdersBloc>().add(
                      OrdersSearchChanged(value.trim()),
                    );
              },
            );
          },
        ),
        
        const SizedBox(height: 12),
        
        // Filtros
        Row(
          children: [
            Expanded(
              child: BlocBuilder<OrdersBloc, OrdersState>(
                builder: (context, state) {
                  return _FilterChip(
                    label: state.stateFilter != null
                        ? _labelForState(state.stateFilter!)
                        : 'state',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => BlocProvider.value(
                          value: context.read<OrdersBloc>(),
                          child: const StateFilterBottomSheet(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _FilterChip(
                label: 'price',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Price filter coming soon'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.expand_more, size: 18),
        ],
      ),
    );
  }
}