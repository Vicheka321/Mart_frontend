import 'package:meta/meta.dart';
import 'dart:convert';

List<CategoriesWithProductsModel> categoriesWithProductsModelFromJson(
  String str,
) => List<CategoriesWithProductsModel>.from(
  json.decode(str).map((x) => CategoriesWithProductsModel.fromJson(x)),
);

String categoriesWithProductsModelToJson(
  List<CategoriesWithProductsModel> data,
) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CategoriesWithProductsModel {
  int id;
  String name;
  String image;
  DateTime createdAt;
  DateTime updatedAt;
  List<Product> products;

  CategoriesWithProductsModel({
    required this.id,
    required this.name,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.products,
  });

  factory CategoriesWithProductsModel.fromJson(Map<String, dynamic> json) =>
      CategoriesWithProductsModel(
        id: json["id"],
        name: json["name"],
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
  String? productCode;
  String name;
  String description;
  Unit? unit;
  String costPrice;
  String salePrice;
  int quantity;
  bool status;
  DateTime createdAt;
  DateTime updatedAt;
  FirstImage firstImage;

  Product({
    required this.id,
    required this.categoriesId,
    required this.brandId,
    this.productCode,
    required this.name,
    required this.description,
    this.unit,
    required this.costPrice,
    required this.salePrice,
    required this.quantity,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.firstImage,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    categoriesId: json["categories_id"],
    brandId: json["brand_id"],
    productCode: json["product_code"],
    name: json["name"],
    description: json["description"],
    unit: json["unit"] == null ? null : unitValues.map[json["unit"]],
    costPrice: json["cost_price"],
    salePrice: json["sale_price"],
    quantity: json["quantity"],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    firstImage: FirstImage.fromJson(json["first_image"]),
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

enum Unit { BAG, BOTTLE, DOZEN, KG, LITER, PACK, PIECE }

final unitValues = EnumValues({
  "bag": Unit.BAG,
  "bottle": Unit.BOTTLE,
  "dozen": Unit.DOZEN,
  "kg": Unit.KG,
  "liter": Unit.LITER,
  "pack": Unit.PACK,
  "piece": Unit.PIECE,
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

// To parse this JSON data, do
//
//     final categoriesWithProductsModel = categoriesWithProductsModelFromJson(jsonString);

// import 'package:meta/meta.dart';
// import 'dart:convert';

// List<CategoriesWithProductsModel> categoriesWithProductsModelFromJson(
//   String str,
// ) => List<CategoriesWithProductsModel>.from(
//   json.decode(str).map((x) => CategoriesWithProductsModel.fromJson(x)),
// );

// String categoriesWithProductsModelToJson(
//   List<CategoriesWithProductsModel> data,
// ) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class CategoriesWithProductsModel {
//   int id;
//   String name;
//   String image;
//   DateTime createdAt;
//   DateTime updatedAt;
//   List<Product> products;

//   CategoriesWithProductsModel({
//     required this.id,
//     required this.name,
//     required this.image,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.products,
//   });

//   factory CategoriesWithProductsModel.fromJson(Map<String, dynamic> json) =>
//       CategoriesWithProductsModel(
//         id: json["id"],
//         name: json["name"],
//         image: json["image"],
//         createdAt: DateTime.parse(json["created_at"]),
//         updatedAt: DateTime.parse(json["updated_at"]),
//         products: List<Product>.from(
//           json["products"].map((x) => Product.fromJson(x)),
//         ),
//       );

//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "name": name,
//     "image": image,
//     "created_at": createdAt.toIso8601String(),
//     "updated_at": updatedAt.toIso8601String(),
//     "products": List<dynamic>.from(products.map((x) => x.toJson())),
//   };
// }

// class Product {
//   int id;
//   String name;
//   String description;
//   String? unit;
//   int quantity;
//   String salePrice;
//   String finalPrice;
//   String? discount;
//   String categoryName;
//   String brandName;
//   List<String> images;

//   Product({
//     required this.id,
//     required this.name,
//     required this.description,
//     this.unit,
//     required this.quantity,
//     required this.salePrice,
//     required this.finalPrice,
//     this.discount,
//     required this.categoryName,
//     required this.brandName,
//     required this.images,
//   });

//   factory Product.fromJson(Map<String, dynamic> json) => Product(
//     id: json["id"],
//     name: json["name"],
//     description: json["description"],
//     unit: json["unit"]!,
//     quantity: json["quantity"],
//     salePrice: json["sale_price"],
//     finalPrice: json["final_price"],
//     discount: json["discount"],
//     categoryName: json["category_name"] ?? '',
//     brandName: json["brand_name"] ?? '',
//     images: List<String>.from(json["images"] ?? []),
//   );

//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "name": name,
//     "description": description,
//     "unit": unit,
//     "quantity": quantity,
//     "sale_price": salePrice,
//     "final_price": finalPrice,
//     "discount": discount,
//     "category_name": categoryName,
//     "brand_name": brandName,
//     "images": List<dynamic>.from(images.map((x) => x)),
//   };
// }
