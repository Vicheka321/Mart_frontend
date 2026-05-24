// To parse this JSON data, do
//
//     final products = productsFromJson(jsonString);

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

List<Products> productsFromJson(String str) =>
    List<Products>.from(json.decode(str).map((x) => Products.fromJson(x)));

String productsToJson(List<Products> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Products {
  int id;
  int categoriesId;
  int brandId;
  String productCode;
  String name;
  String description;
  Unit unit;
  String costPrice;
  String salePrice;
  int quantity;
  bool status;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic finalPrice;
  String discount;
  List<String> images;

  Products({
    required this.id,
    required this.categoriesId,
    required this.brandId,
    required this.productCode,
    required this.name,
    required this.description,
    required this.unit,
    required this.costPrice,
    required this.salePrice,
    required this.quantity,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.finalPrice,
    required this.discount,
    required this.images,
  });

  factory Products.fromJson(Map<String, dynamic> json) => Products(
    id: json["id"],
    categoriesId: json["categories_id"],
    brandId: json["brand_id"],
    productCode: json["product_code"] ?? '',
    name: json["name"] ?? '',
    description: json["description"] ?? '',
    unit: unitValues.map[json["unit"]] ?? Unit.BOTTLE,
    costPrice: json["cost_price"] ?? '',
    salePrice: json["sale_price"] ?? '',
    quantity: json["quantity"] ?? 0,
    status: json["status"] ?? '',
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    finalPrice: json["final_price"] ?? '',
    discount: json["discount"],
    images: json["images"] != null
        ? List<String>.from(json["images"].map((x) => x.toString()))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "categories_id": categoriesId,
    "brand_id": brandId,
    "product_code": productCode,
    "name": name,
    "description": description,
    "unit": unitValues.reverse[unit],
    "cost_price": costPrice,
    "sale_price": salePrice,
    "quantity": quantity,
    "status": status,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "final_price": finalPrice,
    "discount": discount,
    "images": List<dynamic>.from(images.map((x) => x)),
  };
}

enum Unit { BOTTLE }

final unitValues = EnumValues({"bottle": Unit.BOTTLE});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

// ================= one product =================

GetProductModel getProductModelFromJson(String str) =>
    GetProductModel.fromJson(json.decode(str));

String getProductModelToJson(GetProductModel data) =>
    json.encode(data.toJson());

class GetProductModel {
  int id;
  String name;
  String description;
  String salePrice;
  String finalPrice;
  String? discount;
  int quantity;
  bool status;
  String categoryName;
  String brandName;
  List<String> images;

  GetProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.salePrice,
    required this.finalPrice,
    this.discount,
    required this.quantity,
    required this.status,
    required this.categoryName,
    required this.brandName,
    required this.images,
  });

  factory GetProductModel.fromJson(Map<String, dynamic> json) =>
      GetProductModel(
        id: json["id"],
        name: json["name"] ?? '',
        description: json["description"] ?? '',
        salePrice: json["sale_price"] ?? '',
        finalPrice: json["final_price"] ?? '',
        discount: json["discount"],
        quantity: json["quantity"] ?? 0,
        status: json["status"] ?? '',
        categoryName: json["category_name"] ?? '',
        brandName: json["brand_name"] ?? '',
        images: json["images"] != null
            ? List<String>.from(json["images"].map((x) => x.toString()))
            : [],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "sale_price": salePrice,
    "final_price": finalPrice,
    "discount": discount,
    "quantity": quantity,
    "status": status,
    "category_name": categoryName,
    "brand_name": brandName,
    "images": List<dynamic>.from(images.map((x) => x)),
  };
}

// ================== best sellers =================

List<BestSellerModel> bestSellerModelFromJson(String str) =>
    List<BestSellerModel>.from(
      json.decode(str).map((x) => BestSellerModel.fromJson(x)),
    );

