// To parse this JSON data, do
//
//     final myProfileModel = myProfileModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

MyProfileModel myProfileModelFromJson(String str) =>
    MyProfileModel.fromJson(json.decode(str));

String myProfileModelToJson(MyProfileModel data) => json.encode(data.toJson());

class MyProfileModel {
  int id;
  String fullName;
  String email;
  String phone;
  String avatar;
  DateTime createdAt;

  MyProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.createdAt,
  });

  /// Full name helper
  // String get name => '$fullName';

  factory MyProfileModel.fromJson(Map<String, dynamic> json) => MyProfileModel(
    id: json["id"],
    fullName: json["full_name"] ?? '',
    email: json["email"] ?? '',
    phone: json["phone"] ?? '',
    avatar: json["avatar"] ?? '',
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "full_name": fullName,
    "email": email,
    "phone": phone,
    "avatar": avatar,
    "created_at": createdAt.toIso8601String(),
  };
}
