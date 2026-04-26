import 'package:restock/features/alerts/domain/models/alert.dart';

abstract class AlertRepository {
  Future<List<Alert>> getAlertsBySupplier();
  Future<List<Alert>> getAlertsByRestaurantAdmin();
  
}