import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:mart_frontend/models/address_model.dart';
import 'package:mart_frontend/models/brands_with_products.dart';
import 'package:mart_frontend/models/categories_with_products_model.dart';
import 'package:mart_frontend/models/order_detail_model.dart';

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
  final String baseUrl = 'https://glutton-heat-trifle.ngrok-free.dev/api';
  // final String baseUrl = 'http://10.0.2.2:8000/api';

  // ==============Products=================

  Future<List<AllProducts>> fetchAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('all_products_cache', response.body);
        return allProductsFromJson(response.body);
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

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

  Future<List<CategoriesWithProductsModel>>
  fetchCategoriesWithProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('categories_with_products_cache', response.body);
        return categoriesWithProductsModelFromJson(response.body);
      } else {
        throw Exception(
          'Failed to load categories with products: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<BrandsWithProductsModel>> fetchBrandsWithProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/brands'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('brands_with_products_cache', response.body);
        return brandsWithProductsModelFromJson(response.body);
      } else {
        throw Exception(
          'Failed to load brands with products: ${response.statusCode}',
        );
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

  Future<GetProductsByBrandModel> fetchProductsByBrand(int id) async {
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

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String login,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'full_name': fullName,
        'login': login,
        'password': password,
        'password_confirmation': confirmPassword,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['message'] ?? 'Registration failed');
  }

  Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'login': login, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["token"] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);

        final fcmToken = await FirebaseMessaging.instance.getToken();

        if (fcmToken != null) {
          await saveUserToken(fcmToken);
        }
      }
      return data;
    }

    throw Exception(data['message'] ?? 'Login failed');
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String login,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/verify-otp"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"login": login, "otp": otp}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // save token after verify success
        if (data["token"] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", data["token"]);

          final fcmToken = await FirebaseMessaging.instance.getToken();

          if (fcmToken != null) {
            await saveUserToken(fcmToken);
          }
        }
        print(data["token"]);

        return data;
      }

      throw Exception(data["message"] ?? "Invalid OTP");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> forgotPassword({required String login}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'login': login}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to send OTP');
  }

  Future<Map<String, dynamic>> verifyResetOtp({
    required String login,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-reset-otp'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'login': login, 'otp': otp}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['message'] ?? 'OTP verification failed');
  }

  Future<Map<String, dynamic>> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'reset_token': resetToken,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data["token"] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);
      }
      return data;
    }

    throw Exception(data['message'] ?? 'Password reset failed');
  }

  Future<Map<String, dynamic>> resendOtp({required String login}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resend-otp'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'login': login}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to resend OTP');
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

  // =================== orders=================
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

    if (response.statusCode == 200) {
      throw Exception("Cart updated successfully");
    }
    throw Exception("Update failed");
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

  Future<OrderDetailModel> getOrderDetail(int orderId) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse('$baseUrl/orders/$orderId'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load order');
    }

    final json = jsonDecode(response.body);

    return OrderDetailModel.fromJson(json);
  }

  // ==========================profile================

  Future<MyProfileModel> fetchMyProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse('$baseUrl/my-profile'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      await prefs.setString('my_profile_cache', response.body);
      return myProfileModelFromJson(response.body);
    }

    throw Exception('Failed to load profile');
  }

  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    File? avatar,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/my-profile/update'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['full_name'] = fullName;
    request.fields['email'] = email;
    request.fields['phone'] = phone;

    if (avatar != null) {
      request.files.add(
        await http.MultipartFile.fromPath('avatar', avatar.path),
      );
    }

    final streamed = await request.send();

    final response = await http.Response.fromStream(streamed);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to update profile');
  }

  Future<Map<String, dynamic>> updatePhone({String? phone}) async {
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

      request.fields["phone"] = phone!;

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

  Future<List<AddressModel>> myAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("$baseUrl/my-addresses"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<AddressModel>.from(
        data["data"].map((x) => AddressModel.fromJson(x)),
      );
    }

    throw Exception(data["message"] ?? "Failed to load addresses");
  }

  Future<Map<String, dynamic>> updateAddress({
    required int id,
    required String fullName,
    required String address,
    required double lat,
    required double lng,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.put(
      Uri.parse("$baseUrl/address/$id"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
      body: {
        "full_name": fullName,
        "address": address,
        "lat": lat.toString(),
        "lng": lng.toString(),
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data["message"] ?? "Failed to update address");
  }

  Future<Map<String, dynamic>> deleteAddress(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.delete(
      Uri.parse("$baseUrl/address/$id"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data["message"] ?? "Failed to delete address");
  }

  Future<Map<String, dynamic>> setDefaultAddress(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.post(
      Uri.parse("$baseUrl/address/$id/default"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data["message"] ?? "Failed to set default address");
  }

  // ===========================order================================

  Future<Map<String, dynamic>> storeAddress({
    required String fullName,
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
        "full_name": fullName,
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

  Future<Map<String, dynamic>> applyCoupon({required String couponCode}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.post(
      Uri.parse("$baseUrl/coupons/apply"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
      body: {"code": couponCode},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data["message"] ?? "Failed to apply coupon");
  }

  Future<Map<String, dynamic>> placeOrder({
    required String deliveryAddress,
    required double lat,
    required double lng,
    required String paymentMethod,
    String? code,
    String? note,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.post(
      Uri.parse("$baseUrl/order"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
      body: {
        "delivery_address": deliveryAddress,
        "lat": lat.toString(),
        "lng": lng.toString(),
        "payment_method": paymentMethod,
        "code": code ?? "",
        "note": note ?? "",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }

    throw Exception(
      data["message"] ?? data["error"] ?? "Failed to place order",
    );
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

  Future<Map<String, dynamic>> getABADeeplink(int orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.post(
      Uri.parse("$baseUrl/aba-pay"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
      body: {"order_id": orderId.toString()},
    );

    return jsonDecode(response.body);
  }

  Future<void> saveGuestToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/device-token/guest'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': token,
          'device_id': 'android-device',
          'platform': Platform.isAndroid ? 'android' : 'ios',
        }),
      );

      print('Status Code: ${response.statusCode}');
      print(response.body);
    } catch (e) {
      print(e);
    }
  }

  Future<void> saveUserToken(String fcmToken) async {
    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('token');

    if (userToken == null) {
      print('User not logged in');
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/device-token'),
      headers: {
        'Authorization': 'Bearer $userToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fcm_token': fcmToken,
        'device_id': 'android-device',
        'platform': Platform.isAndroid ? 'android' : 'ios',
      }),
    );

    print('Status: ${response.statusCode}');
    print(response.body);
  }
}
