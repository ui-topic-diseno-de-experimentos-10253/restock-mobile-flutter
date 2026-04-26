import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:restock/features/resource/inventory/domain/models/batch.dart';
import 'package:restock/features/resource/inventory/domain/models/custom_supply.dart';
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_bloc.dart';
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_event.dart';
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_state.dart';
import 'package:restock/features/resource/inventory/presentation/pages/batch_form_page.dart';
import 'package:restock/features/resource/inventory/presentation/pages/supply_detail_page.dart';
import 'package:restock/features/resource/inventory/presentation/pages/supply_form_page.dart';
import 'package:restock/features/resource/inventory/presentation/pages/inventory_detail_page.dart';
import 'package:restock/features/resource/inventory/presentation/widgets/batch_list_section.dart';
import 'package:restock/features/resource/inventory/presentation/widgets/supply_catalog_section.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // carga inicial
    context.read<InventoryBloc>().add(const InventoryLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    const greenColor = Color(0xFF4F8A5B);
    const whiteColor = Colors.white;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(
          'Inventory Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: whiteColor,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BatchFormPage(),
            ),
          );
        },
        backgroundColor: greenColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New batch'),
      ),
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          if (state.loading && state.supplies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<CustomSupply> customSupplies = state.customSupplies;
          final List<Batch> batches = state.batches;

          // filtrado simple por nombre de supply
          final filteredSupplies = customSupplies.where((cs) {
            final name = cs.supply?.name ?? '';
            return name.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

          final filteredBatches = batches.where((b) {
            final name = b.customSupply?.supply?.name ?? '';
            return name.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

          return SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Catálogo de custom supplies
                SupplyCatalogSection(
                  supplies: filteredSupplies,
                  onAddSupplyClick: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SupplyFormPage(),
                      ),
                    );
                  },
                  onViewSupplyDetails: (custom) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SupplyDetailPage(customSupply: custom),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                // Lista de batches
                BatchListSection(
                  batches: filteredBatches,
                  searchQuery: searchQuery,
                  onSearchChange: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  onBatchClick: (batchId) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            InventoryDetailPage(batchId: batchId),
                      ),
                    );
                  },
                  shrinkWrap: true, // importante para evitar overflow
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
