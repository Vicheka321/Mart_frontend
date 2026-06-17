// To parse this JSON data, do
//
//     final orderDetailModel = orderDetailModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

OrderDetailModel orderDetailModelFromJson(String str) =>
    OrderDetailModel.fromJson(json.decode(str));

String orderDetailModelToJson(OrderDetailModel data) =>
    json.encode(data.toJson());

class OrderDetailModel {
  bool success;
  Data data;

  OrderDetailModel({required this.success, required this.data});

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) =>
      OrderDetailModel(
        success: json["success"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data.toJson()};
}

class Data {
  int id;
  String total;
  String paymentMethod;
  String paymentStatus;
  String phone;
  String address;
  String createdAt;

  List<Item> items;

  Data({
    required this.id,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.phone,
    required this.address,
    required this.createdAt,
    required this.items,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"] ?? 0,
    total: json["total"]?.toString() ?? "0.00",
    paymentMethod: json["payment_method"] ?? "",
    paymentStatus: json["payment_status"] ?? "",
    phone: json["phone"] ?? "",
    address: json["address"] ?? "",
    createdAt: json["created_at"] ?? "",
    items: json["items"] == null
        ? []
        : List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "total": total,
    "payment_method": paymentMethod,
    "payment_status": paymentStatus,
    "phone": phone,
    "address": address,
    "created_at": createdAt,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class Item {
  int productId;
  String name;
  int qty;
  String price;
  String image;

  Item({
    required this.productId,
    required this.name,
    required this.qty,
    required this.price,
    required this.image,
  });

factory Item.fromJson(Map<String, dynamic> json) => Item(
  productId: json["product_id"] ?? 0,
  name: json["name"] ?? "",
  qty: json["qty"] ?? 0,
  price: json["price"]?.toString() ?? "0",
  image: json["image"] ?? "",
);

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "name": name,
    "qty": qty,
    "price": price,
    "image": image,
  };
}
