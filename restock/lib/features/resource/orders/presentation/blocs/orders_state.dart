import 'package:restock/core/enums/status.dart';
import 'package:restock/features/resource/orders/domain/models/order.dart';
import 'package:restock/features/resource/orders/domain/models/order_state.dart';
import 'package:restock/features/resource/orders/domain/models/order_situation.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_tab.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_sort.dart';

class OrdersState {
  final Status status;
  final List<Order> allOrders;
  final String searchQuery;
  final OrdersTab currentTab;
  final OrdersSort sort;
  final OrderState? stateFilter;
  final int? supplierId;
  final String? errorMessage;
  
  // Caché de perfiles: {userId: businessName}
  final Map<int, String> profileCache;
  
  // Estado de exportación
  final bool isExporting;
  final String? exportedFilePath;

  const OrdersState({
    this.status = Status.initial,
    this.allOrders = const [],
    this.searchQuery = '',
    this.currentTab = OrdersTab.newOrders,
    this.sort = OrdersSort.dateDesc,
    this.stateFilter,
    this.supplierId,
    this.errorMessage,
    this.profileCache = const {},
    this.isExporting = false,
    this.exportedFilePath,
  });

  OrdersState copyWith({
    Status? status,
    List<Order>? allOrders,
    String? searchQuery,
    OrdersTab? currentTab,
    OrdersSort? sort,
    OrderState? stateFilter,
    bool clearStateFilter = false,
    int? supplierId,
    String? errorMessage,
    Map<int, String>? profileCache,
    bool? isExporting,
    String? exportedFilePath,
    bool clearExportedFilePath = false,
  }) {
    return OrdersState(
      status: status ?? this.status,
      allOrders: allOrders ?? this.allOrders,
      searchQuery: searchQuery ?? this.searchQuery,
      currentTab: currentTab ?? this.currentTab,
      sort: sort ?? this.sort,
      stateFilter:
          clearStateFilter ? null : (stateFilter ?? this.stateFilter),
      supplierId: supplierId ?? this.supplierId,
      errorMessage: errorMessage ?? this.errorMessage,
      profileCache: profileCache ?? this.profileCache,
      isExporting: isExporting ?? this.isExporting,
      exportedFilePath: clearExportedFilePath 
          ? null 
          : (exportedFilePath ?? this.exportedFilePath),
    );
  }

  List<Order> get visibleOrders {
    Iterable<Order> result = allOrders;

    // 1) Filtrar por pestaña
    result = result.where((o) {
      switch (currentTab) {
        case OrdersTab.newOrders:
          return o.situation == OrderSituation.pending;
        case OrdersTab.currentOrders:
          return o.situation == OrderSituation.approved && !o.state.isFinished;
        case OrdersTab.historyOrders:
          // Solo mostrar delivered en history
          return o.state == OrderState.delivered;
      }
    });

    // 2) Filtro por estado
    if (stateFilter != null) {
      result = result.where((o) => o.state == stateFilter);
    }

    // 3) Buscador
    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((o) {
        final idMatch = o.id.toString().contains(q);
        final restName = getRestaurantName(o.adminRestaurantId).toLowerCase();
        return idMatch || restName.contains(q);
      });
    }

    // 4) Sort por fecha
    int compareByDate(Order a, Order b) {
      final da = DateTime.tryParse(a.requestedDate) ?? DateTime(2000);
      final db = DateTime.tryParse(b.requestedDate) ?? DateTime(2000);
      return da.compareTo(db);
    }

    final list = result.toList();
    list.sort((a, b) {
      final cmp = compareByDate(a, b);
      return sort == OrdersSort.dateAsc ? cmp : -cmp;
    });

    return list;
  }
  
  // 🆕 Helper para obtener nombre del restaurante
  String getRestaurantName(int userId) {
    final name = profileCache[userId];
    if (name == null || name.isEmpty) {
      return 'Restaurant #$userId';
    }
    return name;
  }
}