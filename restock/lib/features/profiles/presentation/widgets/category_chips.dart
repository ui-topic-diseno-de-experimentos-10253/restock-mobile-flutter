import 'package:flutter/material.dart';
import 'package:restock/features/profiles/domain/models/business_category.dart';

class CategoryChips extends StatelessWidget {
  final List<BusinessCategory> categories;

  const CategoryChips({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'No categories',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color:  Color.fromRGBO(92, 164, 104, 1),
              ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories
          .map(
            (category) => Chip(
              label: Text(category.name),
              avatar: Icon(
                Icons.category,
                size: 18,
              ),
            ),
          )
          .toList(),
    );
  }
}
