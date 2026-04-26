 

enum OrderState {
  onHold,
  preparing,
  onTheWay,
  delivered,
}

extension OrderStateX on OrderState {
  bool get isFinished => this == OrderState.delivered;

    String get apiValue {
    switch (this) {
      case OrderState.onHold:
        return 'ON_HOLD';
      case OrderState.preparing:
        return 'PREPARING';
      case OrderState.onTheWay:
        return 'ON_THE_WAY';
      case OrderState.delivered:
        return 'DELIVERED';
    }
  } 
}
