import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:restock/features/alerts/domain/models/alert.dart';

class AlertCard extends StatelessWidget {
  final Alert alert;
  final Color baseColor;

  const AlertCard({
    required this.alert,
    required this.baseColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM dd, yyyy HH:mm').format(alert.date);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: baseColor, width: 4.0), 
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alert.message,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: baseColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    alert.situationDescription.replaceAll('_', ' '),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: baseColor,
                      fontSize: 13,
                    ),
                  ),
                ),

                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Order ID: #${alert.orderId}',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
