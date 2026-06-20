// // To parse this JSON data, do
// //
// //     final myOrdersModel = myOrdersModelFromJson(jsonString);

// import 'dart:convert';

// MyOrdersModel myOrdersModelFromJson(String str) =>
//     MyOrdersModel.fromJson(json.decode(str));

// String myOrdersModelToJson(MyOrdersModel data) => json.encode(data.toJson());

// class MyOrdersModel {
//   List<Order> orders;

//   MyOrdersModel({required this.orders});

//   factory MyOrdersModel.fromJson(Map<String, dynamic> json) => MyOrdersModel(
//     orders: List<Order>.from(json["orders"].map((x) => Order.fromJson(x))),
//   );

//   Map<String, dynamic> toJson() => {
//     "orders": List<dynamic>.from(orders.map((x) => x.toJson())),
//   };
// }

// class Order {
//   int id;
//   String status;
//   String total;
//   String paymentMethod;
//   String paymentStatus;
//   String phone;
//   String address;
//   String createdAt;
//   List<Item> items;

//   Order({
//     required this.id,
//     required this.status,
//     required this.total,
//     required this.paymentMethod,
//     required this.paymentStatus,
//     required this.phone,
//     required this.address,
//     required this.createdAt,
//     required this.items,
//   });

//   factory Order.fromJson(Map<String, dynamic> json) => Order(
//     id: json["id"] ?? 0,
//     status: json["status"]?.toString() ?? 'pending',
//     total: json["total"]?.toString() ?? '0.00',
//     paymentMethod: json["payment_method"]?.toString() ?? '',
//     paymentStatus: json["payment_status"]?.toString() ?? '',
//     phone: json["phone"]?.toString() ?? '',
//     address: json["address"]?.toString() ?? '',
//     createdAt: json["created_at"]?.toString() ?? '',
//     items: json["items"] != null
//         ? List<Item>.from(json["items"].map((x) => Item.fromJson(x)))
//         : [],
//   );

//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "status": status,
//     "total": total,
//     "payment_method": paymentMethod,
//     "payment_status": paymentStatus,
//     "phone": phone,
//     "address": address,
//     "created_at": createdAt,
//     "items": List<dynamic>.from(items.map((x) => x.toJson())),
//   };
// }

// class Item {
//   String name;
//   int qty;
//   String price;
//   String finalPrice;
//   dynamic discount;
//   String image;

//   Item({
//     required this.name,
//     required this.qty,
//     required this.price,
//     required this.finalPrice,
//     required this.discount,
//     required this.image,
//   });

//   factory Item.fromJson(Map<String, dynamic> json) => Item(
//     name: json["name"]?.toString() ?? '',
//     qty: json["qty"] ?? 0,
//     price: json["price"]?.toString() ?? '0.00',
//     finalPrice: json["final_price"]?.toString() ?? '0.00',
//     discount: json["discount"],
//     image: json["image"]?.toString() ?? '',
//   );

//   get productId => null;

//   Map<String, dynamic> toJson() => {
//     "name": name,
//     "qty": qty,
//     "price": price,
//     "final_price": finalPrice,
//     "discount": discount,
//     "image": image,
//   };
// }

// To parse this JSON data, do
//
//     final myOrdersModel = myOrdersModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

// my_orders_model.dart
import 'dart:convert';

MyOrdersModel myOrdersModelFromJson(String str) =>
    MyOrdersModel.fromJson(json.decode(str));

String myOrdersModelToJson(MyOrdersModel data) => json.encode(data.toJson());

class MyOrdersModel {
  List<Order> orders;

  MyOrdersModel({required this.orders});

  factory MyOrdersModel.fromJson(Map<String, dynamic> json) => MyOrdersModel(
        orders: List<Order>.from(json["orders"].map((x) => Order.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "orders": List<dynamic>.from(orders.map((x) => x.toJson())),
      };
}

class Order {
  int id;
  String status;
  String total;
  String promotionDiscount;
  String? couponCode;
  String? couponType;
  String couponValue;
  String couponDiscount;
  String paymentMethod;
  String paymentStatus;
  String phone;
  String address;
  String createdAt;
  List<Item> items;

  Order({
    required this.id,
    required this.status,
    required this.total,
    required this.promotionDiscount,
    this.couponCode,
    this.couponType,
    required this.couponValue,
    required this.couponDiscount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.phone,
    required this.address,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        status: json["status"] ?? "pending",
        total: json["total"] ?? "0.00",
        promotionDiscount: json["promotion_discount"] ?? "0.00",
        couponCode: json["coupon_code"],         // nullable ✓
        couponType: json["coupon_type"],         // nullable ✓
        couponValue: json["coupon_value"] ?? "0.00",
        couponDiscount: json["coupon_discount"] ?? "0.00",
        paymentMethod: json["payment_method"] ?? "",
        paymentStatus: json["payment_status"] ?? "",
        phone: json["phone"] ?? "",
        address: json["address"] ?? "",          // plain String ✓
        createdAt: json["created_at"] ?? "",
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "total": total,
        "promotion_discount": promotionDiscount,
        "coupon_code": couponCode,
        "coupon_type": couponType,
        "coupon_value": couponValue,
        "coupon_discount": couponDiscount,
        "payment_method": paymentMethod,
        "payment_status": paymentStatus,
        "phone": phone,
        "address": address,
        "created_at": createdAt,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class Item {
  int? productId;
  String name;
  int qty;
  String price;
  String subtotal;
  String image;
  String? discount;

  Item({
    this.productId,
    required this.name,
    required this.qty,
    required this.price,
    required this.subtotal,
    required this.image,
    this.discount,
  });

  /// Final price after item-level discount (falls back to price if absent)
  String get finalPrice {
    final base = double.tryParse(price) ?? 0.0;
    final pct = double.tryParse(discount ?? '') ?? 0.0;
    if (pct <= 0) return price;
    return (base * (1 - pct / 100)).toStringAsFixed(2);
  }

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        productId: json["product_id"],
        name: json["name"] ?? "",
        qty: json["qty"] ?? 1,
        price: json["price"] ?? "0.00",
        subtotal: json["subtotal"] ?? "0.00",
        image: json["image"] ?? "",
        discount: json["discount"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "name": name,
        "qty": qty,
        "price": price,
        "subtotal": subtotal,
        "image": image,
        "discount": discount,
      };
}