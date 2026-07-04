// To parse this JSON data, do
//
//     final myFavoriteModel = myFavoriteModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

List<MyFavoriteModel> myFavoriteModelFromJson(String str) => List<MyFavoriteModel>.from(json.decode(str).map((x) => MyFavoriteModel.fromJson(x)));

String myFavoriteModelToJson(List<MyFavoriteModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MyFavoriteModel {
    int id;
    int userId;
    int productId;
    DateTime createdAt;
    DateTime updatedAt;
    Product product;

    MyFavoriteModel({
        required this.id,
        required this.userId,
        required this.productId,
        required this.createdAt,
        required this.updatedAt,
        required this.product,
    });

    factory MyFavoriteModel.fromJson(Map<String, dynamic> json) => MyFavoriteModel(
        id: json["id"],
        userId: json["user_id"],
        productId: json["product_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        product: Product.fromJson(json["product"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "product_id": productId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "product": product.toJson(),
    };
}

class Product {
    int id;
    int categoriesId;
    int brandId;
    String productCode;
    String name;
    String description;
    String unit;
    String costPrice;
    String salePrice;
    int quantity;
    bool status;
    DateTime createdAt;
    DateTime updatedAt;
    String discountValue;
    String discountType;
    int finalPrice;
    FirstImage firstImage;

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
        required this.discountValue,
        required this.discountType,
        required this.finalPrice,
        required this.firstImage,
    });

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        categoriesId: json["categories_id"],
        brandId: json["brand_id"],
        productCode: json["product_code"],
        name: json["name"],
        description: json["description"],
        unit: json["unit"],
        costPrice: json["cost_price"],
        salePrice: json["sale_price"],
        quantity: json["quantity"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        discountValue: json["discount_value"],
        discountType: json["discount_type"],
        finalPrice: json["final_price"],
        firstImage: FirstImage.fromJson(json["first_image"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "categories_id": categoriesId,
        "brand_id": brandId,
        "product_code": productCode,
        "name": name,
        "description": description,
        "unit": unit,
        "cost_price": costPrice,
        "sale_price": salePrice,
        "quantity": quantity,
        "status": status,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "discount_value": discountValue,
        "discount_type": discountType,
        "final_price": finalPrice,
        "first_image": firstImage.toJson(),
    };
}

class FirstImage {
    int id;
    int productId;
    String imageUrl;
    DateTime createdAt;
    DateTime updatedAt;

    FirstImage({
        required this.id,
        required this.productId,
        required this.imageUrl,
        required this.createdAt,
        required this.updatedAt,
    });

    factory FirstImage.fromJson(Map<String, dynamic> json) => FirstImage(
        id: json["id"],
        productId: json["product_id"],
        imageUrl: json["image_url"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "product_id": productId,
        "image_url": imageUrl,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
    };
}
