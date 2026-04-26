class BusinessCategory {
  final String id;
  final String name;

  const BusinessCategory({
    required this.id,
    required this.name,
  });

  BusinessCategory copyWith({
    String? id,
    String? name,
  }) {
    return BusinessCategory(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}