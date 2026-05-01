// To parse this JSON data, do
//
//     final categoriesModel = categoriesModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

List<CategoriesModel> categoriesModelFromJson(String str) =>
    List<CategoriesModel>.from(
      json.decode(str).map((x) => CategoriesModel.fromJson(x)),
    );

String categoriesModelToJson(List<CategoriesModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CategoriesModel {
  int id;
  String name;
  String image;
  DateTime createdAt;
  DateTime updatedAt;

  CategoriesModel({
    required this.id,
    required this.name,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoriesModel.fromJson(Map<String, dynamic> json) =>
      CategoriesModel(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

// ================= get products by category =================

GetProductsByCategoryModel getProductsByCategoryModelFromJson(String str) =>
    GetProductsByCategoryModel.fromJson(json.decode(str));

String getProductsByCategoryModelToJson(GetProductsByCategoryModel data) =>
    json.encode(data.toJson());

class GetProductsByCategoryModel {
  int id;
  String name;
  List<Product> products;

  GetProductsByCategoryModel({
    required this.id,
    required this.name,
    required this.products,
  });

  factory GetProductsByCategoryModel.fromJson(Map<String, dynamic> json) =>
      GetProductsByCategoryModel(
        id: json["id"],
        name: json["name"],
        products: List<Product>.from(
          json["products"].map((x) => Product.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "products": List<dynamic>.from(products.map((x) => x.toJson())),
  };
}

class Product {
  int id;
  String name;
  String description;
  String unit;
  int quantity;
  String salePrice;
  double finalPrice;
  String? discount;
  String categoryName;
  String brandName;
  List<String> images;

  Product({
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
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    unit: json["unit"],
    quantity: json["quantity"],
    salePrice: json["sale_price"],
    finalPrice: json["final_price"].toDouble(),
    discount: json["discount"],
    categoryName: json["category_name"],
    brandName: json["brand_name"],
    images: List<String>.from(json["images"].map((x) => x)),
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
    "images": List<dynamic>.from(images.map((x) => x)),
  };
}
