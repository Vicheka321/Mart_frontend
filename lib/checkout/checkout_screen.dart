// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../services/api_service.dart';
// import '../services/address_history_service.dart';
// import '../providers/cart_provider.dart';
// import '../screens/theme/app_theme.dart';
// import '../widgets/skeleton_loader.dart';
// import 'OrderSuccessScreen.dart';
// import 'khqr_screen.dart';

// class CheckoutScreen extends StatefulWidget {
//   const CheckoutScreen({super.key});

//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   GoogleMapController? mapController;
//   LatLng? currentPosition;

//   final phoneController = TextEditingController();
//   final userNameController = TextEditingController();
//   String paymentMethod = "khqr";
//   bool _isPlacingOrder = false; // ← prevents duplicate submissions

//   @override
//   void initState() {
//     super.initState();
//     _getLocation();
//     _loadUserProfile();
//   }

//   /// 👤 Load user profile from API
//   Future<void> _loadUserProfile() async {
//     try {
//       final profile = await ApiService().fetchMyProfile();
//       if (mounted) {
//         setState(() {
//           userNameController.text = profile.fullName;
//         });
//       }
//     } catch (e) {
//       print("Error loading profile: $e");
//     }
//   }

//   /// 📍 Get current location
//   Future<void> _getLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) return;

//     LocationPermission permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) return;

//     final pos = await Geolocator.getCurrentPosition();

//     setState(() {
//       currentPosition = LatLng(pos.latitude, pos.longitude);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("checkout".tr)),
//       body: currentPosition == null
//           ? const Center(
//               child: SkeletonBox(
//                 width: 180,
//                 height: 16,
//                 borderRadius: BorderRadius.all(Radius.circular(8)),
//               ),
//             )
//           : SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     /// ========== 📋 DETAILS SECTION ==========
//                     _buildDetailsSection(),
//                     const SizedBox(height: 20),

//                     /// ========== 📍 ADDRESS SECTION ==========
//                     _buildAddressSection(),
//                     const SizedBox(height: 20),

//                     /// ========== 🛒 ORDER SUMMARY SECTION ==========
//                     _buildOrderSummarySection(),
//                     const SizedBox(height: 20),

//                     /// ========== 💳 PAYMENT METHOD SECTION ==========
//                     _buildPaymentMethodSection(),
//                     const SizedBox(height: 24),

