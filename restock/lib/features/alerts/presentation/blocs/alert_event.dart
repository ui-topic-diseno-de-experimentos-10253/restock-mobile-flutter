// Archivo: restock/features/resource/alerts/presentation/blocs/alert_event.dart

abstract class AlertEvent {
  const AlertEvent();
}

class AlertsLoadRequested extends AlertEvent {
  const AlertsLoadRequested();
}

class AlertsClearRequested extends AlertEvent {
  const AlertsClearRequested();
}

