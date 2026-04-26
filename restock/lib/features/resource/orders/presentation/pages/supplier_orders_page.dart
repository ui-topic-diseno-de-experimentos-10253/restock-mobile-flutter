// lib/features/resource/orders/presentation/pages/supplier_orders_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/core/enums/status.dart';
import 'package:restock/features/auth/data/local/auth_storage.dart';
import 'package:restock/features/profiles/data/remote/profile_service.dart';
import 'package:restock/features/resource/inventory/data/remote/inventory_service.dart';
import 'package:restock/features/resource/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:restock/features/resource/orders/data/remote/orders_service.dart';
import 'package:restock/features/resource/orders/data/repositories/orders_repository_impl.dart';
import 'package:restock/features/resource/orders/domain/repositories/orders_repository.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_bloc.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_event.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_state.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_tab.dart';
import 'package:restock/features/resource/orders/presentation/widgets/order_card.dart';
import 'package:restock/features/resource/orders/presentation/widgets/orders_filters_bar.dart';
import 'package:restock/features/resource/orders/presentation/pages/manage_order_page.dart';
import 'package:restock/features/resource/orders/presentation/pages/order_detail_page.dart';

class SupplierOrdersPage extends StatelessWidget {
  final OrdersRepository repository;
  final int supplierId;


  
  const SupplierOrdersPage({
    Key? key,
    required this.repository,
    required this.supplierId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    final ordersRepository = OrdersRepositoryImpl(service: OrdersService());
    final inventoryRepository = InventoryRepositoryImpl(
      service: InventoryService(),
      getUserId: () async => await AuthStorage().getUserId(),
    );
    
    return BlocProvider(
      create: (_) => OrdersBloc(
        repository: ordersRepository,
        profileService: ProfileService(),
        authStorage: AuthStorage(),
        inventoryRepository: inventoryRepository
      )..add(OrdersStarted(supplierId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
          actions: [
            BlocBuilder<OrdersBloc, OrdersState>(
              builder: (context, state) {
                if (state.currentTab != OrdersTab.historyOrders) {
                  return const SizedBox.shrink();
                }

                return TextButton.icon(
                  onPressed: state.isExporting
                      ? null
                      : () {
                          context
                              .read<OrdersBloc>()
                              .add(const OrdersExportToExcel());

                          // Snackbar simple al terminar
                          Future.delayed(const Duration(seconds: 2), () {
                            if (context.mounted) {
                              final s =
                                  context.read<OrdersBloc>().state;
                              if (s.exportedFilePath != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'File saved: ${s.exportedFilePath}',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          });
                        },
                  icon: state.isExporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download),
                  label: Text(
                    state.isExporting
                        ? 'Exporting...'
                        : 'Download report',
                  ),
                );
              },
            ),
          ],
        ),
        body: const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                OrdersFiltersBar(),
                SizedBox(height: 12),
                _OrdersTabBar(),
                SizedBox(height: 8),
                Expanded(child: _OrdersList()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrdersTabBar extends StatelessWidget {
  const _OrdersTabBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        return Row(
          children: OrdersTab.values.map((tab) {
            final isSelected = tab == state.currentTab;
            return Expanded(
              child: GestureDetector(
                onTap: () => context
                    .read<OrdersBloc>()
                    .add(OrdersTabChanged(tab)),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? Colors.green : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tab.label, // extensión que ya tienes
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        if (state.status == Status.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = state.visibleOrders;

        if (orders.isEmpty) {
          return const Center(
            child: Text('You currently have no orders registered.'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context
                .read<OrdersBloc>()
                .add(const OrdersRefreshRequested());
          },
          child: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (ctx, index) {
              final order = orders[index];
              final bloc = ctx.read<OrdersBloc>();
              final currentTab = state.currentTab;

              return OrderCard(
                order: order,
                onTap: () {
                  // 👇 AQUÍ SE DEFINE EL COMPORTAMIENTO POR TAB
                  if (currentTab == OrdersTab.newOrders) {
                    // 1) NEW ORDERS -> ManageOrderPage (aceptar / rechazar + supplies)
                    Navigator.of(ctx).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: bloc,
                          child: ManageOrderPage(order: order),
                        ),
                      ),
                    );
                  } else if (currentTab == OrdersTab.currentOrders) {
                    // 2) YOUR ORDERS -> Detalle + botón EDIT
                    Navigator.of(ctx).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: bloc,
                          child: OrderDetailPage(
                            order: order,
                            showEditButton: true,
                          ),
                        ),
                      ),
                    );
                  } else {
                    // 3) HISTORY -> Detalle SOLO lectura
                    Navigator.of(ctx).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: bloc,
                          child: OrderDetailPage(
                            order: order,
                            showEditButton: false,
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
