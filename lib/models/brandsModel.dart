// To parse this JSON data, do
//
//     final brands = brandsFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

// ==============fetch all brands =================

List<BrandsModel> brandsModelFromJson(String str) => List<BrandsModel>.from(
  json.decode(str).map((x) => BrandsModel.fromJson(x)),
);

String brandsModelToJson(List<BrandsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BrandsModel {
  int id;
  String name;
  String country;
  String image;
  DateTime createdAt;
  DateTime updatedAt;

  BrandsModel({
    required this.id,
    required this.name,
    required this.country,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BrandsModel.fromJson(Map<String, dynamic> json) => BrandsModel(
    id: json["id"],
    name: json["name"],
    country: json["country"],
    image: json["image"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "country": country,
    "image": image,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

// ===============get products by brand =================

GetProductsByBrandModel getProductsByBrandModelFromJson(String str) =>
    GetProductsByBrandModel.fromJson(json.decode(str));

String getProductsByBrandModelToJson(GetProductsByBrandModel data) =>
    json.encode(data.toJson());

class GetProductsByBrandModel {
  int id;
  String name;
  String country;
  List<Product> products;

  GetProductsByBrandModel({
    required this.id,
    required this.name,
    required this.country,
    required this.products,
  });

  factory GetProductsByBrandModel.fromJson(Map<String, dynamic> json) =>
      GetProductsByBrandModel(
        id: json["id"],
        name: json["name"],
        country: json["country"],
        products: List<Product>.from(
          json["products"].map((x) => Product.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "country": country,

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
  String finalPrice;
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
    finalPrice: json["final_price"],
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