String bestSellerModelToJson(List<BestSellerModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BestSellerModel {
  int id;
  String name;
  String salePrice;
  String finalPrice;
  dynamic discount;
  int sold;
  List<String> images;

  BestSellerModel({
    required this.id,
    required this.name,
    required this.salePrice,
    required this.finalPrice,
    required this.discount,
    required this.sold,
    required this.images,
  });

  factory BestSellerModel.fromJson(Map<String, dynamic> json) =>
      BestSellerModel(
        id: json["id"],
        name: json["name"] ?? '',
        salePrice: json["sale_price"] ?? '',
        finalPrice: json["final_price"] ?? '',
        discount: json["discount"],
        sold: json["sold"] ?? 0,
        images: json["images"] != null
            ? List<String>.from(json["images"].map((x) => x.toString()))
            : [],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "sale_price": salePrice,
    "final_price": finalPrice,
    "discount": discount,
    "sold": sold,
    "images": List<dynamic>.from(images.map((x) => x)),
  };
}

// ==============new arrivals=================

List<NewArrivalsModel> newArrivalsModelFromJson(String str) =>
    List<NewArrivalsModel>.from(
      json.decode(str).map((x) => NewArrivalsModel.fromJson(x)),
    );

String newArrivalsModelToJson(List<NewArrivalsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NewArrivalsModel {
  int id;
  String name;
  String salePrice;
  String finalPrice;
  String? discount;
  List<String> images;

  NewArrivalsModel({
    required this.id,
    required this.name,
    required this.salePrice,
    required this.finalPrice,
    this.discount,
    required this.images,
  });

  factory NewArrivalsModel.fromJson(Map<String, dynamic> json) =>
      NewArrivalsModel(
        id: json["id"],
        name: json["name"],
        salePrice: json["sale_price"],
        finalPrice: json["final_price"],
        discount: json["discount"],
        images: List<String>.from(json["images"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "sale_price": salePrice,
    "final_price": finalPrice,
    "discount": discount,
    "images": List<dynamic>.from(images.map((x) => x)),
  };
}

// ==================recommended=================

List<RecommendedModel> recommendedModelFromJson(String str) =>
    List<RecommendedModel>.from(
      json.decode(str).map((x) => RecommendedModel.fromJson(x)),
    );

String recommendedModelToJson(List<RecommendedModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RecommendedModel {
  int id;
  String name;
  String salePrice;
  String finalPrice;
  String? discount;
  int sold;
  List<String> images;

  RecommendedModel({
    required this.id,
    required this.name,
    required this.salePrice,
    required this.finalPrice,
    this.discount,
    required this.sold,
    required this.images,
  });

  factory RecommendedModel.fromJson(Map<String, dynamic> json) =>
      RecommendedModel(
        id: json["id"],
        name: json["name"],
        salePrice: json["sale_price"],
        finalPrice: json["final_price"],
        discount: json["discount"],
        sold: json["sold"],
        images: List<String>.from(json["images"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "sale_price": salePrice,
    "final_price": finalPrice,
    "discount": discount,
    "sold": sold,
    "images": List<dynamic>.from(images.map((x) => x)),
  };
}

// =========================all best sellers=========================

List<AllbestsellersModel> allbestsellersModelFromJson(String str) =>
    List<AllbestsellersModel>.from(
      json.decode(str).map((x) => AllbestsellersModel.fromJson(x)),
    );

String allbestsellersModelToJson(List<AllbestsellersModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AllbestsellersModel {
  int id;
  String name;
  String description;
  String unit;
  int quantity;
  String salePrice;
  String finalPrice;
  String? discount;
  String categoryName;
  String brandName;
  int sold;
  List<String> images;

  AllbestsellersModel({
    required this.id,
    required this.name,
    required this.description,
    required this.unit,
    required this.quantity,
    required this.salePrice,
    required this.finalPrice,
    this.discount,
    required this.categoryName,
    required this.brandName,
    required this.sold,
    required this.images,
  });

  factory AllbestsellersModel.fromJson(Map<String, dynamic> json) =>
      AllbestsellersModel(
        id: json["id"] ?? 0,
        name: json["name"]?.toString() ?? '',
        description: json["description"]?.toString() ?? '',
        unit: json["unit"]?.toString() ?? '',
        quantity: json["quantity"] ?? 0,
        salePrice: json["sale_price"]?.toString() ?? '0.00',
        finalPrice: json["final_price"]?.toString() ?? '0.00',
        discount: json["discount"],
        categoryName: json["category_name"]?.toString() ?? '',
        brandName: json["brand_name"]?.toString() ?? '',
        sold: json["sold"] ?? 0,
        images: json["images"] != null
            ? List<String>.from(
                (json["images"] as List).map((x) => x.toString()),
              )
            : [],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "unit": unit,
    "quantity": quantity,
    "sale_price": salePrice,
    "final_price": finalPrice,
    "discount": discount,
    "category_name": categoryName,
    "brand_name": brandName,
    "sold": sold,
    "images": List<dynamic>.from(images.map((x) => x)),
  };
}

// =========================all new arrivals=========================

List<AllnewarrivalsModel> allnewarrivalsModelFromJson(String str) =>
    List<AllnewarrivalsModel>.from(
      json.decode(str).map((x) => AllnewarrivalsModel.fromJson(x)),
    );

String allnewarrivalsModelToJson(List<AllnewarrivalsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AllnewarrivalsModel {
  int id;
  String name;
  String description;
  String unit;
  int quantity;
  String salePrice;
  String finalPrice;
  String? discount;
  String categoryName;
  String brandName;
  int sold;
  List<String> images;

  AllnewarrivalsModel({
    required this.id,
    required this.name,
    required this.description,
    required this.unit,
    required this.quantity,
    required this.salePrice,
    required this.finalPrice,
    this.discount,
    required this.categoryName,
    required this.brandName,
    required this.sold,
    required this.images,
  });

  factory AllnewarrivalsModel.fromJson(Map<String, dynamic> json) =>
      AllnewarrivalsModel(
        id: json["id"] ?? 0,
        name: json["name"]?.toString() ?? '',
        description: json["description"]?.toString() ?? '',
        unit: json["unit"]?.toString() ?? '',
        quantity: json["quantity"] ?? 0,
        salePrice: json["sale_price"]?.toString() ?? '0.00',
        finalPrice: json["final_price"]?.toString() ?? '0.00',
        discount: json["discount"],
        categoryName: json["category_name"]?.toString() ?? '',
        brandName: json["brand_name"]?.toString() ?? '',
        sold: json["sold"] ?? 0,
        images: json["images"] != null
            ? List<String>.from(
                (json["images"] as List).map((x) => x.toString()),
              )
            : [],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "unit": unit,
    "quantity": quantity,
    "sale_price": salePrice,
    "final_price": finalPrice,
    "discount": discount,
    "category_name": categoryName,
    "brand_name": brandName,
    "sold": sold,
    "images": List<dynamic>.from(images.map((x) => x)),
  };
}

List<AllrecommendedModel> allrecommendedModelFromJson(String str) =>
    List<AllrecommendedModel>.from(
      json.decode(str).map((x) => AllrecommendedModel.fromJson(x)),
    );

String allrecommendedModelToJson(List<AllrecommendedModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AllrecommendedModel {
  int id;
  String name;
  String description;
  String unit;
  int quantity;
  String salePrice;
  String finalPrice;
  String? discount;
  String categoryName;
  String brandName;
  int sold;
  List<String> images;

  AllrecommendedModel({
    required this.id,
    required this.name,
    required this.description,
    required this.unit,
    required this.quantity,
    required this.salePrice,
    required this.finalPrice,
    this.discount,
    required this.categoryName,
    required this.brandName,
    required this.sold,
    required this.images,
  });

  factory AllrecommendedModel.fromJson(Map<String, dynamic> json) =>
      AllrecommendedModel(
        id: json["id"] ?? 0,
        name: json["name"]?.toString() ?? '',
        description: json["description"]?.toString() ?? '',
        unit: json["unit"]?.toString() ?? '',
        quantity: json["quantity"] ?? 0,
        salePrice: json["sale_price"]?.toString() ?? '0.00',
        finalPrice: json["final_price"]?.toString() ?? '0.00',
        discount: json["discount"],
        categoryName: json["category_name"]?.toString() ?? '',
        brandName: json["brand_name"]?.toString() ?? '',
        sold: json["sold"] ?? 0,
        images: json["images"] != null
            ? List<String>.from(
                (json["images"] as List).map((x) => x.toString()),
              )
            : [],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "unit": unit,
    "quantity": quantity,
    "sale_price": salePrice,
    "final_price": finalPrice,
    "discount": discount,
    "category_name": categoryName,
    "brand_name": brandName,
    "sold": sold,
    "images": List<dynamic>.from(images.map((x) => x)),
  };
}

// ========================my cart =================

MyCartModel myCartModelFromJson(String str) =>
    MyCartModel.fromJson(json.decode(str));

String myCartModelToJson(MyCartModel data) => json.encode(data.toJson());

class MyCartModel {
  int cartId;
  double totalPrice;
  List<Item> items;

  MyCartModel({
    required this.cartId,
    required this.totalPrice,
    required this.items,
  });

  factory MyCartModel.fromJson(Map<String, dynamic> json) => MyCartModel(
    cartId: json["cart_id"],
    totalPrice: json["total_price"].toDouble(),
    items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "cart_id": cartId,
    "total_price": totalPrice,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class Item {
  int productId;
  String name;
  int qty;
  String price;
  double totalPrice;
  List<String> images;

  Item({
    required this.productId,
    required this.name,
    required this.qty,
    required this.price,
    required this.totalPrice,
    required this.images,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    productId: json["product_id"],
    name: json["name"],
    qty: json["qty"],
    price: json["price"].toString(),
    totalPrice: json["total_price"].toDouble(),
    images: List<String>.from(json["images"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "name": name,
    "qty": qty,
    "price": price,
    "total_price": totalPrice,
    "images": List<dynamic>.from(images.map((x) => x)),
  };
}

// =========================all recommended=========================
