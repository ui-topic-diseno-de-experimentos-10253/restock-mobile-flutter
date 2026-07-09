// lib/features/resource/inventory/presentation/pages/supply_detail_by_id_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/features/resource/inventory/domain/models/custom_supply.dart';
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_bloc.dart';
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_event.dart';
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_state.dart';
import 'package:restock/features/resource/inventory/presentation/pages/supply_detail_page.dart';

/// Loads and displays a [SupplyDetailPage] by [customSupplyId] string.
/// Used when navigating from a push notification deep-link.
class SupplyDetailByIdPage extends StatefulWidget {
  final String customSupplyId;

  const SupplyDetailByIdPage({super.key, required this.customSupplyId});

  @override
  State<SupplyDetailByIdPage> createState() => _SupplyDetailByIdPageState();
}

class _SupplyDetailByIdPageState extends State<SupplyDetailByIdPage> {
  @override
  void initState() {
    super.initState();
    // Ensure inventory data is loaded so we can look up the supply.
    context.read<InventoryBloc>().add(const InventoryLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        if (state.loading && state.customSupplies.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Supply Details')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        CustomSupply? found;
        try {
          found = state.customSupplies.firstWhere(
            (cs) => cs.id.toString() == widget.customSupplyId,
          );
        } catch (_) {
          found = null;
        }

        if (found == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Supply Details')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Insumo #${widget.customSupplyId} no encontrado',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            ),
          );
        }

        // Delegate to the existing SupplyDetailPage.
        return SupplyDetailPage(customSupply: found);
      },
    );
  }
}
