import 'dart:convert';

List<AddressModel> addressListFromJson(String str) =>
    List<AddressModel>.from(json.decode(str)["data"].map((x) => AddressModel.fromJson(x)));

class AddressModel {
  final int id;
  final int userId;
  final String? fullName;
  final String address;
  final double lat;
  final double lng;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  AddressModel({
    required this.id,
    required this.userId,
    this.fullName,
    required this.address,
    required this.lat,
    required this.lng,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json["id"],
        userId: json["user_id"],
        fullName: json["full_name"],

        address: json["address"],
        lat: double.parse(json["lat"].toString()),
        lng: double.parse(json["lng"].toString()),
        isDefault: json["is_default"] ?? false,
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "full_name": fullName,
        "address": address,
        "lat": lat.toString(),
        "lng": lng.toString(),
        "is_default": isDefault,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}