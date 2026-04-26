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
    final greenColor = const Color(0xFF4F8A5B);
    final redColor = const Color(0xFFD9534F);
    final grayColor = const Color(0xFF9E9E9E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inventory (Batches)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),

        // Buscador
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search supply or batch...',
            border: OutlineInputBorder(),
          ),
          onChanged: onSearchChange,
        ),
        const SizedBox(height: 8),

        // Importante: SIN Expanded, para que funcione dentro de SingleChildScrollView
        ListView.separated(
          itemCount: batches.length,
          shrinkWrap: shrinkWrap, // 👈 clave cuando está dentro de scroll padre
          physics: shrinkWrap
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics(),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final batch = batches[index];
            final supply = batch.customSupply?.supply;
            final isNonPerishable = batch.expirationDate == '9999-12-31';
            final isPerishable = supply?.perishable == true;

            return Card(
              color: const Color(0xFFF8F8F8),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                supply?.name ?? 'No name',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (isNonPerishable)
                                Text(
                                  'Non-perishable',
                                  style: TextStyle(
                                    color: greenColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                )
                              else if (isPerishable)
                                Text(
                                  'Perishable',
                                  style: TextStyle(
                                    color: redColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => onBatchClick(batch.id),
                          icon: Icon(Icons.remove_red_eye, color: greenColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Stock: ${batch.stock}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 12),
                        if (batch.customSupply != null) ...[
                          Text(
                            'Min: ${batch.customSupply!.minStock}',
                            style: TextStyle(
                              color: grayColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Max: ${batch.customSupply!.maxStock}',
                            style: TextStyle(
                              color: grayColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (batch.customSupply != null)
                      Text(
                        'Unit: ${batch.customSupply!.unit.name}',
                        style: TextStyle(color: grayColor, fontSize: 12),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          supply?.category ?? '-',
                          style: TextStyle(color: grayColor, fontSize: 12),
                        ),
                        Text(
                          isNonPerishable
                              ? 'Non-perishable'
                              : 'Expires: ${batch.expirationDate ?? '-'}',
                          style: TextStyle(
                            color: isNonPerishable ? greenColor : redColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