//                     /// ========== ✅ PLACE ORDER BUTTON ==========
//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         onPressed: _isPlacingOrder ? null : _placeOrder,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           disabledBackgroundColor: Colors.grey,
//                         ),
//                         child: _isPlacingOrder
//                             ? const SkeletonBox(
//                                 width: 86,
//                                 height: 12,
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(6),
//                                 ),
//                                 baseColor: Colors.white54,
//                                 highlightColor: Colors.white,
//                               )
//                             : Text(
//                                 "place_order".tr,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   /// ========== DETAILS SECTION WIDGET ==========
//   Widget _buildDetailsSection() {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "details".tr,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             // Name field
//             TextField(
//               controller: userNameController,
//               decoration: InputDecoration(
//                 labelText: "full_name".tr,
//                 prefixIcon: const Icon(Icons.person),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             // Phone field
//             TextField(
//               controller: phoneController,
//               keyboardType: TextInputType.phone,
//               decoration: InputDecoration(
//                 labelText: "phone".tr,
//                 prefixIcon: const Icon(Icons.phone),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// ========== ADDRESS SECTION WIDGET ==========
//   Widget _buildAddressSection() {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "address".tr,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             // Google Map
//             SizedBox(
//               height: 200,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: GoogleMap(
//                   initialCameraPosition: CameraPosition(
//                     target: currentPosition!,
//                     zoom: 15,
//                   ),
//                   onMapCreated: (c) => mapController = c,
//                   markers: {
//                     Marker(
//                       markerId: const MarkerId("me"),
//                       position: currentPosition!,
//                     ),
//                   },
//                   onTap: (pos) {
//                     setState(() {
//                       currentPosition = pos;
//                     });
//                   },
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               child: Text(
//                 "tap_map_change_location".tr,
//                 style: const TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// ========== ORDER SUMMARY SECTION WIDGET ==========
//   Widget _buildOrderSummarySection() {
//     return Consumer<CartProvider>(
//       builder: (context, cartProvider, _) {
//         final cart = cartProvider.cart;
//         if (cart == null) {
//           return Card(
//             elevation: 2,
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "order_summary".tr,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   const SkeletonBox(
//                     width: 150,
//                     height: 14,
//                     borderRadius: BorderRadius.all(Radius.circular(7)),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         return Card(
//           elevation: 2,
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "${"order_summary".tr} (${cart.items.length} items)",
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 // Items list
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: cart.items.length,
//                   itemBuilder: (context, index) {
//                     final item = cart.items[index];
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       child: Row(
//                         children: [
//                           // Item image thumbnail
//                           if (item.images.isNotEmpty)
//                             Container(
//                               width: 50,
//                               height: 50,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(6),
//                                 image: DecorationImage(
//                                   image: NetworkImage(item.images.first),
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             )
//                           else
//                             Container(
//                               width: 50,
//                               height: 50,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(6),
//                                 color: Colors.grey[300],
//                               ),
//                               child: const Icon(Icons.image),
//                             ),
//                           const SizedBox(width: 12),
//                           // Item details
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   item.name,
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   "Qty: ${item.qty}",
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           // Price
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text(
//                                 "\$${item.price}",
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               Text(
//                                 "\$${item.totalPrice.toStringAsFixed(2)}",
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 const Divider(),
//                 const SizedBox(height: 8),
//                 // Subtotal
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text("subtotal".tr),
//                     Text(
//                       "\$${cart.totalPrice.toStringAsFixed(2)}",
//                       style: const TextStyle(fontWeight: FontWeight.w600),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 // Total
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "total".tr,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       "\$${cart.totalPrice.toStringAsFixed(2)}",
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   /// ========== PAYMENT METHOD SECTION WIDGET ==========
//   Widget _buildPaymentMethodSection() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               "payment_method".tr,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//           const SizedBox(height: 12),
//           _buildPaymentOption(
//             value: "cash",
//             label: "pay_by_cash".tr,
//             icon: Icons.money,
//           ),
//           _buildPaymentOption(
//             value: "aba",
//             label: "pay_by_aba".tr,
//             icon: Icons.account_balance,
//           ),
//           _buildPaymentOption(
//             value: "khqr",
//             label: "pay_by_khqr".tr,
//             icon: Icons.qr_code,
//           ),
//           // Previous implementation using RadioListTile options:
//           // RadioListTile(
//           //   value: "cash",
//           //   groupValue: paymentMethod,
//           //   onChanged: (v) {
//           //     setState(() {
//           //       paymentMethod = v.toString();
//           //     });
//           //   },
//           //   title: const Text("pay by cash"),
//           //   contentPadding: EdgeInsets.zero,
//           // ),
//           // RadioListTile(
//           //   value: "aba",
//           //   groupValue: paymentMethod,
//           //   onChanged: (v) {
//           //     setState(() {
//           //       paymentMethod = v.toString();
//           //     });
//           //   },
//           //   title: const Text("pay by ABA"),
//           //   contentPadding: EdgeInsets.zero,
//           // ),
//           // RadioListTile(
//           //   value: "khqr",
//           //   groupValue: paymentMethod,
//           //   onChanged: (v) {
//           //     setState(() {
//           //       paymentMethod = v.toString();
//           //     });
//           //   },
//           //   title: const Text("pay by KHQR"),
//           //   contentPadding: EdgeInsets.zero,
//           // ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPaymentOption({
//     required String value,
//     required String label,
//     required IconData icon,
//   }) {
//     final bool selected = paymentMethod == value;
//     final colors = context.colors;
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return InkWell(
//       onTap: () {
//         setState(() {
//           paymentMethod = value;
//         });
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 6),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         decoration: BoxDecoration(
//           color: selected
//               ? (isDark ? colors.surface2 : colors.cardBg)
//               : colors.cardBg,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: selected ? Colors.green : colors.border,
//             width: selected ? 1.8 : 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: isDark
//                   ? Colors.transparent
//                   : Colors.black.withValues(alpha: 0.03),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: selected ? Colors.green : colors.text2),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                   color: selected ? colors.text1 : colors.text2,
//                 ),
//               ),
//             ),
//             Container(
//               width: 20,
//               height: 20,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: selected ? Colors.green : colors.border,
//                   width: 2,
//                 ),
//                 color: selected ? Colors.green : Colors.transparent,
//               ),
//               child: selected
//                   ? const Icon(Icons.check, size: 14, color: Colors.white)
//                   : null,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _placeOrder() async {
//     if (_isPlacingOrder) return; // double-tap guard

//     setState(() => _isPlacingOrder = true);

//     try {
//       if (currentPosition == null ||
//           phoneController.text.isEmpty ||
//           userNameController.text.isEmpty) {
//         setState(() => _isPlacingOrder = false);
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("please_fill_all_fields".tr)));
//         return;
//       }

//       final lat = currentPosition!.latitude;
//       final lng = currentPosition!.longitude;

//       final address = await getAddressFromLatLng(lat, lng);

//       /// ✅ SAVE ADDRESS
//       final addressRes = await ApiService().storeAddress(
//         phone: phoneController.text,
//         address: address,
//         lat: lat,
//         lng: lng,
//       );

//       final addressId = addressRes["address_id"];

//       await AddressHistoryService().saveAddress(
//         phone: phoneController.text,
//         address: address,
//         lat: lat,
//         lng: lng,
//       );

//       /// ✅ PLACE ORDER
//       final orderRes = await ApiService().placeOrder(
//         addressId: addressId,
//         paymentMethod: paymentMethod,
//       );

//       // Refresh cart state after a successful checkout so the UI updates immediately
//       await context.read<CartProvider>().fetchCart();

//       final orderId = orderRes["data"]["order_id"];

//       /// ✅ CASH
//       if (paymentMethod == "cash") {
//         if (!mounted) return;
//         setState(() => _isPlacingOrder = false);
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
//         );
//         return;
//       }

//       /// ✅ KHQR
//       if (paymentMethod == "khqr") {
//         final qrRes = await ApiService().generateQR(orderId);

//         // Use the amount from placeOrder response — backend returns it
//         // as a num (e.g. 2.50) directly in data["amount"].
//         final orderTotal = orderRes["data"]["amount"];
//         final displayAmount = orderTotal is String
//             ? orderTotal
//             : (orderTotal as num).toStringAsFixed(2);

//         if (!mounted) return;
//         setState(() => _isPlacingOrder = false);
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => KhqrScreen(
//               qrUrl: qrRes["qr_url"],
//               amount: displayAmount,
//               md5: qrRes["md5"],
//             ),
//           ),
//         );
//         return;
//       }

//       /// ✅ ABA PAY (Deep Link)
//       if (paymentMethod == "aba") {
//         final abaRes = await ApiService().getABADeeplink(orderId);

//         if (!mounted) return;
//         setState(() => _isPlacingOrder = false);

//         if (abaRes['success'] == true && abaRes['deeplink'] != null) {
//           final deeplink = abaRes['deeplink'] as String;
//           final uri = Uri.parse(deeplink);

//           if (await canLaunchUrl(uri)) {
//             await launchUrl(uri, mode: LaunchMode.externalApplication);
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text(
//                   'Cannot open ABA app. Please make sure it is installed.',
//                 ),
//               ),
//             );
//           }
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 abaRes['message'] ?? 'Failed to generate ABA payment',
//               ),
//             ),
//           );
//         }
//         return;
//       }

//       // Any other payment method — reset flag
//       if (mounted) setState(() => _isPlacingOrder = false);
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isPlacingOrder = false);
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(e.toString())));
//       }
//     }
//   }

//   Future<String> getAddressFromLatLng(double lat, double lng) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

//       Placemark place = placemarks.first;

//       return "${place.name}, ${place.locality}";
//     } catch (e) {
//       return "unknown_location".tr;
//     }
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mart_frontend/checkout/OrderSuccessScreen.dart';
import 'package:mart_frontend/checkout/khqr_screen.dart';
import 'package:mart_frontend/models/products_model.dart';
import 'package:mart_frontend/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/theme/app_theme.dart';

// ── Replace with your actual imports ──────────────────────────────────────────
// import '../services/api_service.dart';
// import '../screens/theme/app_theme.dart';
// import '../models/address_model.dart';
// ──────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────
// APP COLORS
// ─────────────────────────────────────────────

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────

enum PaymentMethod { cash, aba, khqr }

extension PaymentMethodX on PaymentMethod {
  String get apiValue => ['cash', 'aba', 'khqr'][index];
  String get label => ['Cash on Delivery', 'ABA Pay', 'KHQR'][index];
  String get desc => [
    'Pay when you receive',
    'Open ABA app to pay',
    'Scan QR code to pay',
  ][index];
  IconData get icon => [
    Icons.payments_outlined,
    Icons.account_balance_outlined,
    Icons.qr_code_scanner_rounded,
  ][index];
}

// Address used during checkout (may or may not be persisted)
class DeliveryAddress {
  final int?
  savedId; // non-null if pulled from myAddresses or after storeAddress()
  final String fullName;
  final String phone;
  final String address;
  final double lat;
  final double lng;

  const DeliveryAddress({
    this.savedId,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.lat,
    required this.lng,
  });

  DeliveryAddress copyWith({
    int? savedId,
    String? fullName,
    String? phone,
    String? address,
    double? lat,
    double? lng,
  }) => DeliveryAddress(
    savedId: savedId ?? this.savedId,
    fullName: fullName ?? this.fullName,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
  );

  bool get isSaved => savedId != null;
}

// Mirrors AddressModel from your API
class SavedAddress {
  final int id;
  final String? fullName;
  final String address;
  final double lat, lng;
  final bool isDefault;

  const SavedAddress({
    required this.id,
    this.fullName,
    required this.address,
    required this.lat,
    required this.lng,
    required this.isDefault,
  });

  // Replace with AddressModel.fromJson in production
  factory SavedAddress.fromJson(Map<String, dynamic> j) => SavedAddress(
    id: j['id'] as int,
    fullName: j['full_name']?.toString(),
    address: j['address']?.toString() ?? '',
    lat: double.tryParse(j['lat'].toString()) ?? 0,
    lng: double.tryParse(j['lng'].toString()) ?? 0,
    isDefault: j['is_default'] == true || j['is_default'] == 1,
  );

  DeliveryAddress toDelivery() => DeliveryAddress(
    savedId: id,
    fullName: fullName ?? '',
    phone: '',
    address: address,
    lat: lat,
    lng: lng,
  );
}

class OrderItem {
  final String id, name, imageUrl;
  final double unitPrice;
  final int quantity;

  const OrderItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
  });

  double get totalPrice => unitPrice * quantity;
}

class CouponResult {
  final double discount;
  final String code;
  const CouponResult({required this.discount, required this.code});
}

// ─────────────────────────────────────────────
// CHECKOUT CONTROLLER
// ─────────────────────────────────────────────

class CheckoutController extends ChangeNotifier {
  // final ApiService _api;
  final List<OrderItem> items;
  final double deliveryFee;

