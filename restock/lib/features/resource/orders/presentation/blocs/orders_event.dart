 
import 'package:restock/features/resource/orders/domain/models/order.dart';
import 'package:restock/features/resource/orders/domain/models/order_state.dart';
import 'package:restock/features/resource/orders/domain/models/order_situation.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_tab.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_sort.dart';

abstract class OrdersEvent {
  const OrdersEvent();
}

/// Carga inicial para el proveedor
class OrdersStarted extends OrdersEvent {
  final int supplierId;
  const OrdersStarted(this.supplierId);
}

/// Pull-to-refresh (usa el supplierId del state)
class OrdersRefreshRequested extends OrdersEvent {
  const OrdersRefreshRequested();
}

/// Cambiar pestaña New / Current / History
class OrdersTabChanged extends OrdersEvent {
  final OrdersTab tab;
  const OrdersTabChanged(this.tab);
}

/// Texto de búsqueda
class OrdersSearchChanged extends OrdersEvent {
  final String query;
  const OrdersSearchChanged(this.query);
}

/// Cambiar ordenamiento (fecha)
class OrdersSortChanged extends OrdersEvent {
  final OrdersSort sort;
  const OrdersSortChanged(this.sort);
}

/// Filtro por estado (On hold, Preparing, ...)
class OrdersStateFilterChanged extends OrdersEvent {
  final OrderState? stateFilter;
  const OrdersStateFilterChanged(this.stateFilter);
}

/// Actualizar estado / situación desde la pantalla de gestión
class OrderStateUpdateRequested extends OrdersEvent {
  final int orderId;
  final OrderState newState;
  final OrderSituation newSituation;

  const OrderStateUpdateRequested({
    required this.orderId,
    required this.newState,
    required this.newSituation,
  });
}

/// Exportar historial a Excel
class OrdersExportToExcel extends OrdersEvent {
  const OrdersExportToExcel();
}

class OrderUpdateRequested extends OrdersEvent {
  final Order updatedOrder;

  const OrderUpdateRequested(this.updatedOrder);

  @override
  List<Object?> get props => [updatedOrder];
}
