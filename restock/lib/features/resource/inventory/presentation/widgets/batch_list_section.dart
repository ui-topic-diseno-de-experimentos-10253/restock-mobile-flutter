import 'package:flutter/material.dart';
import 'package:restock/features/resource/inventory/domain/models/batch.dart';

class BatchListSection extends StatelessWidget {
  final List<Batch> batches;
  final String searchQuery;
  final ValueChanged<String> onSearchChange;
  final void Function(String batchId) onBatchClick;
  final bool shrinkWrap; 
  
  const BatchListSection({
    super.key,
    required this.batches,
    required this.searchQuery,
    required this.onSearchChange,
    required this.onBatchClick,
    this.shrinkWrap = false, // por defecto false
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    const alertRed = Color(0xFFE53935);
    const alertOrange = Color(0xFFFB8C00);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inventory Batches / Lots',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Search Field
        TextField(
          onChanged: onSearchChange,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search products or batch ID...',
          ),
        ),
        const SizedBox(height: 16),

        if (batches.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.04)),
            ),
            child: Column(
              children: [
                Icon(Icons.layers_clear_outlined, size: 40, color: primaryColor.withOpacity(0.4)),
                const SizedBox(height: 12),
                Text(
                  'No batches registered',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            itemCount: batches.length,
            shrinkWrap: shrinkWrap,
            physics: shrinkWrap
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final batch = batches[index];
              final supply = batch.customSupply?.supply;
              final isNonPerishable = batch.expirationDate == '9999-12-31';
              final isPerishable = supply?.perishable == true;

              // Check if expiring soon (e.g., in 7 days or less)
              bool isExpiringSoon = false;
              int daysToExpire = 999;
              if (batch.expirationDate != null && !isNonPerishable) {
                try {
                  final expDate = DateTime.parse(batch.expirationDate!);
                  final difference = expDate.difference(DateTime.now()).inDays;
                  daysToExpire = difference;
                  if (difference >= 0 && difference <= 7) {
                    isExpiringSoon = true;
                  }
                } catch (_) {}
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                supply?.name ?? 'Unnamed Batch Product',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Batch ID: #${batch.id.substring(0, batch.id.length > 8 ? 8 : batch.id.length)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.black45,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => onBatchClick(batch.id),
                            icon: Icon(Icons.edit_outlined, size: 18, color: primaryColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Stats Row
                    Row(
                      children: [
                        Icon(Icons.inventory_outlined, size: 16, color: primaryColor),
                        const SizedBox(width: 6),
                        Text(
                          'Stock: ',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                        ),
                        Text(
                          '${batch.stock} ${batch.customSupply?.unit.abbreviation ?? ""}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0xFFF1F1F1)),
                    const SizedBox(height: 10),

                    // Footer with Expiration Tags
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          supply?.category ?? 'General',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black45,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isNonPerishable
                                ? primaryColor.withOpacity(0.08)
                                : isExpiringSoon
                                    ? alertRed.withOpacity(0.08)
                                    : alertOrange.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isNonPerishable
                                    ? Icons.check_circle_outline
                                    : Icons.timer_outlined,
                                size: 14,
                                color: isNonPerishable
                                    ? primaryColor
                                    : isExpiringSoon
                                        ? alertRed
                                        : alertOrange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isNonPerishable
                                    ? 'Non-perishable'
                                    : isExpiringSoon
                                        ? 'Expiring soon (${daysToExpire}d)'
                                        : 'Expires: ${batch.expirationDate}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isNonPerishable
                                      ? primaryColor
                                      : isExpiringSoon
                                          ? alertRed
                                          : alertOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
