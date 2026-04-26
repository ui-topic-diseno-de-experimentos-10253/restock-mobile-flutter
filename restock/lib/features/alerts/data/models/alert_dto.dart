
import 'package:restock/features/alerts/domain/models/alert.dart';

class AlertDto {
  final int? id;
  final String? message;
  final int? orderId;
  final String? date; 
  final int? supplierId;
  final int? adminRestaurantId;
  final String? situationDescription;

  const AlertDto({
    this.id,
    this.message,
    this.orderId,
    this.date,
    this.supplierId,
    this.adminRestaurantId,
    this.situationDescription,
  });

  factory AlertDto.fromJson(Map<String, dynamic> json) {
    return AlertDto(
      id: json['id'],
      message: json['message'],
      orderId: json['orderId'],
      date: json['date'],
      supplierId: json['supplierId'],
      adminRestaurantId: json['adminRestaurantId'],
      situationDescription: json['situationDescription'],
    );
  }


  Alert toDomain() {
    return Alert(
      id: id ?? 0,
      message: message ?? 'No message',
      orderId: orderId ?? 0,
      date: date != null ? DateTime.parse(date!) : DateTime.now(), 
      supplierId: supplierId ?? 0,
      adminRestaurantId: adminRestaurantId ?? 0,
      situationDescription: situationDescription ?? 'PENDING',
    );
  }
}