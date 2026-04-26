 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/features/resource/orders/domain/models/order_state.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_bloc.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_event.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_state.dart';

class StateFilterBottomSheet extends StatelessWidget {
  const StateFilterBottomSheet({Key? key}) : super(key: key);

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
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter by State',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (state.stateFilter != null)
                    TextButton(
                      onPressed: () {
                        context.read<OrdersBloc>().add(
                              const OrdersStateFilterChanged(null),
                            );
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Opción: Todos
              ListTile(
                title: const Text('All states'),
                leading: Radio<OrderState?>(
                  value: null,
                  groupValue: state.stateFilter,
                  onChanged: (value) {
                    context.read<OrdersBloc>().add(
                          OrdersStateFilterChanged(value),
                        );
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  context.read<OrdersBloc>().add(
                        const OrdersStateFilterChanged(null),
                      );
                  Navigator.pop(context);
                },
              ),
              
              const Divider(),
              
              // Opciones de estado
              ...OrderState.values.map((orderState) {
                return ListTile(
                  title: Text(_labelForState(orderState)),
                  leading: Radio<OrderState?>(
                    value: orderState,
                    groupValue: state.stateFilter,
                    onChanged: (value) {
                      context.read<OrdersBloc>().add(
                            OrdersStateFilterChanged(value),
                          );
                      Navigator.pop(context);
                    },
                  ),
                  onTap: () {
                    context.read<OrdersBloc>().add(
                          OrdersStateFilterChanged(orderState),
                        );
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}