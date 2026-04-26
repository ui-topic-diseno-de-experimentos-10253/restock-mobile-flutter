import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:restock/features/resource/inventory/domain/models/custom_supply.dart';
import 'package:restock/features/resource/inventory/domain/models/supply.dart';
import 'package:restock/features/resource/inventory/domain/models/unit_model.dart';
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_bloc.dart';
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_event.dart';
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_state.dart';

class SupplyFormPage extends StatefulWidget {
  final CustomSupply? existingSupply;

  const SupplyFormPage({super.key, this.existingSupply});

  @override
  State<SupplyFormPage> createState() => _SupplyFormPageState();
}

class _SupplyFormPageState extends State<SupplyFormPage> {
  String? selectedCategory;
  int? selectedSupplyId;

  String description = '';
  String minStock = '';
  String maxStock = '';

  // nombre, abreviatura
  final List<(String, String)> unitOptions = const [
    ('Kilogram', 'kg'),
    ('Gram', 'g'),
    ('Liter', 'L'),
    ('Unit', 'u'),
  ];
  (String, String) selectedUnit = ('Kilogram', 'kg');

  bool _initializedFromExisting = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingSupply;
    if (existing != null) {
      description = existing.description;
      minStock = existing.minStock.toString();
      maxStock = existing.maxStock.toString();
      selectedUnit = (existing.unit.name, existing.unit.abbreviation);
      selectedCategory = existing.supply?.category;
      // selectedSupplyId lo seteamos cuando tengamos la lista de supplies
    }
  }

  @override
  Widget build(BuildContext context) {
    final greenColor = const Color(0xFF4F8A5B);
    final isEditing = widget.existingSupply != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Supply' : 'Add Supply'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          final supplies = state.supplies;

          // categorías únicas
          final categories = supplies
              .map((s) => s.category)
              .where((c) => c != null && c!.isNotEmpty)
              .cast<String>()
              .toSet()
              .toList()
            ..sort();

          // si estamos editando, inicializamos supplyId una sola vez
          if (widget.existingSupply != null &&
              !_initializedFromExisting &&
              supplies.isNotEmpty) {
            final existingId = widget.existingSupply!.supplyId;
            selectedSupplyId = existingId;
            _initializedFromExisting = true;
          }

          // filtrar por categoría
          final filteredSupplies = selectedCategory == null ||
                  selectedCategory!.isEmpty
              ? supplies
              : supplies
                  .where((s) => s.category == selectedCategory)
                  .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Category',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select category',
                  ),
                  items: categories
                      .map(
                        (c) => DropdownMenuItem<String>(
                          value: c,
                          child: Text(c),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                      selectedSupplyId = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Base Supply',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<int>(
                  value: selectedSupplyId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select base supply',
                  ),
                  items: filteredSupplies
                      .map(
                        (s) => DropdownMenuItem<int>(
                          value: s.id,
                          child: Text(s.name),
                        ),
                      )
                      .toList(),
                  onChanged: (id) {
                    setState(() {
                      selectedSupplyId = id;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onChanged: (v) => description = v,
                  controller: TextEditingController(text: description)
                    ..selection = TextSelection.collapsed(
                      offset: description.length,
                    ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Minimum Stock',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => minStock = v,
                  controller: TextEditingController(text: minStock)
                    ..selection =
                        TextSelection.collapsed(offset: minStock.length),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Maximum Stock',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => maxStock = v,
                  controller: TextEditingController(text: maxStock)
                    ..selection =
                        TextSelection.collapsed(offset: maxStock.length),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unit',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: selectedUnit.$1,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: unitOptions
                      .map(
                        (u) => DropdownMenuItem<String>(
                          value: u.$1,
                          child: Text('${u.$1} (${u.$2})'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedUnit =
                          unitOptions.firstWhere((u) => u.$1 == value);
                    });
                  },
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(140, 48),
                    ),
                    onPressed: () {
                      if (selectedSupplyId == null ||
                          minStock.isEmpty ||
                          maxStock.isEmpty) {
                        // TODO: mostrar snackbar de validación
                        return;
                      }

                      final Supply? baseSupply = supplies.firstWhereOrNull(
                        (s) => s.id == selectedSupplyId,
                      );

                      if (baseSupply == null) return;

                      final custom = CustomSupply(
                        id: widget.existingSupply?.id ?? 0,
                        minStock: int.tryParse(minStock) ?? 0,
                        maxStock: int.tryParse(maxStock) ?? 0,
                        price: widget.existingSupply?.price ?? 0.0,
                        userId: widget.existingSupply?.userId,
                        supplyId: baseSupply.id,
                        supply: baseSupply,
                        unit: UnitModel(name: selectedUnit.$1, abbreviation: selectedUnit.$2),
                        currencyCode: widget.existingSupply?.currencyCode ?? 'PEN',
                        description: description,
                      );

                      final bloc = context.read<InventoryBloc>();

                      if (isEditing) {
                        bloc.add(UpdateCustomSupplyEvent(custom));
                      } else {
                        bloc.add(CreateCustomSupplyEvent(custom));
                      }

                      Navigator.pop(context);
                    },
                    child: Text(isEditing ? 'Update' : 'Save'),
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

// helper
extension FirstWhereOrNull<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E e) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
