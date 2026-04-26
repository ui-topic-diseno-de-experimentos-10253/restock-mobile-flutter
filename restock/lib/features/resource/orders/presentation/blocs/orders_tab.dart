// lib/features/resource/orders/presentation/blocs/orders_tab.dart

enum OrdersTab {
  newOrders,     // Órdenes recibidas pendientes de evaluar
  currentOrders, // Órdenes aceptadas/en proceso
  historyOrders, // Órdenes completadas / rechazadas / canceladas
}

extension OrdersTabX on OrdersTab {
  String get label {
    switch (this) {
      case OrdersTab.newOrders:
        return 'New Orders';
      case OrdersTab.currentOrders:
        return 'Your Orders';
      case OrdersTab.historyOrders:
        return 'History Orders';
    }
  }
}
