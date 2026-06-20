// import 'package:meta/meta.dart';
// import 'dart:convert';

// OrderDetailModel orderDetailModelFromJson(String str) =>
//     OrderDetailModel.fromJson(json.decode(str));

// String orderDetailModelToJson(OrderDetailModel data) =>
//     json.encode(data.toJson());

// class OrderDetailModel {
//   bool success;
//   Data data;

//   OrderDetailModel({required this.success, required this.data});

//   factory OrderDetailModel.fromJson(Map<String, dynamic> json) =>
//       OrderDetailModel(
//         success: json["success"],
//         data: Data.fromJson(json["data"]),
//       );

//   Map<String, dynamic> toJson() => {"success": success, "data": data.toJson()};
// }

// class Data {
//   int id;
//   String total;
//   String paymentMethod;
//   String paymentStatus;
//   String phone;
//   String address;
//   String createdAt;

//   List<Item> items;

//   Data({
//     required this.id,
//     required this.total,
//     required this.paymentMethod,
//     required this.paymentStatus,
//     required this.phone,
//     required this.address,
//     required this.createdAt,
//     required this.items,
//   });

//   factory Data.fromJson(Map<String, dynamic> json) => Data(
//     id: json["id"] ?? 0,
//     total: json["total"]?.toString() ?? "0.00",
//     paymentMethod: json["payment_method"] ?? "",
//     paymentStatus: json["payment_status"] ?? "",
//     phone: json["phone"] ?? "",
//     address: json["address"] ?? "",
//     createdAt: json["created_at"] ?? "",
//     items: json["items"] == null
//         ? []
//         : List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
//   );

//   Map<String, dynamic> toJson() => {
//     "id": id,
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
//   int productId;
//   String name;
//   int qty;
//   String price;
//   String image;

//   Item({
//     required this.productId,
//     required this.name,
//     required this.qty,
//     required this.price,
//     required this.image,
//   });

// factory Item.fromJson(Map<String, dynamic> json) => Item(
//   productId: json["product_id"] ?? 0,
//   name: json["name"] ?? "",
//   qty: json["qty"] ?? 0,
//   price: json["price"]?.toString() ?? "0",
//   image: json["image"] ?? "",
// );

//   Map<String, dynamic> toJson() => {
//     "product_id": productId,
//     "name": name,
//     "qty": qty,
//     "price": price,
//     "image": image,
//   };
// }

// To parse this JSON data, do
//
//     final orderDetailModel = orderDetailModelFromJson(jsonString);

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
  String status;
  String total;
  String promotionDiscount;
  String? couponCode; // nullable — absent on orders without coupons
  String? couponType; // nullable — absent on orders without coupons
  String couponValue;
  String couponDiscount;
  String paymentMethod;
  String paymentStatus;
  String phone;
  String address;
  String note;
  String createdAt;
  List<Item> items;

  Data({
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
    required this.note,
    required this.createdAt,
    required this.items,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    status: json["status"] ?? "pending",
    total: json["total"] ?? "0.00",
    promotionDiscount: json["promotion_discount"] ?? "0.00",
    couponCode: json["coupon_code"], // stays null if absent
    couponType: json["coupon_type"], // stays null if absent
    couponValue: json["coupon_value"] ?? "0.00",
    couponDiscount: json["coupon_discount"] ?? "0.00",
    paymentMethod: json["payment_method"] ?? "",
    paymentStatus: json["payment_status"] ?? "",
    phone: json["phone"] ?? "",
    address: json["address"] ?? "",
    note: json["note"] ?? "",
    createdAt: json["created_at"] ?? "",
    items: List<Item>.from(
      (json["items"] as List? ?? []).map((x) => Item.fromJson(x)),
    ),
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
    "note": note,
    "created_at": createdAt,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };

  bool get hasCoupon =>
      couponCode != null &&
      couponCode!.isNotEmpty &&
      double.tryParse(couponDiscount) != null &&
      (double.tryParse(couponDiscount) ?? 0) > 0;

  bool get hasPromotion => (double.tryParse(promotionDiscount) ?? 0) > 0;
}

class Item {
  int productId;
  String name;
  int qty;
  String price;
  String subtotal;
  String image;

  Item({
    required this.productId,
    required this.name,
    required this.qty,
    required this.price,
    required this.subtotal,
    required this.image,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    productId: json["product_id"] ?? 0,
    name: json["name"] ?? "",
    qty: json["qty"] ?? 1,
    price: json["price"] ?? "0.00",
    subtotal: json["subtotal"] ?? "0.00",
    image: json["image"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "name": name,
    "qty": qty,
    "price": price,
    "subtotal": subtotal,
    "image": image,
  };
}
