

class Alert {
  final int id;
  final String message;
  final int orderId;
  final DateTime date; 
  final int supplierId;
  final int adminRestaurantId;
  final String situationDescription; 
  
  const Alert({
    required this.id,
    required this.message,
    required this.orderId,
    required this.date,
    required this.supplierId,
    required this.adminRestaurantId,
    required this.situationDescription,
  });

  Alert copyWith({
    int? id,
    String? message,
    int? orderId,
    DateTime? date,
    int? supplierId,
    int? adminRestaurantId,
    String? situationDescription,
  }) {
    return Alert(
      id: id ?? this.id,
      message: message ?? this.message,
      orderId: orderId ?? this.orderId,
      date: date ?? this.date,
      supplierId: supplierId ?? this.supplierId,
      adminRestaurantId: adminRestaurantId ?? this.adminRestaurantId,
      situationDescription: situationDescription ?? this.situationDescription,
    );
  }
}