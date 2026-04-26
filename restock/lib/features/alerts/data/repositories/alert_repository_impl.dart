
import 'package:restock/features/alerts/data/remote/alert_service.dart';
import 'package:restock/features/alerts/domain/models/alert.dart';
import 'package:restock/features/alerts/domain/repositories/alert_repository.dart';

class AlertRepositoryImpl implements AlertRepository {
  final AlertService service;
  final Future<int?> Function() getUserId; 

  AlertRepositoryImpl({
    required this.service,
    required this.getUserId,
  });

  @override
  Future<List<Alert>> getAlertsBySupplier() async {
    try {
      final userId = await getUserId();
      if (userId == null) return [];
      
      final dtos = await service.getAlertsBySupplierId(userId);
      return dtos.map((e) => e.toDomain()).toList();
    } catch (e) {
      print('Error loading supplier alerts: $e');
      return [];
    }
  }

  @override
  Future<List<Alert>> getAlertsByRestaurantAdmin() async {
    try {
      final userId = await getUserId();
      if (userId == null) return [];
      
      final dtos = await service.getAlertsByAdminRestaurantId(userId);
      return dtos.map((e) => e.toDomain()).toList();
    } catch (e) {
      print('Error loading restaurant admin alerts: $e');
      return [];
    }
  }
}
