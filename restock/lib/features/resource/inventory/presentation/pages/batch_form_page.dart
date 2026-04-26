import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:restock/features/resource/inventory/domain/models/batch.dart';
import 'package:restock/features/resource/inventory/domain/models/custom_supply.dart';
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_bloc.dart';
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_event.dart';
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_state.dart';

class BatchFormPage extends StatefulWidget {
  final Batch? existingBatch;

  const BatchFormPage({super.key, this.existingBatch});

  @override
  State<BatchFormPage> createState() => _BatchFormPageState();
}

class _BatchFormPageState extends State<BatchFormPage> {
  int? selectedCustomId;
  CustomSupply? selectedCustom;

  String stock = '';
  String? expirationDate; // yyyy-MM-dd o null
  bool _initializedFromExisting = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingBatch;
    if (existing != null) {
      stock = existing.stock.toString();
      expirationDate = existing.expirationDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    const greenColor = Color(0xFF4F8A5B);
    const whiteColor = Colors.white;
    final isEditing = widget.existingBatch != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Batch' : 'Add Batch'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: whiteColor,
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          final customSupplies = state.customSupplies;

          // Inicializar valores si estamos editando
          if (isEditing &&
              !_initializedFromExisting &&
              customSupplies.isNotEmpty) {
            final existingId = widget.existingBatch!.customSupply?.id;
            if (existingId != null) {
              selectedCustomId = existingId;
              selectedCustom = customSupplies
                  .firstWhereOrNull((cs) => cs.id == existingId);
            }
            _initializedFromExisting = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Custom Supply',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<int>(
                  value: selectedCustomId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select custom supply',
                  ),
                  items: customSupplies
                      .map(
                        (cs) => DropdownMenuItem<int>(
                          value: cs.id,
                          child: Text(cs.supply?.name ?? 'No name'),
                        ),
                      )
                      .toList(),
                  onChanged: (id) {
                    if (id == null) return;
                    setState(() {
                      selectedCustomId = id;
                      selectedCustom = customSupplies
                          .firstWhereOrNull((cs) => cs.id == id);
                      // resetear fecha si cambiamos de supply
                      expirationDate = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Stock',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => stock = v,
                  controller: TextEditingController(text: stock)
                    ..selection =
                        TextSelection.collapsed(offset: stock.length),
                ),
                const SizedBox(height: 16),
                // Sólo mostramos fecha si el supply es perecible
                if (selectedCustom?.supply?.perishable == true)
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Expiration date (yyyy-MM-dd)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: expirationDate ?? '',
                    ),
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: now,
                        lastDate: DateTime(now.year + 10),
                        initialDate: now,
                      );
                      if (picked != null) {
                        setState(() {
                          expirationDate = picked
                              .toIso8601String()
                              .split('T')
                              .first; // yyyy-MM-dd
                        });
                      }
                    },
                  ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenColor,
                      foregroundColor: whiteColor,
                      minimumSize: const Size(140, 48),
                    ),
                    onPressed: () {
                      if (selectedCustom == null || stock.isEmpty) {
                        // TODO: snackbar de validación
                        return;
                      }

                      final isPerishable =
                          selectedCustom!.supply?.perishable == true;

                      final String? finalExp = isPerishable
                          ? (expirationDate?.isEmpty ?? true
                              ? null
                              : expirationDate)
                          : '9999-12-31';

                      final newBatch = Batch(
                        id: widget.existingBatch?.id ?? '',
                        userId: widget.existingBatch?.userId ?? 1, // TODO real
                        userRoleId: widget.existingBatch?.userRoleId,
                        customSupply: selectedCustom!,
                        stock: double.tryParse(stock) ?? 0.0,
                        expirationDate: finalExp,
                      );

                      final bloc = context.read<InventoryBloc>();

                      if (isEditing) {
                        bloc.add(UpdateBatchEvent(newBatch));
                      } else {
                        bloc.add(CreateBatchEvent(newBatch));
                      }

                      Navigator.pop(context);
                    },
                    child: Text(isEditing ? 'Update batch' : 'Save batch'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Helper
extension FirstWhereOrNull<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E e) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
