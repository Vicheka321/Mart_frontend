import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mart_frontend/models/products_model.dart';
import '../models/banners_model.dart';
import '../models/brands_model.dart';
import '../models/categories_model.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';

import '../models/my_orders_model.dart';
import '../models/profile_model.dart';

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  // ==============Products=================
  Future<List<BannersModel>> fetchBanners() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/banners'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('banners_cache', response.body);
        return bannersModelFromJson(response.body);
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<CategoriesModel>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('categories_cache', response.body);
        return categoriesModelFromJson(response.body);
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<BestSellerModel>> fetchBestSellers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/best-sellers'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('best_sellers_cache', response.body);
        return bestSellerModelFromJson(response.body);
      } else {
        throw Exception('Failed to load best sellers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<NewArrivalsModel>> fetchNewArrivals() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/new-arrivals'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('new_arrivals_cache', response.body);
        return newArrivalsModelFromJson(response.body);
      } else {
        throw Exception('Failed to load new arrivals: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<RecommendedModel>> fetchRecommended() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recommended'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('recommended_cache', response.body);
        return recommendedModelFromJson(response.body);
      } else {
        throw Exception('Failed to load recommended: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<BrandsModel>> fetchBrands() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/brands'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('brands_cache', response.body);
        return brandsModelFromJson(response.body);
      } else {
        throw Exception('Failed to load brands: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<GetProductsByBrandModel> fetchPeoductsByBrand(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/brand/$id'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('brands_with_products_cache_$id', response.body);

        return getProductsByBrandModelFromJson(response.body);
      } else {
        throw Exception(
          'Failed to load brands with products: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<GetProductsByCategoryModel> fetchCategoryWithProducts(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/category/$id'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(
          'categories_with_products_cache_$id',
          response.body,
        );

        return getProductsByCategoryModelFromJson(response.body);
      } else {
        throw Exception(
          'Failed to load categories with products: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<GetProductModel> fetchProduct(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product/$id'),
        headers: {"Accept": "application/json"},
      );
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('product_cache_$id', response.body);
        return getProductModelFromJson(response.body);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<AllbestsellersModel>> fetchAllBestSellers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/all-best-sellers'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('all_best_sellers_cache', response.body);
        return allbestsellersModelFromJson(response.body);
      } else {
        throw Exception('Failed to load best sellers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<AllnewarrivalsModel>> fetchAllNewArrivals() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/all-new-arrivals'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('all_new_arrivals_cache', response.body);
        return allnewarrivalsModelFromJson(response.body);
      } else {
        throw Exception('Failed to load new arrivals: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ============== Auth =================
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      return false;
    }

    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  Future<Map<String, dynamic>> sendEmailOtp({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({"email": email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data["message"] ?? "Failed to send OTP");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/verify-otp"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"email": email, "otp": otp}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // save token after verify success
        if (data["token"] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", data["token"]);
        }
        print(data["token"]);

        return data;
      }

      throw Exception(data["message"] ?? "Invalid OTP");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<AllrecommendedModel>> fetchAllRecommended() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/all-recommended'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('all_recommended_cache', response.body);
        return allrecommendedModelFromJson(response.body);
      } else {
        throw Exception('Failed to load recommended: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  // ==================update profile=================

  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    File? avatar,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception("Unauthorized");
      }

      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/update-profile"),
      );

      request.headers["Authorization"] = "Bearer $token";
      request.headers["Accept"] = "application/json";

      request.fields["first_name"] = firstName;
      request.fields["last_name"] = lastName;

      if (avatar != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "avatar",
            avatar.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      }

      throw Exception(data["message"] ?? "Profile update failed");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // =================== add to cart=================
  Future<void> addToCart({
    required int productId,
    required int quantity,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null || token.isEmpty) {
        throw Exception("Unauthorized: No token found");
      }

      final response = await http.post(
        Uri.parse("$baseUrl/add-to-cart"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"product_id": productId, "quantity": quantity}),
      );

      print(response.body);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      throw Exception(data["message"] ?? "Failed to add to cart");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future updateCart({required int productId, required int quantity}) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    final response = await http.post(
      Uri.parse("$baseUrl/update-cart"),

      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },

      body: jsonEncode({"product_id": productId, "quantity": quantity}),
    );

    if (response.statusCode != 200) {
      throw Exception("Update failed");
    }
  }

  Future<MyCartModel> getCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Unauthorized");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/cart"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return myCartModelFromJson(response.body);
      }

      throw Exception("Failed load cart");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<int> getCartQuantity({required int productId}) async {
    try {
      final cart = await getCart();

      try {
        final item = cart.items.firstWhere((e) => e.productId == productId);

        return item.qty;
      } catch (_) {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<bool> removeCart(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      final response = await http.delete(
        Uri.parse("$baseUrl/remove-cart/$productId"),

        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      print(data); // debug

      if (response.statusCode == 200 && data["success"] == true) {
        return true;
      }

      return false;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<MyOrdersModel> fetchMyOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      throw Exception("No token found. User not authenticated.");
    }

    final response = await http
        .get(
          Uri.parse("$baseUrl/orders"),
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      try {
        return myOrdersModelFromJson(response.body);
      } catch (e) {
        throw Exception("Invalid response format: $e");
      }
    } else {
      throw Exception(
        "Failed to load orders (Status: ${response.statusCode}): ${response.body}",
      );
    }
  }

  // ==========================profile================
  Future<MyProfileModel> fetchMyProfile() async {
    // ✅ Get token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse('$baseUrl/my-profile'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return myProfileModelFromJson(response.body);
    } else {
      throw Exception('Failed to load profile: ${response.body}');
    }
  }

  // ===========================order================================

  Future<Map<String, dynamic>> storeAddress({
    required String phone,
    required String address,
    required double lat,
    required double lng,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.post(
      Uri.parse("$baseUrl/address"),

      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},

      body: {
        "phone": phone,
        "address": address,
        "lat": lat.toString(),
        "lng": lng.toString(),
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Failed to save address");
    }
  }

  Future<Map<String, dynamic>> placeOrder({
    required int addressId,
    required String paymentMethod,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.post(
      Uri.parse("$baseUrl/order"),

      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},

      body: {
        "address_id": addressId.toString(),
        "payment_method": paymentMethod,
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Failed to place order");
    }
  }

  Future<Map<String, dynamic>> generateQR(int orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.post(
      Uri.parse("$baseUrl/payment/khqr"),

      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},

      body: {"order_id": orderId.toString()},
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> checkPayment(String md5) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.post(
      Uri.parse("$baseUrl/check"),

      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},

      body: {"md5": md5},
    );

    return jsonDecode(response.body);
  }
}
