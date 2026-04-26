import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/core/enums/status.dart';
import 'package:restock/features/auth/data/local/auth_storage.dart';
import 'package:restock/features/profiles/data/remote/profile_service.dart';
import 'package:restock/features/resource/inventory/data/remote/inventory_service.dart';
import 'package:restock/features/resource/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:restock/features/resource/orders/domain/models/order_state.dart';
import 'package:restock/features/resource/orders/domain/repositories/orders_repository.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_bloc.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_event.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_state.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_tab.dart';
import 'package:restock/features/resource/orders/presentation/widgets/order_card.dart';
import 'package:restock/features/resource/orders/presentation/pages/manage_order_page.dart';
import 'package:restock/features/resource/orders/presentation/widgets/state_filter_bottom_sheet.dart';

class OrdersPage extends StatelessWidget {
  final OrdersRepository repository;
  final int supplierId;

  const OrdersPage({
    super.key,
    required this.repository,
    required this.supplierId,
  });

  @override
  Widget build(BuildContext context) {

    final inventoryRepository = InventoryRepositoryImpl(
      service: InventoryService(),
      getUserId: () async => await AuthStorage().getUserId(),
    );
    
    return BlocProvider(
      create: (_) => OrdersBloc(
        repository: repository,
        profileService: ProfileService(),
        authStorage: AuthStorage(),
        inventoryRepository: inventoryRepository,
      )..add(OrdersStarted(supplierId)),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatelessWidget {
  const _OrdersView();

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF4F8A5B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        centerTitle: false,
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
                        context.read<OrdersBloc>().add(const OrdersExportToExcel());
                        
                        // Mostrar snackbar cuando termine
                        Future.delayed(const Duration(seconds: 2), () {
                          if (context.mounted) {
                            final currentState = context.read<OrdersBloc>().state;
                            if (currentState.exportedFilePath != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'File saved: ${currentState.exportedFilePath}',
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        });
                      },
                icon: state.isExporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.download, size: 18),
                label: Text(
                  state.isExporting ? 'Exporting...' : 'Download\nhistory',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 11),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: green,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const _OrdersBody(),
    );
  }
}

class _OrdersBody extends StatelessWidget {
  const _OrdersBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        final bloc = context.read<OrdersBloc>();
        final orders = state.visibleOrders;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search orders...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) =>
                    bloc.add(OrdersSearchChanged(value.trim())),
              ),
              const SizedBox(height: 12),

              // Filtros
              Row(
                children: [
                  Expanded(
                    child: BlocBuilder<OrdersBloc, OrdersState>(
                      builder: (context, state) {
                        return _SimpleFilterChip(
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
                    child: _SimpleFilterChip(
                      label: 'price',
                      onTap: () {
                        // TODO: filtro precio
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

              const SizedBox(height: 16),

              // Tabs
              _OrdersTabs(
                currentTab: state.currentTab,
                onTabChanged: (tab) => bloc.add(OrdersTabChanged(tab)),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    bloc.add(const OrdersRefreshRequested());
                  },
                  child: Builder(
                    builder: (context) {
                      if (state.status == Status.loading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (orders.isEmpty) {
                        return const _EmptyOrdersState();
                      }

                      return ListView.separated(
                        itemCount: orders.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final order = orders[index];

                          return OrderCard(
                            order: order,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: bloc,
                                    child: ManageOrderPage(order: order),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SimpleFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SimpleFilterChip({
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
          Text(label),
          const Icon(Icons.expand_more, size: 18),
        ],
      ),
    );
  }
}

class _OrdersTabs extends StatelessWidget {
  final OrdersTab currentTab;
  final ValueChanged<OrdersTab> onTabChanged;

  const _OrdersTabs({
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildTab(String label, OrdersTab tab) {
      final bool isSelected = currentTab == tab;
      final green = const Color(0xFFBFD7C7);

      return Expanded(
        child: InkWell(
          onTap: () => onTabChanged(tab),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? green : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade400,
                  width: 1,
                ),
                top: BorderSide(
                  color: Colors.grey.shade400,
                  width: 1,
                ),
                left: BorderSide(
                  color: Colors.grey.shade400,
                  width: 0.5,
                ),
                right: BorderSide(
                  color: Colors.grey.shade400,
                  width: 0.5,
                ),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.black : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        buildTab('New Orders', OrdersTab.newOrders),
        buildTab('Your Orders', OrdersTab.currentOrders),
        buildTab('History Orders', OrdersTab.historyOrders),
      ],
    );
  }
}

class _EmptyOrdersState extends StatelessWidget {
  const _EmptyOrdersState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 56,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'You currently have no orders registered.',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

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