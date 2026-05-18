import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/address_history_service.dart';
import '../providers/cart_provider.dart';
import '../screens/theme/app_theme.dart';
import '../widgets/skeleton_loader.dart';
import 'OrderSuccessScreen.dart';
import 'khqr_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  GoogleMapController? mapController;
  LatLng? currentPosition;

  final phoneController = TextEditingController();
  final userNameController = TextEditingController();
  String paymentMethod = "khqr";
  bool _isPlacingOrder = false; // ← prevents duplicate submissions

  @override
  void initState() {
    super.initState();
    _getLocation();
    _loadUserProfile();
  }

  /// 👤 Load user profile from API
  Future<void> _loadUserProfile() async {
    try {
      final profile = await ApiService().fetchMyProfile();
      if (mounted) {
        setState(() {
          userNameController.text = profile.name;
        });
      }
    } catch (e) {
      print("Error loading profile: $e");
    }
  }

  /// 📍 Get current location
  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    final pos = await Geolocator.getCurrentPosition();

    setState(() {
      currentPosition = LatLng(pos.latitude, pos.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("checkout".tr)),
      body: currentPosition == null
          ? const Center(
              child: SkeletonBox(
                width: 180,
                height: 16,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ========== 📋 DETAILS SECTION ==========
                    _buildDetailsSection(),
                    const SizedBox(height: 20),

                    /// ========== 📍 ADDRESS SECTION ==========
                    _buildAddressSection(),
                    const SizedBox(height: 20),

                    /// ========== 🛒 ORDER SUMMARY SECTION ==========
                    _buildOrderSummarySection(),
                    const SizedBox(height: 20),

                    /// ========== 💳 PAYMENT METHOD SECTION ==========
                    _buildPaymentMethodSection(),
                    const SizedBox(height: 24),

                    /// ========== ✅ PLACE ORDER BUTTON ==========
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isPlacingOrder ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: _isPlacingOrder
                            ? const SkeletonBox(
                                width: 86,
                                height: 12,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(6),
                                ),
                                baseColor: Colors.white54,
                                highlightColor: Colors.white,
                              )
                            : Text(
                                "place_order".tr,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  /// ========== DETAILS SECTION WIDGET ==========
  Widget _buildDetailsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "details".tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Name field
            TextField(
              controller: userNameController,
              decoration: InputDecoration(
                labelText: "full_name".tr,
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Phone field
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "phone".tr,
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ========== ADDRESS SECTION WIDGET ==========
  Widget _buildAddressSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "address".tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Google Map
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: currentPosition!,
                    zoom: 15,
                  ),
                  onMapCreated: (c) => mapController = c,
                  markers: {
                    Marker(
                      markerId: const MarkerId("me"),
                      position: currentPosition!,
                    ),
                  },
                  onTap: (pos) {
                    setState(() {
                      currentPosition = pos;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "tap_map_change_location".tr,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ========== ORDER SUMMARY SECTION WIDGET ==========
  Widget _buildOrderSummarySection() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        final cart = cartProvider.cart;
        if (cart == null) {
          return Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "order_summary".tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SkeletonBox(
                    width: 150,
                    height: 14,
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${"order_summary".tr} (${cart.items.length} items)",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Items list
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          // Item image thumbnail
                          if (item.images.isNotEmpty)
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                image: DecorationImage(
                                  image: NetworkImage(item.images.first),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.grey[300],
                              ),
                              child: const Icon(Icons.image),
                            ),
                          const SizedBox(width: 12),
                          // Item details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Qty: ${item.qty}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Price
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "\$${item.price}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "\$${item.totalPrice.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                // Subtotal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("subtotal".tr),
                    Text(
                      "\$${cart.totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "total".tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "\$${cart.totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ========== PAYMENT METHOD SECTION WIDGET ==========
  Widget _buildPaymentMethodSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "payment_method".tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            value: "cash",
            label: "pay_by_cash".tr,
            icon: Icons.money,
          ),
          _buildPaymentOption(
            value: "aba",
            label: "pay_by_aba".tr,
            icon: Icons.account_balance,
          ),
          _buildPaymentOption(
            value: "khqr",
            label: "pay_by_khqr".tr,
            icon: Icons.qr_code,
          ),
          // Previous implementation using RadioListTile options:
          // RadioListTile(
          //   value: "cash",
          //   groupValue: paymentMethod,
          //   onChanged: (v) {
          //     setState(() {
          //       paymentMethod = v.toString();
          //     });
          //   },
          //   title: const Text("pay by cash"),
          //   contentPadding: EdgeInsets.zero,
          // ),
          // RadioListTile(
          //   value: "aba",
          //   groupValue: paymentMethod,
          //   onChanged: (v) {
          //     setState(() {
          //       paymentMethod = v.toString();
          //     });
          //   },
          //   title: const Text("pay by ABA"),
          //   contentPadding: EdgeInsets.zero,
          // ),
          // RadioListTile(
          //   value: "khqr",
          //   groupValue: paymentMethod,
          //   onChanged: (v) {
          //     setState(() {
          //       paymentMethod = v.toString();
          //     });
          //   },
          //   title: const Text("pay by KHQR"),
          //   contentPadding: EdgeInsets.zero,
          // ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final bool selected = paymentMethod == value;
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        setState(() {
          paymentMethod = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? colors.surface2 : colors.cardBg)
              : colors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.green : colors.border,
            width: selected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.transparent
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.green : colors.text2),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: selected ? colors.text1 : colors.text2,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.green : colors.border,
                  width: 2,
                ),
                color: selected ? Colors.green : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return; // double-tap guard

    setState(() => _isPlacingOrder = true);

    try {
      if (currentPosition == null ||
          phoneController.text.isEmpty ||
          userNameController.text.isEmpty) {
        setState(() => _isPlacingOrder = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("please_fill_all_fields".tr)));
        return;
      }

      final lat = currentPosition!.latitude;
      final lng = currentPosition!.longitude;

      final address = await getAddressFromLatLng(lat, lng);

      /// ✅ SAVE ADDRESS
      final addressRes = await ApiService().storeAddress(
        phone: phoneController.text,
        address: address,
        lat: lat,
        lng: lng,
      );

      final addressId = addressRes["address_id"];

      await AddressHistoryService().saveAddress(
        phone: phoneController.text,
        address: address,
        lat: lat,
        lng: lng,
      );

      /// ✅ PLACE ORDER
      final orderRes = await ApiService().placeOrder(
        addressId: addressId,
        paymentMethod: paymentMethod,
      );

      // Refresh cart state after a successful checkout so the UI updates immediately
      await context.read<CartProvider>().fetchCart();

      final orderId = orderRes["data"]["order_id"];

      /// ✅ CASH
      if (paymentMethod == "cash") {
        if (!mounted) return;
        setState(() => _isPlacingOrder = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
        );
        return;
      }

      /// ✅ KHQR
      if (paymentMethod == "khqr") {
        final qrRes = await ApiService().generateQR(orderId);

        // Use the amount from placeOrder response — backend returns it
        // as a num (e.g. 2.50) directly in data["amount"].
        final orderTotal = orderRes["data"]["amount"];
        final displayAmount = orderTotal is String
            ? orderTotal
            : (orderTotal as num).toStringAsFixed(2);

        if (!mounted) return;
        setState(() => _isPlacingOrder = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KhqrScreen(
              qrUrl: qrRes["qr_url"],
              amount: displayAmount,
              md5: qrRes["md5"],
            ),
          ),
        );
        return;
      }

      // Any other payment method — reset flag
      if (mounted) setState(() => _isPlacingOrder = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      Placemark place = placemarks.first;

      return "${place.name}, ${place.locality}";
    } catch (e) {
      return "unknown_location".tr;
    }
  }
}