  CheckoutController({
    required this.items,
    this.deliveryFee = 1.50,
  }); // : _api = api;

  // ── State ──────────────────────────────────
  PaymentMethod _payment = PaymentMethod.cash;
  PaymentMethod get payment => _payment;

  CouponResult? _coupon;
  CouponResult? get coupon => _coupon;
  MyCartModel? _cart;
  MyCartModel? get cart => _cart;
  bool _couponLoading = false;
  bool get couponLoading => _couponLoading;
  String? _couponError;
  String? get couponError => _couponError;

  bool _placingOrder = false;
  bool get placingOrder => _placingOrder;

  bool _savingAddress = false;
  bool get savingAddress => _savingAddress;
  String? _addressError;
  String? get addressError => _addressError;

  List<SavedAddress> _savedAddresses = [];
  List<SavedAddress> get savedAddresses => _savedAddresses;
  bool _loadingAddresses = false;
  bool get loadingAddresses => _loadingAddresses;

  // ── Computed ───────────────────────────────
  double get subtotal {
    if (_cart != null) {
      return _cart!.totalPrice;
    }

    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get discount => _coupon?.discount ?? 0;
  // double get total =>
  //     (subtotal + deliveryFee - discount).clamp(0, double.infinity);
  double get total => (subtotal - discount).clamp(0, double.infinity);

  // ── Load saved addresses ───────────────────
  Future<void> loadAddresses() async {
    _loadingAddresses = true;
    notifyListeners();

    try {
      final addresses = await ApiService().myAddresses();

      _savedAddresses = addresses.map((e) {
        return SavedAddress(
          id: e.id,
          fullName: e.fullName,

          address: e.address,
          lat: double.parse(e.lat.toString()),
          lng: double.parse(e.lng.toString()),
          isDefault: e.isDefault,
        );
      }).toList();
    } catch (e) {
      debugPrint(e.toString());
    }

    _loadingAddresses = false;
    notifyListeners();
  }

  // ── Payment ────────────────────────────────
  void selectPayment(PaymentMethod m) {
    _payment = m;
    notifyListeners();
  }

  Future<void> loadCartSummary() async {
    try {
      _cart = await ApiService().getCart();

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // ── Coupon ─────────────────────────────────
  Future<void> applyCoupon(String code, double orderTotal) async {
    if (code.trim().isEmpty) return;

    _couponLoading = true;
    _couponError = null;
    notifyListeners();

    try {
      final res = await ApiService().applyCoupon(couponCode: code.trim());

      _coupon = CouponResult(
        code: code.trim().toUpperCase(),
        discount: double.parse(res["summary"]["coupon_discount"].toString()),
      );

      _couponError = null;
    } catch (e) {
      _coupon = null;
      _couponError = e.toString().replaceAll("Exception: ", "");
    }

    _couponLoading = false;
    notifyListeners();
  }

  void removeCoupon() {
    _coupon = null;
    _couponError = null;
    notifyListeners();
  }

  // ── Save address ───────────────────────────
  Future<int?> saveAddress(DeliveryAddress addr) async {
    _savingAddress = true;
    _addressError = null;
    notifyListeners();

    try {
      await ApiService().storeAddress(
        fullName: "Others",
        address: addr.address,
        lat: addr.lat,
        lng: addr.lng,
      );

      _savingAddress = false;
      notifyListeners();
    } catch (e) {
      _addressError = e.toString();

      _savingAddress = false;
      notifyListeners();

      return null;
    }
  }

  // ── Place order ────────────────────────────
  Future<void> placeOrder({
    required DeliveryAddress address,
    required String couponCode,
    required void Function(String id) onCash,
    required void Function(
      String orderId,
      String qrUrl,
      String amount,
      String md5,
    )
    onKhqr,
    required void Function(String deeplink) onAba,
    required void Function(String msg) onError,
  }) async {
    try {
      _placingOrder = true;
      notifyListeners();
      final res = await ApiService().placeOrder(
        deliveryAddress: address.address,
        lat: address.lat,
        lng: address.lng,
        paymentMethod: _payment.apiValue,
        code: couponCode.isEmpty ? null : couponCode,
      );

      final data = res["data"];

      final orderId = data["order_id"].toString();

      switch (_payment) {
        case PaymentMethod.cash:
          onCash(orderId);
          break;

        case PaymentMethod.khqr:
          final qrRes = await ApiService().generateQR(int.parse(orderId));

          onKhqr(
            orderId,
            qrRes["qr_url"],
            qrRes["amount"].toString(),
            qrRes["md5"],
          );

          break;
        case PaymentMethod.aba:
          final abaRes = await ApiService().getABADeeplink(int.parse(orderId));

          onAba(abaRes["deeplink"]);

          break;
      }
    } catch (e) {
      onError(e.toString().replaceAll("Exception: ", ""));
    } finally {
      _placingOrder = false;
      notifyListeners();
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// CHECKOUT SCREEN
// ═══════════════════════════════════════════════════════════════

class CheckoutScreen extends StatefulWidget {
  final List<OrderItem> items;
  final bool fromCart;

  const CheckoutScreen({super.key, required this.items, this.fromCart = true});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final CheckoutController _ctrl;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _couponCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  // Current delivery address (starts empty)
  DeliveryAddress? _address;
  bool _shouldSaveAddress = false; // "Save this address" checkbox
  String? _profilePhone;

  @override
  void initState() {
    super.initState();

    _ctrl = CheckoutController(items: widget.items);

    if (widget.fromCart) {
      _ctrl.loadCartSummary();
    }
    _loadProfile();
    _ctrl.loadAddresses().then((_) {
      final defaultAddress = _ctrl.savedAddresses
          .where((e) => e.isDefault)
          .firstOrNull;

      if (defaultAddress != null) {
        setState(() {
          _address = defaultAddress.toDelivery();
          _nameCtrl.text = defaultAddress.fullName ?? "";
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _couponCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ApiService().fetchMyProfile();

      if (!mounted) return;

      setState(() {
        _profilePhone = profile.phone;
        _phoneCtrl.text = profile.phone ?? '';
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _updatePhoneIfNeeded() async {
    if ((_profilePhone ?? '').trim().isEmpty &&
        _phoneCtrl.text.trim().isNotEmpty) {
      try {
        await ApiService().updatePhone(phone: _phoneCtrl.text.trim());

        _profilePhone = _phoneCtrl.text.trim();
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  // ── Open map picker ────────────────────────
  Future<void> _openMapPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => MapPickerScreen(
          initialPosition: _address != null
              ? LatLng(_address!.lat, _address!.lng)
              : null,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
    if (result == null) return;
    setState(() {
      // New location: drop savedId so it's treated as unsaved
      _address = DeliveryAddress(
        savedId: null,
        fullName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: result['address'] as String,
        lat: result['lat'] as double,
        lng: result['lng'] as double,
      );
    });
  }

  // ── Open saved address picker ──────────────
  void _openSavedAddresses() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SavedAddressSheet(
        addresses: _ctrl.savedAddresses,
        selectedId: _address?.savedId,
        colors: context.colors,
        onSelect: (addr) {
          setState(() {
            _address = addr.toDelivery();
            _nameCtrl.text = addr.fullName ?? '';

            _shouldSaveAddress = false;
          });
          Navigator.pop(context);
        },
        onAddNew: () {
          Navigator.pop(context);
          _openMapPicker();
        },
      ),
    );
  }

  // ── Place order flow ───────────────────────
  Future<void> _handlePlaceOrder() async {
    final colors = context.colors;

    // 1. Validate contact
    if (_phoneCtrl.text.trim().isEmpty) {
      _snack('Please fill in your phone number', isError: true);
      return;
    }
    // 2. Validate address
    if (_address == null || _address!.address.isEmpty) {
      _snack('Please select a delivery location', isError: true);
      return;
    }

    // 3. Update address with latest contact fields
    _address = _address!.copyWith(
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );

    await _updatePhoneIfNeeded();

    if (!mounted) return;
    await _ctrl.placeOrder(
      address: _address!,

      couponCode: _ctrl.coupon?.code ?? '',
      onCash: (id) {
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OrderSuccessScreen(orderId: id)));
        _snack('Order placed! ID: $id');
      },
      onKhqr: (id, qrUrl, amount, md5) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KhqrScreen(qrUrl: qrUrl, amount: amount, md5: md5),
          ),
        );
      },
      onAba: (deeplink) {
        launchUrl(Uri.parse(deeplink), mode: LaunchMode.externalApplication);
        _snack('ABA: $deeplink');
      },
      onError: (msg) {
        if (mounted) _snack(msg, isError: true);
      },
    );
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError
            ? const Color(0xFFDC2626)
            : const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(colors),
      body: ListenableBuilder(
        listenable: _ctrl,
        builder: (_, __) =>
            Stack(children: [_buildScroll(colors), _buildBottom(colors)]),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppColors colors) => AppBar(
    backgroundColor: colors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    title: Text(
      'Checkout',
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: colors.text1,
      ),
    ),
    leading: Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pop(context),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface2,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: colors.text1,
          ),
        ),
      ),
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Divider(height: 1, color: colors.border),
    ),
  );

  Widget _buildScroll(AppColors colors) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildAddressCard(colors),
              const SizedBox(height: 14),
              _buildContactCard(colors),
              const SizedBox(height: 14),
              _buildNoteCard(colors),
              const SizedBox(height: 14),
              _buildCouponCard(colors),
              const SizedBox(height: 14),
              _buildOrderSummary(colors),
              const SizedBox(height: 14),
              _buildPriceSummary(colors),
              const SizedBox(height: 14),
              _buildPaymentCard(colors),
            ]),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // DELIVERY ADDRESS CARD
  // ══════════════════════════════════════════

  Widget _buildAddressCard(AppColors colors) {
    final hasAddr = _address != null && _address!.address.isNotEmpty;

    return _Card(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──
          Row(
            children: [
              Expanded(
                child: _Label(label: 'Delivery Address', colors: colors),
              ),
              // Saved addresses button
              if (_ctrl.savedAddresses.isNotEmpty)
                GestureDetector(
                  onTap: _openSavedAddresses,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.accentLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bookmarks_rounded,
                          size: 13,
                          color: colors.accent,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Saved (${_ctrl.savedAddresses.length})',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Address preview row ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _openMapPicker,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: hasAddr ? colors.accentLight : colors.surface2,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: hasAddr ? colors.accent : colors.text3,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: hasAddr
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_nameCtrl.text.isNotEmpty)
                            Text(
                              _nameCtrl.text,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: colors.text1,
                              ),
                            ),
                          if (_phoneCtrl.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                _phoneCtrl.text,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.text2,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              _address!.address,
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.text2,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (_address!.isSaved) ...[
                                _Chip(
                                  label: '✓ Saved',
                                  color: const Color(0xFF16A34A),
                                  bg: const Color(0xFFDCFCE7),
                                ),
                                const SizedBox(width: 6),
                              ],
                              _Chip(
                                label: 'Home',
                                color: colors.accent,
                                bg: colors.accentLight,
                              ),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No location selected',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colors.text3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap the map or choose a saved address',
                            style: TextStyle(fontSize: 12, color: colors.text3),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _openMapPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.accentLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    hasAddr ? 'Edit' : 'Select',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.accent,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Map preview ──
          GestureDetector(
            onTap: _openMapPicker,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: 120,
                child: hasAddr
                    ? GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(_address!.lat, _address!.lng),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('d'),
                            position: LatLng(_address!.lat, _address!.lng),
                          ),
                        },
                        zoomControlsEnabled: false,
                        scrollGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        myLocationButtonEnabled: false,
                        liteModeEnabled: true,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors.accentLight.withOpacity(0.6),
                              colors.accentLight,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_location_alt_rounded,
                                size: 28,
                                color: colors.accent,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tap to select location',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),

          // ── Save address checkbox (only shown for new/unsaved addresses) ──
          if (_address != null && !_address!.isSaved) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () =>
                  setState(() => _shouldSaveAddress = !_shouldSaveAddress),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _shouldSaveAddress
                      ? colors.accentLight
                      : colors.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _shouldSaveAddress ? colors.accent : colors.border,
                    width: _shouldSaveAddress ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _shouldSaveAddress
                            ? colors.accent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _shouldSaveAddress
                              ? colors.accent
                              : colors.text3,
                          width: 1.5,
                        ),
                      ),
                      child: _shouldSaveAddress
                          ? const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Save this address',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _shouldSaveAddress
                                  ? colors.accent
                                  : colors.text1,
                            ),
                          ),
                          Text(
                            'Reuse for future orders',
                            style: TextStyle(fontSize: 11, color: colors.text3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ── Saving state / error ──
          if (_ctrl.savingAddress) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.accent,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Saving address…',
                  style: TextStyle(fontSize: 12, color: colors.text3),
                ),
              ],
            ),
          ],
          if (_ctrl.addressError != null) ...[
            const SizedBox(height: 8),
            Text(
              _ctrl.addressError!,
              style: TextStyle(fontSize: 12, color: colors.flashText),
            ),
          ],
        ],
      ),
    );
  }

  // ── Contact card ───────────────────────────

  Widget _buildContactCard(AppColors colors) => _Card(
    colors: colors,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label: 'Contact Information', colors: colors),
        // _Field(
        //   controller: _nameCtrl,
        //   label: 'Full Name',
        //   hint: 'Enter your name',
        //   icon: Icons.person_outline_rounded,
        //   colors: colors,
        //   onChanged: (_) => setState(() {}),
        // ),
        // const SizedBox(height: 12),
        _Field(
          controller: _phoneCtrl,
          label: 'Phone Number',
          hint: '+855 xx xxx xxx',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          colors: colors,
          onChanged: (_) => setState(() {}),
        ),
      ],
    ),
  );

  Widget _buildOrderSummary(AppColors colors) {
    // BUY AGAIN
    if (!widget.fromCart) {
      return _Card(
        colors: colors,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Label(
              label: 'Order Summary (${widget.items.length} items)',
              colors: colors,
            ),
            const SizedBox(height: 12),

            ...widget.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        item.imageUrl,
                        width: 55,
                        height: 55,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: colors.text1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Qty: ${item.quantity}',
                            style: TextStyle(fontSize: 12, color: colors.text3),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.text1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // CART FLOW
    final cart = _ctrl.cart;

    if (cart == null) {
      return _Card(
        colors: colors,
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return _Card(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(
            label: 'Order Summary (${cart.items.length} items)',
            colors: colors,
          ),

          const SizedBox(height: 12),

          ...cart.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      item.images.isNotEmpty ? item.images.first : '',
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colors.text1,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Qty: ${item.qty}',
                          style: TextStyle(fontSize: 12, color: colors.text3),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    '\$${item.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colors.text1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Payment card ───────────────────────────

  Widget _buildPaymentCard(AppColors colors) => _Card(
    colors: colors,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label: 'Payment Method', colors: colors),
        ...PaymentMethod.values.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PaymentTile(
              method: m,
              selected: _ctrl.payment,
              colors: colors,
              onTap: () => _ctrl.selectPayment(m),
            ),
          ),
        ),
      ],
    ),
  );

  // ── Coupon card ────────────────────────────

  Widget _buildCouponCard(AppColors colors) => _Card(
    colors: colors,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label: 'Promo Code', colors: colors),
        Row(
          children: [
            Expanded(
              child: _CouponInput(
                controller: _couponCtrl,
                colors: colors,
                hasSuccess: _ctrl.coupon != null,
                hasError: _ctrl.couponError != null,
                enabled: _ctrl.coupon == null && !_ctrl.couponLoading,
              ),
            ),
            const SizedBox(width: 8),
            _ApplyBtn(
              loading: _ctrl.couponLoading,
              enabled: _ctrl.coupon == null && !_ctrl.couponLoading,
              colors: colors,
              onTap: () =>
                  _ctrl.applyCoupon(_couponCtrl.text.trim(), _ctrl.total),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_ctrl.coupon != null) ...[
                const SizedBox(height: 10),
                _CouponChip(
                  code: _ctrl.coupon!.code,
                  discount: _ctrl.coupon!.discount,
                  colors: colors,
                  onRemove: () {
                    _couponCtrl.clear();
                    _ctrl.removeCoupon();
                  },
                ),
              ],
              if (_ctrl.couponError != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 15,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _ctrl.couponError!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );

  // ── Note card ──────────────────────────────

  Widget _buildNoteCard(AppColors colors) => _Card(
    colors: colors,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label: 'Order Note (Optional)', colors: colors),
        Container(
          decoration: BoxDecoration(
            color: colors.surface2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: TextField(
            controller: _noteCtrl,
            maxLines: 3,
            style: TextStyle(fontSize: 14, color: colors.text1),
            decoration: InputDecoration(
              hintText: 'e.g. "Call before delivery"',
              hintStyle: TextStyle(color: colors.text3),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),
      ],
    ),
  );

  // ── Price summary ──────────────────────────

  Widget _buildPriceSummary(AppColors colors) => _Card(
    colors: colors,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label: 'Price Summary', colors: colors),
        _PriceRow(
          label: 'Subtotal',
          value: '\$${_ctrl.subtotal.toStringAsFixed(2)}',
          colors: colors,
        ),
        // const SizedBox(height: 10),
        // _PriceRow(
        //   label: 'Delivery Fee',
        //   value: '\$${_ctrl.deliveryFee.toStringAsFixed(2)}',
        //   colors: colors,
        // ),
        if (_ctrl.coupon != null) ...[
          const SizedBox(height: 10),
          _PriceRow(
            label: 'Coupon (${_ctrl.coupon!.code})',
            value: '-\$${_ctrl.discount.toStringAsFixed(2)}',
            valueColor: const Color(0xFF16A34A),
            colors: colors,
          ),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: colors.border, thickness: 1),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colors.text1,
              ),
            ),
            Text(
              '\$${_ctrl.total.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: colors.accent,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  // ── Sticky bottom ──────────────────────────

  Widget _buildBottom(AppColors colors) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(top: BorderSide(color: colors.border)),
        ),
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 12, color: colors.text3),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${_ctrl.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: colors.text1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: (_ctrl.placingOrder || _ctrl.savingAddress)
                    ? null
                    : _handlePlaceOrder,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 52,
                  decoration: BoxDecoration(
                    color: (_ctrl.placingOrder || _ctrl.savingAddress)
                        ? colors.accent.withOpacity(0.6)
                        : colors.accent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colors.accent.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: (_ctrl.placingOrder || _ctrl.savingAddress)
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Place Order',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SAVED ADDRESS BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════

class _SavedAddressSheet extends StatelessWidget {
  final List<SavedAddress> addresses;
  final int? selectedId;
  final AppColors colors;
  final void Function(SavedAddress) onSelect;
  final VoidCallback onAddNew;

  const _SavedAddressSheet({
    required this.addresses,
    required this.selectedId,
    required this.colors,
    required this.onSelect,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        0,
        0,
        0,
        MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Saved Addresses',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: colors.text1,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onAddNew,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 15, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Add New',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: colors.border),

          // Address list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.55,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final addr = addresses[i];
                final isSelected = addr.id == selectedId;
                return GestureDetector(
                  onTap: () {
                    // HapticFeedback.selectionClick();
                    onSelect(addr);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? colors.accentLight : colors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? colors.accent : colors.border,
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.accent.withOpacity(0.12)
                                : colors.surface2,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            addr.fullName == 'Home'
                                ? Icons.home_rounded
                                : addr.fullName == 'Work'
                                ? Icons.work_rounded
                                : Icons.location_on_rounded,
                            size: 18,
                            color: isSelected ? colors.accent : colors.text2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    addr.fullName ?? 'Address',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? colors.accent
                                          : colors.text1,
                                    ),
                                  ),
                                  if (addr.isDefault) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.accent.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        'Default',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: colors.accent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                addr.address,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.text2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                addr.address,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.text3,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? colors.accent
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? colors.accent : colors.border,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 13,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MAP PICKER SCREEN  (full-screen + search)
// ═══════════════════════════════════════════════════════════════

// class MapPickerScreen extends StatefulWidget {
//   final LatLng? initialPosition;
//   const MapPickerScreen({super.key, this.initialPosition});

//   @override
//   State<MapPickerScreen> createState() => _MapPickerScreenState();
// }

// class _MapPickerScreenState extends State<MapPickerScreen>
//     with SingleTickerProviderStateMixin {
//   GoogleMapController? _mapCtrl;
//   LatLng _picked = const LatLng(11.5564, 104.9282);
//   String _resolvedAddress = 'Locating…';
//   bool _resolving = false;

//   final _searchCtrl = TextEditingController();
//   final _searchFocus = FocusNode();
//   bool _searchActive = false;
//   bool _searching = false;
//   List<_Sugg> _suggestions = [];
//   Timer? _debounce;
//   bool _locating = false;

//   late final AnimationController _panelCtrl;
//   late final Animation<Offset> _panelSlide;

//   @override
//   void initState() {
//     super.initState();

//     _panelCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );

//     _panelSlide = Tween<Offset>(
//       begin: const Offset(0, 1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _panelCtrl, curve: Curves.easeOutCubic));

//     _panelCtrl.forward();

//     _searchFocus.addListener(() {
//       setState(() => _searchActive = _searchFocus.hasFocus);

//       if (!_searchFocus.hasFocus) {
//         setState(() => _suggestions = []);
//       }
//     });

//     _initLocation(); // ✅ important
//   }

//   @override
//   void dispose() {
//     _mapCtrl?.dispose();
//     _searchCtrl.dispose();
//     _searchFocus.dispose();
//     _debounce?.cancel();
//     _panelCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _resolveAddress(LatLng pos) async {
//     setState(() => _resolving = true);
//     try {
//       final marks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
//       if (marks.isNotEmpty) {
//         final p = marks.first;
//         final parts = [
//           p.street,
//           p.subLocality,
//           p.locality,
//           p.country,
//         ].where((s) => s != null && s!.isNotEmpty).join(', ');
//         setState(
//           () => _resolvedAddress = parts.isNotEmpty
//               ? parts
//               : '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
//         );
//       }
//     } catch (_) {
//       setState(
//         () => _resolvedAddress =
//             '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
//       );
//     }
//     setState(() => _resolving = false);
//   }

//   void _onSearchChanged(String q) {
//     _debounce?.cancel();
//     if (q.trim().isEmpty) {
//       setState(() => _suggestions = []);
//       return;
//     }
//     _debounce = Timer(
//       const Duration(milliseconds: 500),
//       () => _fetchSuggestions(q.trim()),
//     );
//   }

//   Future<void> _fetchSuggestions(String query) async {
//     setState(() => _searching = true);
//     try {
//       final locs = await locationFromAddress(query);
//       final results = <_Sugg>[];
//       for (final loc in locs.take(5)) {
//         final marks = await placemarkFromCoordinates(
//           loc.latitude,
//           loc.longitude,
//         );
//         String label = query;
//         if (marks.isNotEmpty) {
//           final p = marks.first;
//           final parts = [
//             p.name,
//             p.subLocality,
//             p.locality,
//             p.country,
//           ].where((s) => s != null && s!.isNotEmpty).join(', ');
//           if (parts.isNotEmpty) label = parts;
//         }
//         results.add(
//           _Sugg(display: label, lat: loc.latitude, lng: loc.longitude),
//         );
//       }
//       if (mounted) setState(() => _suggestions = results);
//     } catch (_) {
//       if (mounted) setState(() => _suggestions = []);
//     }
//     if (mounted) setState(() => _searching = false);
//   }

//   void _selectSugg(_Sugg s) {
//     _searchCtrl.text = s.display;
//     _searchFocus.unfocus();
//     setState(() {
//       _suggestions = [];
//       _searchActive = false;
//     });
//     final ll = LatLng(s.lat, s.lng);
//     _mapCtrl?.animateCamera(CameraUpdate.newLatLngZoom(ll, 16));
//     setState(() => _picked = ll);
//     _resolveAddress(ll);
//     // HapticFeedback.selectionClick();
//   }

//   Future<void> _goToMyLocation() async {
//     setState(() => _locating = true);
//     // HapticFeedback.mediumImpact();
//     try {
//       LocationPermission perm = await Geolocator.checkPermission();
//       if (perm == LocationPermission.denied)
//         perm = await Geolocator.requestPermission();
//       if (perm == LocationPermission.deniedForever) {
//         setState(() => _locating = false);
//         return;
//       }
//       final pos = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       final ll = LatLng(pos.latitude, pos.longitude);
//       _mapCtrl?.animateCamera(CameraUpdate.newLatLngZoom(ll, 16));
//       setState(() => _picked = ll);
//       _resolveAddress(ll);
//     } catch (_) {}
//     setState(() => _locating = false);
//   }

//   void _confirm() {
//     // HapticFeedback.heavyImpact();
//     Navigator.pop(context, {
//       'lat': _picked.latitude,
//       'lng': _picked.longitude,
//       'address': _resolvedAddress,
//     });
//   }

//   Future<void> _initLocation() async {
//     try {
//       // User already selected address before
//       if (widget.initialPosition != null) {
//         _picked = widget.initialPosition!;

//         await _resolveAddress(_picked);
//         return;
//       }

//       // First time open map
//       final pos = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       _picked = LatLng(pos.latitude, pos.longitude);

//       await _resolveAddress(_picked);

//       if (_mapCtrl != null) {
//         _mapCtrl!.animateCamera(CameraUpdate.newLatLngZoom(_picked, 16));
//       }

//       if (mounted) setState(() {});
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     return Scaffold(
//       backgroundColor: colors.background,
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: GoogleMap(
//               initialCameraPosition: CameraPosition(target: _picked, zoom: 15),
//               onMapCreated: (c) {
//                 _mapCtrl = c;

//                 if (widget.initialPosition != null) {
//                   c.animateCamera(
//                     CameraUpdate.newLatLngZoom(widget.initialPosition!, 16),
//                   );
//                 }
//               },
//               myLocationEnabled: false,
//               myLocationButtonEnabled: false,
//               zoomControlsEnabled: false,
//               compassEnabled: false,
//               mapToolbarEnabled: false,
//               onCameraMove: (pos) => setState(() => _picked = pos.target),
//               onCameraIdle: () => _resolveAddress(_picked),
//             ),
//           ),

//           // Centre pin
//           const Positioned.fill(
//             child: IgnorePointer(child: Center(child: _CentrePin())),
//           ),

//           // Top bar + search
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: _TopSearchBar(
//               colors: colors,
//               searchCtrl: _searchCtrl,
//               searchFocus: _searchFocus,
//               searchActive: _searchActive,
//               searching: _searching,
//               onChanged: _onSearchChanged,
//               onClear: () {
//                 _searchCtrl.clear();
//                 setState(() => _suggestions = []);
//               },
//               onBack: () => Navigator.pop(context),
//             ),
//           ),

//           // Suggestions
//           if (_suggestions.isNotEmpty ||
//               (_searching && _searchCtrl.text.isNotEmpty))
//             Positioned(
//               top: MediaQuery.of(context).padding.top + 72,
//               left: 16,
//               right: 16,
//               child: _SuggestionsList(
//                 colors: colors,
//                 suggestions: _suggestions,
//                 searching: _searching,
//                 onSelect: _selectSugg,
//               ),
//             ),

//           // My location FAB
//           Positioned(
//             right: 16,
//             bottom: MediaQuery.of(context).padding.bottom + 250,
//             child: GestureDetector(
//               onTap: _locating ? null : _goToMyLocation,
//               child: Container(
//                 width: 48,
//                 height: 48,
//                 decoration: BoxDecoration(
//                   color: colors.surface,
//                   shape: BoxShape.circle,
//                   border: Border.all(color: colors.border),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.14),
//                       blurRadius: 16,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: _locating
//                     ? Padding(
//                         padding: const EdgeInsets.all(14),
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: colors.accent,
//                         ),
//                       )
//                     : Icon(
//                         Icons.my_location_rounded,
//                         color: colors.accent,
//                         size: 22,
//                       ),
//               ),
//             ),
//           ),

//           // Bottom confirm panel
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: SlideTransition(
//               position: _panelSlide,
//               child: Container(
//                 padding: EdgeInsets.fromLTRB(
//                   16,
//                   20,
//                   16,
//                   MediaQuery.of(context).padding.bottom + 20,
//                 ),
//                 decoration: BoxDecoration(
//                   color: colors.surface,
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(28),
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.12),
//                       blurRadius: 28,
//                       offset: const Offset(0, -6),
//                     ),
//                   ],
//                   border: Border(top: BorderSide(color: colors.border)),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 40,
//                       height: 4,
//                       margin: const EdgeInsets.only(bottom: 18),
//                       decoration: BoxDecoration(
//                         color: colors.border,
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           width: 44,
//                           height: 44,
//                           decoration: BoxDecoration(
//                             color: colors.accentLight,
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                           child: Icon(
//                             Icons.location_on_rounded,
//                             color: colors.accent,
//                             size: 22,
//                           ),
//                         ),
//                         const SizedBox(width: 14),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Delivery Location',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w600,
//                                   color: colors.text3,
//                                   letterSpacing: 0.4,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               _resolving
//                                   ? _ShimmerBar(colors: colors)
//                                   : Text(
//                                       _resolvedAddress,
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w600,
//                                         color: colors.text1,
//                                         height: 1.4,
//                                       ),
//                                       maxLines: 3,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 '${_picked.latitude.toStringAsFixed(5)}, ${_picked.longitude.toStringAsFixed(5)}',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   color: colors.text3,
//                                   fontFamily: 'monospace',
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 18),
//                     GestureDetector(
//                       onTap: _resolving ? null : _confirm,
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         width: double.infinity,
//                         height: 54,
//                         decoration: BoxDecoration(
//                           color: _resolving
//                               ? colors.accent.withOpacity(0.5)
//                               : colors.accent,
//                           borderRadius: BorderRadius.circular(18),
//                           boxShadow: _resolving
//                               ? []
//                               : [
//                                   BoxShadow(
//                                     color: colors.accent.withOpacity(0.38),
//                                     blurRadius: 18,
//                                     offset: const Offset(0, 6),
//                                   ),
//                                 ],
//                         ),
//                         child: Center(
//                           child: _resolving
//                               ? const SizedBox(
//                                   width: 22,
//                                   height: 22,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2.5,
//                                     color: Colors.white,
//                                   ),
//                                 )
//                               : const Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(
//                                       Icons.check_circle_rounded,
//                                       color: Colors.white,
//                                       size: 20,
//                                     ),
//                                     SizedBox(width: 8),
//                                     Text(
//                                       'Confirm Location',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w800,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class MapPickerScreen extends StatefulWidget {
  final LatLng? initialPosition;
  const MapPickerScreen({super.key, this.initialPosition});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapCtrl;
  LatLng? _picked;
  bool _loadingLocation = true;
  bool _locationError = false;
  String _resolvedAddress = 'Locating…';
  bool _resolving = false;

  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searchActive = false;
  bool _searching = false;
  List<_Sugg> _suggestions = [];
  Timer? _debounce;
  bool _locating = false;

  late final AnimationController _panelCtrl;
  late final Animation<Offset> _panelSlide;

  @override
  void initState() {
    super.initState();

    _panelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _panelSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _panelCtrl, curve: Curves.easeOutCubic));

    _panelCtrl.forward();

    _searchFocus.addListener(() {
      setState(() => _searchActive = _searchFocus.hasFocus);

      if (!_searchFocus.hasFocus) {
        setState(() => _suggestions = []);
      }
    });

    _initLocation(); // ✅ important
  }

  @override
  void dispose() {
    _mapCtrl?.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    _panelCtrl.dispose();
    super.dispose();
  }

  Future<void> _resolveAddress(LatLng pos) async {
    setState(() => _resolving = true);
    try {
      final marks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (marks.isNotEmpty) {
        final p = marks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
          p.country,
        ].where((s) => s != null && s!.isNotEmpty).join(', ');
        setState(
          () => _resolvedAddress = parts.isNotEmpty
              ? parts
              : '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
        );
      }
    } catch (_) {
      setState(
        () => _resolvedAddress =
            '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
      );
    }
    setState(() => _resolving = false);
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _fetchSuggestions(q.trim()),
    );
  }

  Future<void> _fetchSuggestions(String query) async {
    setState(() => _searching = true);
    try {
      final locs = await locationFromAddress(query);
      final results = <_Sugg>[];
      for (final loc in locs.take(5)) {
        final marks = await placemarkFromCoordinates(
          loc.latitude,
          loc.longitude,
        );
        String label = query;
        if (marks.isNotEmpty) {
          final p = marks.first;
          final parts = [
            p.name,
            p.subLocality,
            p.locality,
            p.country,
          ].where((s) => s != null && s!.isNotEmpty).join(', ');
          if (parts.isNotEmpty) label = parts;
        }
        results.add(
          _Sugg(display: label, lat: loc.latitude, lng: loc.longitude),
        );
      }
      if (mounted) setState(() => _suggestions = results);
    } catch (_) {
      if (mounted) setState(() => _suggestions = []);
    }
    if (mounted) setState(() => _searching = false);
  }

  void _selectSugg(_Sugg s) {
    _searchCtrl.text = s.display;
    _searchFocus.unfocus();
    setState(() {
      _suggestions = [];
      _searchActive = false;
    });
    final ll = LatLng(s.lat, s.lng);
    _mapCtrl?.animateCamera(CameraUpdate.newLatLngZoom(ll, 16));
    setState(() => _picked = ll);
    _resolveAddress(ll);
    // HapticFeedback.selectionClick();
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    // HapticFeedback.mediumImpact();
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied)
        perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.deniedForever) {
        setState(() => _locating = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final ll = LatLng(pos.latitude, pos.longitude);
      _mapCtrl?.animateCamera(CameraUpdate.newLatLngZoom(ll, 16));
      setState(() => _picked = ll);
      _resolveAddress(ll);
    } catch (_) {}
    setState(() => _locating = false);
  }

  void _confirm() {
    // HapticFeedback.heavyImpact();
    Navigator.pop(context, {
      'lat': _picked!.latitude,
      'lng': _picked!.longitude,
      'address': _resolvedAddress,
    });
  }

  Future<void> _initLocation() async {
    // Case 1: existing saved address
    if (widget.initialPosition != null) {
      _picked = widget.initialPosition!;
      setState(() => _loadingLocation = false);
      await _resolveAddress(_picked!);
      return;
    }

    // Case 2: first time — fetch GPS
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever ||
          perm == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _picked = LatLng(pos.latitude, pos.longitude);

      if (mounted) setState(() => _loadingLocation = false);

      await _resolveAddress(_picked!);
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        setState(() {
          // Fallback only after GPS failure
          _picked = const LatLng(11.5564, 104.9282);
          _loadingLocation = false;
          _locationError = true;
        });
        await _resolveAddress(_picked!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Show loading state while fetching location
    if (_loadingLocation || _picked == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(child: Column(mainAxisSize: MainAxisSize.min)),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: _picked!, zoom: 16),
              onMapCreated: (c) {
                _mapCtrl = c;
              },
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              onCameraMove: (pos) => setState(() => _picked = pos.target),
              onCameraIdle: () => _resolveAddress(_picked!),
            ),
          ),

          // Centre pin
          const Positioned.fill(
            child: IgnorePointer(child: Center(child: _CentrePin())),
          ),

          // Top bar + search
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopSearchBar(
              colors: colors,
              searchCtrl: _searchCtrl,
              searchFocus: _searchFocus,
              searchActive: _searchActive,
              searching: _searching,
              onChanged: _onSearchChanged,
              onClear: () {
                _searchCtrl.clear();
                setState(() => _suggestions = []);
              },
              onBack: () => Navigator.pop(context),
            ),
          ),

          // Suggestions
          if (_suggestions.isNotEmpty ||
              (_searching && _searchCtrl.text.isNotEmpty))
            Positioned(
              top: MediaQuery.of(context).padding.top + 72,
              left: 16,
              right: 16,
              child: _SuggestionsList(
                colors: colors,
                suggestions: _suggestions,
                searching: _searching,
                onSelect: _selectSugg,
              ),
            ),

          // My location FAB
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 250,
            child: GestureDetector(
              onTap: _locating ? null : _goToMyLocation,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.14),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _locating
                    ? Padding(
                        padding: const EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.accent,
                        ),
                      )
                    : Icon(
                        Icons.my_location_rounded,
                        color: colors.accent,
                        size: 22,
                      ),
              ),
            ),
          ),

          // Bottom confirm panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _panelSlide,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  20,
                  16,
                  MediaQuery.of(context).padding.bottom + 20,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 28,
                      offset: const Offset(0, -6),
                    ),
                  ],
                  border: Border(top: BorderSide(color: colors.border)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colors.accentLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: colors.accent,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delivery Location',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colors.text3,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _resolving
                                  ? _ShimmerBar(colors: colors)
                                  : Text(
                                      _resolvedAddress,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colors.text1,
                                        height: 1.4,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                              const SizedBox(height: 4),
                              Text(
                                '${_picked!.latitude.toStringAsFixed(5)}, ${_picked!.longitude.toStringAsFixed(5)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.text3,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: _resolving ? null : _confirm,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: _resolving
                              ? colors.accent.withOpacity(0.5)
                              : colors.accent,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: _resolving
                              ? []
                              : [
                                  BoxShadow(
                                    color: colors.accent.withOpacity(0.38),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                        ),
                        child: Center(
                          child: _resolving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Confirm Location',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HELPER WIDGETS
// ============================================================================

class _CentrePin extends StatelessWidget {
  const _CentrePin();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.location_pin, color: Colors.red, size: 56);
  }
}

class _TopSearchBar extends StatelessWidget {
  final AppColors colors;
  final TextEditingController searchCtrl;
  final FocusNode searchFocus;
  final bool searchActive;
  final bool searching;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onBack;

  const _TopSearchBar({
    required this.colors,
    required this.searchCtrl,
    required this.searchFocus,
    required this.searchActive,
    required this.searching,
    required this.onChanged,
    required this.onClear,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: Icon(Icons.arrow_back_rounded, color: colors.text1),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: searchActive ? colors.accent : colors.border,
                    width: searchActive ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.search_rounded,
                        color: colors.text3,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: searchCtrl,
                        focusNode: searchFocus,
                        onChanged: onChanged,
                        decoration: InputDecoration(
                          hintText: 'Search location…',
                          hintStyle: TextStyle(
                            color: colors.text3,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colors.text1,
                        ),
                      ),
                    ),
                    if (searchCtrl.text.isNotEmpty)
                      GestureDetector(
                        onTap: onClear,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            Icons.clear_rounded,
                            color: colors.text3,
                            size: 18,
                          ),
                        ),
                      ),
                    if (searching)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.accent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionsList extends StatelessWidget {
  final AppColors colors;
  final List<_Sugg> suggestions;
  final bool searching;
  final Function(_Sugg) onSelect;

  const _SuggestionsList({
    required this.colors,
    required this.suggestions,
    required this.searching,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: searching && suggestions.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Searching…',
                    style: TextStyle(fontSize: 13, color: colors.text2),
                  ),
                ],
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: colors.border,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (_, i) {
                final s = suggestions[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Icon(
                    Icons.location_on_outlined,
                    color: colors.text3,
                    size: 20,
                  ),
                  title: Text(
                    s.display,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.text1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => onSelect(s),
                );
              },
            ),
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  final AppColors colors;
  const _ShimmerBar({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.border.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _Sugg {
  final String display;
  final double lat;
  final double lng;

  _Sugg({required this.display, required this.lat, required this.lng});
}

// ─────────────────────────────────────────────
// SMALL MODELS & WIDGETS
// ─────────────────────────────────────────────

class _SuggTile extends StatefulWidget {
  final _Sugg sugg;
  final AppColors colors;
  final VoidCallback onTap;
  const _SuggTile({
    required this.sugg,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_SuggTile> createState() => _SuggTileState();
}

class _SuggTileState extends State<_SuggTile> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => setState(() => _pressed = true),
    onTapUp: (_) {
      setState(() => _pressed = false);
      widget.onTap();
    },
    onTapCancel: () => setState(() => _pressed = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      color: _pressed
          ? widget.colors.accentLight.withOpacity(0.5)
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: widget.colors.accentLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.location_on_rounded,
              size: 17,
              color: widget.colors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.sugg.display.split(',').first,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: widget.colors.text1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.sugg.display,
                  style: TextStyle(fontSize: 11, color: widget.colors.text3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.north_west_rounded, size: 14, color: widget.colors.text3),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// CHECKOUT SHARED WIDGETS
// ─────────────────────────────────────────────

class _Card extends StatelessWidget {
  final AppColors colors;
  final Widget child;
  const _Card({required this.colors, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: colors.cardBg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: colors.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 16,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
}

class _Label extends StatelessWidget {
  final String label;
  final AppColors colors;
  const _Label({required this.label, required this.colors});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: colors.text3,
        letterSpacing: 0.8,
      ),
    ),
  );
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _Chip({required this.label, required this.color, required this.bg});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
    ),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final AppColors colors;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    required this.colors,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.text2,
        ),
      ),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          color: colors.surface2,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: TextStyle(fontSize: 14, color: colors.text1),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colors.text3),
            prefixIcon: Icon(icon, size: 20, color: colors.text3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.accent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            filled: true,
            fillColor: Colors.transparent,
          ),
        ),
      ),
    ],
  );
}

