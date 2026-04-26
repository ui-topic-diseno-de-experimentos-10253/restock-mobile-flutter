
enum OrderSituation {
  pending,
  approved,
  declined,
  cancelled,
}

extension OrderSituationX on OrderSituation {
  bool get isPending => this == OrderSituation.pending;
  bool get isApproved => this == OrderSituation.approved;
  bool get isDeclined => this == OrderSituation.declined;

  String get apiValue {
    switch (this) {
      case OrderSituation.pending:
        return 'PENDING';
      case OrderSituation.approved:
        return 'APPROVED';
      case OrderSituation.declined:
        return 'DECLINED';
      case OrderSituation.cancelled:
        return 'CANCELLED';
    }
  }
}