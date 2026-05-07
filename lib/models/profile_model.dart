// To parse this JSON data, do
//
//     final myProfileModel = myProfileModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

MyProfileModel myProfileModelFromJson(String str) => MyProfileModel.fromJson(json.decode(str));

String myProfileModelToJson(MyProfileModel data) => json.encode(data.toJson());

class MyProfileModel {
    int id;
    String name;
    String email;
    dynamic phone;
    dynamic avatar;
    DateTime createdAt;

    MyProfileModel({
        required this.id,
        required this.name,
        required this.email,
        required this.phone,
        required this.avatar,
        required this.createdAt,
    });

    factory MyProfileModel.fromJson(Map<String, dynamic> json) => MyProfileModel(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        avatar: json["avatar"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "avatar": avatar,
        "created_at": createdAt.toIso8601String(),
    };
}
