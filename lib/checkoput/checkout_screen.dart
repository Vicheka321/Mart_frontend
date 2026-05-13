import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../providers/cart_provider.dart';
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
      appBar: AppBar(title: const Text("Checkout")),
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
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
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                "Place Order",
                                style: TextStyle(
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
            const Text(
              "Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Name field
            TextField(
              controller: userNameController,
              decoration: InputDecoration(
                labelText: "Name",
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
                labelText: "Phone Number",
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
            const Text(
              "Address",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Tap on map to change location",
                style: TextStyle(fontSize: 12, color: Colors.grey),
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
                  const Text(
                    "Order Summary",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Center(child: CircularProgressIndicator()),
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
                  "Order Summary (${cart.items.length} items)",
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
                    const Text("Subtotal"),
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
                    const Text(
                      "Total",
                      style: TextStyle(
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
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Payment method",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RadioListTile(
              value: "cash",
              groupValue: paymentMethod,
              onChanged: (v) {
                setState(() {
                  paymentMethod = v.toString();
                });
              },
              title: const Text("pay by cash"),
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile(
              value: "aba",
              groupValue: paymentMethod,
              onChanged: (v) {
                setState(() {
                  paymentMethod = v.toString();
                });
              },
              title: const Text("pay by ABA"),
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile(
              value: "khqr",
              groupValue: paymentMethod,
              onChanged: (v) {
                setState(() {
                  paymentMethod = v.toString();
                });
              },
              title: const Text("pay by KHQR"),
              contentPadding: EdgeInsets.zero,
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
        ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
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

      /// ✅ PLACE ORDER
      final orderRes = await ApiService().placeOrder(
        addressId: addressId,
        paymentMethod: paymentMethod,
      );

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
      return "Unknown location";
    }
  }
}
