
import 'package:restock/features/profiles/domain/models/business_category.dart';

class Profile {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String country;
  final String? avatar;
  final String businessName;
  final String businessAddress;
  final String? description;
  final List<BusinessCategory> categories;

  const Profile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.country,
    this.avatar,
    required this.businessName,
    required this.businessAddress,
    this.description,
    this.categories = const [],
  });

  Profile copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? country,
    String? avatar,
    String? businessName,
    String? businessAddress,
    String? description,
    List<BusinessCategory>? categories,
  }) {
    return Profile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      country: country ?? this.country,
      avatar: avatar ?? this.avatar,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      description: description ?? this.description,
      categories: categories ?? this.categories,
    );
  }
}
