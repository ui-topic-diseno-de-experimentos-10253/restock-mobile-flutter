import 'package:flutter/material.dart';
import 'package:restock/features/resource/inventory/domain/models/custom_supply.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_bloc.dart';
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_event.dart';
import 'package:restock/features/resource/inventory/presentation/pages/supply_form_page.dart';

class SupplyDetailPage extends StatelessWidget {
  final CustomSupply? customSupply;

  const SupplyDetailPage({super.key, required this.customSupply});

  @override
  Widget build(BuildContext context) {
    if (customSupply == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Supply Details')),
        body: const Center(child: Text('Supply not found')),
      );
    }

    final supply = customSupply!.supply;
    final greenColor = const Color(0xFF4F8A5B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supply Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SupplyFormPage(existingSupply: customSupply),
                  ),
                );
              } else if (value == 'delete') {
                context.read<InventoryBloc>().add(
                      DeleteCustomSupplyEvent(customSupply!.id),
                    );
                Navigator.pop(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
            icon: const Icon(Icons.more_vert), // los tres puntitos
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              supply?.name ?? 'Unnamed Supply',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _InfoTile(
                        label: 'Description', value: customSupply!.description),
                    const Divider(height: 1),
                    _InfoTile(
                        label: 'Min Stock', value: '${customSupply!.minStock}'),
                    const Divider(height: 1),
                    _InfoTile(
                        label: 'Max Stock', value: '${customSupply!.maxStock}'),
                    const Divider(height: 1),
                    _InfoTile(label: 'Unit', value: customSupply!.unit.name),
                    const Divider(height: 1),
                    _InfoTile(
                        label: 'Abbreviation',
                        value: customSupply!.unit.abbreviation),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      dense: true,
      title: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }
}
