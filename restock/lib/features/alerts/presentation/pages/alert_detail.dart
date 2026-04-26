
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restock/features/alerts/domain/models/alert.dart';

class AlertDetailPage extends StatelessWidget {
  final Alert alert;

  const AlertDetailPage({required this.alert, super.key});

  static const Color _greenColor = Color(0xFF4F8A5B);

  Color _getDetailColor(String situation) {
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

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _getDetailColor(value).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getDetailColor(value), width: 1),
              ),
              child: Text(
                value.replaceAll('_', ' '),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getDetailColor(value),
                  fontSize: 16,
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          const Divider(height: 20, color: Colors.grey),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _getDetailColor(alert.situationDescription);
    final formattedDate = DateFormat('EEEE, MMM dd, yyyy - HH:mm').format(alert.date);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Alert #${alert.id}'),
        backgroundColor: Colors.white,
        foregroundColor: color, 
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.notifications_active,
                color: color,
                size: 60,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: _buildDetailRow(
                'Current Situation',
                alert.situationDescription,
                isStatus: true,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Alert Message:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                alert.message,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 20),
            
            _buildDetailRow('Order ID', '#${alert.orderId}'),
            _buildDetailRow('Date', formattedDate),
            _buildDetailRow('Supplier ID', alert.supplierId.toString()),
            _buildDetailRow('Restaurant Admin ID', alert.adminRestaurantId.toString()),
            
            const SizedBox(height: 40),
            
          ],
        ),
      ),
    );
  }
}
