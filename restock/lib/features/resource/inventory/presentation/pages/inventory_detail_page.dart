import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:restock/features/resource/inventory/domain/models/batch.dart';
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_bloc.dart';
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_state.dart';
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_event.dart';
import 'batch_form_page.dart';

class InventoryDetailPage extends StatelessWidget {
  final String batchId;

  const InventoryDetailPage({super.key, required this.batchId});

  @override
  Widget build(BuildContext context) {
    final greenColor = const Color(0xFF4F8A5B);

    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        final Batch? batch =
            state.batches.where((b) => b.id == batchId).firstOrNull;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Batch Details'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: batch == null
                ? null
                : [
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BatchFormPage(existingBatch: batch),
                            ),
                          );
                        } else if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete batch'),
                              content: const Text(
                                'Are you sure you want to delete this batch?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            context.read<InventoryBloc>().add(
                                  DeleteBatchEvent(batch.id),
                                );
                            Navigator.pop(context);
                          }
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                      icon: const Icon(Icons.more_vert),
                    ),
                  ],
          ),
          body: batch == null
              ? const Center(child: Text('Batch not found'))
              : _BatchDetailContent(batch: batch, accentColor: greenColor),
        );
      },
    );
  }
}

class _BatchDetailContent extends StatelessWidget {
  final Batch batch;
  final Color accentColor;

  const _BatchDetailContent({required this.batch, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final customSupply = batch.customSupply;
    final supply = customSupply?.supply;
    final unit = customSupply?.unit;
    final isPerishable = supply?.perishable ?? false;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          // Supply Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Supply Information',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Divider(),
                  _DetailRow('Name', supply?.name ?? '-'),
                  _DetailRow('Description', supply?.description ?? '-'),
                  _DetailRow('Category', supply?.category ?? '-'),
                  _DetailRow('Perishable', isPerishable ? 'Yes' : 'No'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Custom Supply Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Custom Supply Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Divider(),
                  _DetailRow('Min stock', customSupply?.minStock.toString() ?? '-'),
                  _DetailRow('Max stock', customSupply?.maxStock.toString() ?? '-'),
                  _DetailRow('Price', customSupply?.price.toString() ?? '-'),
                  _DetailRow(
                    'Unit',
                    '${unit?.name ?? '-'} (${unit?.abbreviation ?? ''})',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Batch Data
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Batch Data',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Divider(),
                  _DetailRow('Current stock', batch.stock.toString()),
                  if (isPerishable)
                    _DetailRow('Expiration date', batch.expirationDate ?? '-'),
                  _DetailRow('Batch ID', batch.id),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
