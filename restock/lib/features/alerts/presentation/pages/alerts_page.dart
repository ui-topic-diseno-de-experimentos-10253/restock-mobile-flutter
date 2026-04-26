import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:restock/features/alerts/domain/models/alert.dart';
import 'package:restock/features/alerts/presentation/blocs/alert_bloc.dart';
import 'package:restock/features/alerts/presentation/blocs/alert_event.dart';
import 'package:restock/features/alerts/presentation/blocs/alert_state.dart';
import 'package:restock/features/alerts/presentation/pages/alert_detail.dart';
import 'package:restock/features/alerts/presentation/widgets/alert_widget.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  static const Color _greenColor = Color(0xFF4F8A5B);
  static const Color _whiteColor = Colors.white;

  @override
  void initState() {
    super.initState();
    context.read<AlertBloc>().add(const AlertsLoadRequested());
  }

  Color _getAlertColor(String situation) {
    final status = situation.toUpperCase();

    switch (status) {
      case 'APPROVED':
      case 'PREPARING':
        return _greenColor;
      case 'ON_THE_WAY':
        return Colors.blue.shade700;
      case 'PENDING':
        return Colors.orange.shade700;
      case 'DELIVERED':
        return Colors.grey.shade500;
      case 'DECLINED':
      case 'CANCELLED':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _whiteColor,
      appBar: AppBar(
        title: const Text(
          'Alerts & Order Tracking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _whiteColor,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AlertBloc>().add(const AlertsLoadRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<AlertBloc, AlertState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(
              child: CircularProgressIndicator(color: _greenColor),
            );
          }

          if (state.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading alerts: ${state.error}',
                  style: TextStyle(color: Colors.red.shade700, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final List<Alert> displayedAlerts = state.supplierAlerts;

          if (displayedAlerts.isEmpty) {
            return const Center(
              child: Text(
                'No alerts found. Everything looks clear!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: displayedAlerts.length,
            itemBuilder: (context, index) {
              final alert = displayedAlerts[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AlertDetailPage(alert: alert),
                    ),
                  );
                },
                child: AlertCard(
                  alert: alert,
                  baseColor: _getAlertColor(alert.situationDescription),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