class _ItemRow extends StatelessWidget {
  final OrderItem item;
  final AppColors colors;
  const _ItemRow({required this.item, required this.colors});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: colors.surface2,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.imageUrl.startsWith('http')
                    ? Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.image_outlined, color: colors.text3),
                      )
                    : Icon(Icons.image_outlined, color: colors.text3),
              ),
            ),
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.text1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '\$${item.unitPrice.toStringAsFixed(2)} × ${item.quantity}',
                style: TextStyle(fontSize: 12, color: colors.text3),
              ),
            ],
          ),
        ),
        Text(
          '\$${item.totalPrice.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colors.text1,
          ),
        ),
      ],
    ),
  );
}

class _PaymentTile extends StatelessWidget {
  final PaymentMethod method, selected;
  final AppColors colors;
  final VoidCallback onTap;
  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = method == selected;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: active ? colors.accentLight : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? colors.accent : colors.border,
          width: active ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: active
                        ? colors.accent.withOpacity(0.12)
                        : colors.surface2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    method.icon,
                    size: 20,
                    color: active ? colors.accent : colors.text2,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: active ? colors.accent : colors.text1,
                        ),
                      ),
                      Text(
                        method.desc,
                        style: TextStyle(fontSize: 12, color: colors.text3),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? colors.accent : Colors.transparent,
                    border: Border.all(
                      color: active ? colors.accent : colors.border,
                      width: 2,
                    ),
                  ),
                  child: active
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CouponInput extends StatelessWidget {
  final TextEditingController controller;
  final AppColors colors;
  final bool hasSuccess, hasError, enabled;
  const _CouponInput({
    required this.controller,
    required this.colors,
    required this.hasSuccess,
    required this.hasError,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = hasSuccess
        ? const Color(0xFF16A34A)
        : hasError
        ? const Color(0xFFDC2626)
        : colors.border;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        textCapitalization: TextCapitalization.characters,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: colors.text1,
          letterSpacing: 1,
        ),
        decoration: InputDecoration(
          hintText: 'Enter promo code',
          hintStyle: TextStyle(
            color: colors.text3,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
          prefixIcon: Icon(
            Icons.local_offer_outlined,
            size: 18,
            color: colors.accent,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _ApplyBtn extends StatelessWidget {
  final bool loading, enabled;
  final AppColors colors;
  final VoidCallback onTap;
  const _ApplyBtn({
    required this.loading,
    required this.enabled,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: enabled ? colors.accent : colors.accent.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Apply',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    ),
  );
}

class _CouponChip extends StatelessWidget {
  final String code;
  final double discount;
  final AppColors colors;
  final VoidCallback onRemove;
  const _CouponChip({
    required this.code,
    required this.discount,
    required this.colors,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFDCFCE7),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF16A34A), width: 1.5),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          size: 18,
          color: Color(0xFF16A34A),
        ),
        const SizedBox(width: 8),
        Text(
          code,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF15803D),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '-\$${discount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 13, color: Color(0xFF15803D)),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onRemove,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '✕ Remove',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFDC2626),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final AppColors colors;
  const _PriceRow({
    required this.label,
    required this.value,
    this.valueColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(fontSize: 14, color: colors.text2)),
      Text(
        value,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: valueColor ?? colors.text1,
        ),
      ),
    ],
  );
}

class _DashedLine extends StatelessWidget {
  final Color color;
  const _DashedLine({required this.color});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) {
      const dw = 6.0, gap = 4.0;
      final count = (c.maxWidth / (dw + gap)).floor();
      return Row(
        children: List.generate(
          count,
          (_) => Padding(
            padding: const EdgeInsets.only(right: gap),
            child: Container(width: dw, height: 1, color: color),
          ),
        ),
      );
    },
  );
}
