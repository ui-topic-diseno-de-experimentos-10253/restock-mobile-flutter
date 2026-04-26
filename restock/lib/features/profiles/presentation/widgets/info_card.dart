import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final IconData headerIcon;
  final String headerTitle;
  final VoidCallback? onEdit;
  final List<InfoItem> items;

  const InfoCard({
    super.key,
    required this.headerIcon,
    required this.headerTitle,
    this.onEdit,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  headerIcon,
                  size: 24,
                  color:  Color.fromRGBO(92, 164, 104, 1),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    headerTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                  ),
              ],
            ),
            const Divider(height: 24),
            ...items.map((item) => _InfoItemWidget(item: item)),
          ],
        ),
      ),
    );
  }
}

class InfoItem {
  final IconData icon;
  final String label;
  final String value;

  const InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _InfoItemWidget extends StatelessWidget {
  final InfoItem item;

  const _InfoItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            item.icon,
            size: 20,
            color:  Color.fromRGBO(92, 164, 104, 1)
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:  Color.fromRGBO(92, 164, 104, 1),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
