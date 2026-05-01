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

BrandWithProducts brandWithProductsFromJson(String str) =>
    BrandWithProducts.fromJson(json.decode(str));

String brandWithProductsToJson(BrandWithProducts data) =>
    json.encode(data.toJson());

class BrandWithProducts {
  int id;
  String name;
  String country;
  String image;
  DateTime createdAt;
  DateTime updatedAt;
  List<Product> products;

  BrandWithProducts({
    required this.id,
    required this.name,
    required this.country,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.products,
  });

  factory BrandWithProducts.fromJson(Map<String, dynamic> json) =>
      BrandWithProducts(
        id: json["id"],
        name: json["name"],
        country: json["country"],
        image: json["image"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        products: List<Product>.from(
          json["products"].map((x) => Product.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "country": country,
    "image": image,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "products": List<dynamic>.from(products.map((x) => x.toJson())),
  };
}

class Product {
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

  Product({
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
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    categoriesId: json["categories_id"],
    brandId: json["brand_id"],
    productCode: json["product_code"],
    name: json["name"],
    description: json["description"],
    unit: unitValues.map[json["unit"]]!,
    costPrice: json["cost_price"],
    salePrice: json["sale_price"],
    quantity: json["quantity"],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
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
