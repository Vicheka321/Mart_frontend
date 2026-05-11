import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../services/api_service.dart';
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
  String paymentMethod = "khqr";
  bool _isPlacingOrder = false; // ← prevents duplicate submissions

  @override
  void initState() {
    super.initState();
    _getLocation();
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
          : Column(
              children: [
                /// 🗺️ MAP
                SizedBox(
                  height: 250,
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

                    /// 👉 tap to select location
                    onTap: (pos) {
                      setState(() {
                        currentPosition = pos;
                      });
                    },
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        /// 📞 PHONE
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: "Phone Number",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// 💳 PAYMENT
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Payment Method",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                        RadioListTile(
                          value: "cash",
                          groupValue: paymentMethod,
                          onChanged: (v) {
                            setState(() {
                              paymentMethod = v.toString();
                            });
                          },
                          title: const Text("Cash on Delivery"),
                        ),

                        RadioListTile(
                          value: "aba",
                          groupValue: paymentMethod,
                          onChanged: (v) {
                            setState(() {
                              paymentMethod = v.toString();
                            });
                          },
                          title: const Text("ABA Pay"),
                        ),
                        RadioListTile(
                          value: "khqr",
                          groupValue: paymentMethod,
                          onChanged: (v) {
                            setState(() {
                              paymentMethod = v.toString();
                            });
                          },
                          title: const Text("KHQR"),
                        ),

                        const Spacer(),

                        /// 🛒 CHECKOUT
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isPlacingOrder ? null : _placeOrder,
                            child: _isPlacingOrder
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text("Place Order"),
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

  // Future<void> _placeOrder() async {
  //   if (currentPosition == null || phoneController.text.isEmpty) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Fill all fields")));
  //     return;
  //   }

  //   final lat = currentPosition!.latitude;
  //   final lng = currentPosition!.longitude;

  //   final address = await getAddressFromLatLng(lat, lng);

  //   print("LAT: $lat");
  //   print("LNG: $lng");
  //   print("PHONE: ${phoneController.text}");
  //   print("PAYMENT: $paymentMethod");
  //   print("ADDRESS: $address");
  // }

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return; // double-tap guard

    setState(() => _isPlacingOrder = true);

    try {
      if (currentPosition == null || phoneController.text.isEmpty) {
        setState(() => _isPlacingOrder = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Fill all fields")));
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
