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
  String firstName;
  String lastName;
  String email;
  dynamic phone;
  dynamic avatar;
  DateTime createdAt;

  MyProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.createdAt,
  });

  /// Full name helper
  String get name => '$firstName $lastName'.trim();

  factory MyProfileModel.fromJson(Map<String, dynamic> json) => MyProfileModel(
    id: json["id"],
    firstName: json["first_name"] ?? '',
    lastName: json["last_name"] ?? '',
    email: json["email"] ?? '',
    phone: json["phone"],
    avatar: json["avatar"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "phone": phone,
    "avatar": avatar,
    "created_at": createdAt.toIso8601String(),
  };
}
