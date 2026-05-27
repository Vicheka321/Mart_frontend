// To parse this JSON data, do
//
//     final bannersModel = bannersModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

List<BannersModel> bannersModelFromJson(String str) => List<BannersModel>.from(
  json.decode(str).map((x) => BannersModel.fromJson(x)),
);

String bannersModelToJson(List<BannersModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BannersModel {
  int id;
  String title;
  String imageUrl;
  int sortOrder;
  bool status;
  dynamic startDate;
  dynamic endDate;
  DateTime createdAt;
  DateTime updatedAt;

  BannersModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.sortOrder,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BannersModel.fromJson(Map<String, dynamic> json) => BannersModel(
    id: json["id"],
    title: json["title"] ?? '',
    imageUrl: json["image_url"] ?? '',
    sortOrder: json["sort_order"] ?? 0,
    status: json["status"] ?? false,
    startDate: json["start_date"],
    endDate: json["end_date"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "image_url": imageUrl,
    "sort_order": sortOrder,
    "status": status,
    "start_date": startDate,
    "end_date": endDate,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
