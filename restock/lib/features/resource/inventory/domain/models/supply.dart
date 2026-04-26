 
class Supply {
  final int id;
  final String name;
  final String? description;
  final bool perishable;
  final String? category;

  const Supply({
    required this.id,
    required this.name,
    this.description,
    required this.perishable,
    this.category,
  });

  Supply copyWith({
    int? id,
    String? name,
    String? description,
    bool? perishable,
    String? category,
  }) {
    return Supply(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      perishable: perishable ?? this.perishable,
      category: category ?? this.category,
    );
  }
}
