import 'package:flutter/material.dart';
import 'package:restock/features/resource/inventory/domain/models/custom_supply.dart';

class SupplyCatalogSection extends StatelessWidget {
  final List<CustomSupply> supplies;
  final VoidCallback onAddSupplyClick;
  final void Function(CustomSupply) onViewSupplyDetails;

  const SupplyCatalogSection({
    super.key,
    required this.supplies,
    required this.onAddSupplyClick,
    required this.onViewSupplyDetails,
  });

  @override
  Widget build(BuildContext context) {
    final greenColor = const Color(0xFF4F8A5B);
    const whiteColor = Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Supply Catalog',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                foregroundColor: whiteColor,
              ),
              onPressed: onAddSupplyClick,
              icon: const Icon(Icons.add),
              label: const Text('Supply'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: supplies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final custom = supplies[index];
              return _SupplyCard(
                custom: custom,
                onViewSupplyDetails: onViewSupplyDetails,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SupplyCard extends StatelessWidget {
  final CustomSupply custom;
  final void Function(CustomSupply) onViewSupplyDetails;

  const _SupplyCard({required this.custom, required this.onViewSupplyDetails});

  @override
  Widget build(BuildContext context) {
    final greenColor = const Color(0xFF4F8A5B);

    return Card(
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              custom.supply?.name ?? 'Unnamed',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                Chip(
                  label: Text(custom.unit.abbreviation),
                  backgroundColor: const Color(0xFFEFF9F1),
                ),
                Chip(
                  label: Text(custom.supply?.category ?? '-'),
                  backgroundColor: const Color(0xFFF2F2F2),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Stock: ${custom.minStock} ~ ${custom.maxStock}',
              style: const TextStyle(color: Colors.grey),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: greenColor),
                onPressed: () => onViewSupplyDetails(custom),
                icon: const Icon(Icons.remove_red_eye, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
