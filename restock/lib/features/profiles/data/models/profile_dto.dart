import 'package:restock/features/profiles/data/models/category_dto.dart';
import 'package:restock/features/profiles/domain/models/profile.dart';

class ProfileDto {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? address;
  final String? country;
  final String? avatar;
  final String? businessName;
  final String? businessAddress;
  final String? description;
  final List<CategoryDto>? businessCategories;

  const ProfileDto({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.address,
    this.country,
    this.avatar,
    this.businessName,
    this.businessAddress,
    this.description,
    this.businessCategories,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    final List rawCategories = json['businessCategories'] ?? [];

    return ProfileDto(
      id: json['userId'] ?? 0,
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      country: json['country'],
      avatar: json['avatar'],
      businessName: json['businessName'],
      businessAddress: json['businessAddress'],
      description: json['description'],
      businessCategories: rawCategories
          .map((e) => CategoryDto.fromJson(e))
          .toList()
          .cast<CategoryDto>(),
    );
  }

  Profile toDomain() {
    return Profile(
      id: id,
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      email: email ?? '',
      phone: phone ?? '',
      address: address ?? '',
      country: country ?? '',
      avatar: avatar,
      businessName: businessName ?? '',
      businessAddress: businessAddress ?? '',
      description: description,
      categories: businessCategories!.map((c) => c.toDomain()).toList(),
    );
  }
}
