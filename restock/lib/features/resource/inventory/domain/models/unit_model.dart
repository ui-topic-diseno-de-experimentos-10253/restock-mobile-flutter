class UnitModel {
  final String name;
  final String abbreviation;

  const UnitModel({
    required this.name,
    required this.abbreviation,
  });

  UnitModel copyWith({
    String? name,
    String? abbreviation,
  }) {
    return UnitModel(
      name: name ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
    );
  }
}