// To parse this JSON data, do
//
//     final myOrdersModel = myOrdersModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

MyOrdersModel myOrdersModelFromJson(String str) => MyOrdersModel.fromJson(json.decode(str));

String myOrdersModelToJson(MyOrdersModel data) => json.encode(data.toJson());

class MyOrdersModel {
    List<Order> orders;

    MyOrdersModel({
        required this.orders,
    });

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
        required this.paymentMethod,
        required this.paymentStatus,
        required this.phone,
        required this.address,
        required this.createdAt,
        required this.items,
    });

    factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        status: json["status"],
        total: json["total"],
        paymentMethod: json["payment_method"],
        paymentStatus: json["payment_status"],
        phone: json["phone"],
        address: json["address"],
        createdAt: json["created_at"],
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
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
    String name;
    int qty;
    String price;
    String finalPrice;
    dynamic discount;
    String image;

    Item({
        required this.name,
        required this.qty,
        required this.price,
        required this.finalPrice,
        required this.discount,
        required this.image,
    });

    factory Item.fromJson(Map<String, dynamic> json) => Item(
        name: json["name"],
        qty: json["qty"],
        price: json["price"],
        finalPrice: json["final_price"],
        discount: json["discount"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "qty": qty,
        "price": price,
        "final_price": finalPrice,
        "discount": discount,
        "image": image,
    };
}
