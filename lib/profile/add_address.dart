import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mart_frontend/models/address_model.dart';

import '../screens/theme/app_theme.dart';
import '../services/api_service.dart';

// ─────────────────────────────────────────────
// ADD / EDIT ADDRESS SCREEN
// ─────────────────────────────────────────────
class _Suggestion {
  final String display;
  final double lat, lng;
  const _Suggestion({
    required this.display,
    required this.lat,
    required this.lng,
  });
}

class MapPickerScreen extends StatefulWidget {
  final LatLng? initialPosition;
  const MapPickerScreen({super.key, this.initialPosition});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapCtrl;
  LatLng _picked = const LatLng(11.5564, 104.9282);

  String _resolvedAddress = 'Locating…';
  bool _resolving = false;

  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searchActive = false;
  bool _searching = false;
  List<_Suggestion> _suggestions = [];
  Timer? _debounce;

  bool _locating = false;

  late final AnimationController _panelCtrl;
  late final Animation<Offset> _panelSlide;

  @override
  void initState() {
    super.initState();
    if (widget.initialPosition != null) _picked = widget.initialPosition!;

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
      if (!_searchFocus.hasFocus) setState(() => _suggestions = []);
    });

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _resolveAddress(_picked),
    );
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

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _fetchSuggestions(query.trim()),
    );
  }

  Future<void> _fetchSuggestions(String query) async {
    setState(() => _searching = true);
    try {
      final locations = await locationFromAddress(query);
      final results = <_Suggestion>[];
      for (final loc in locations.take(5)) {
        final marks = await placemarkFromCoordinates(
          loc.latitude,
          loc.longitude,
        );
        String label;
        if (marks.isNotEmpty) {
          final p = marks.first;
          final parts = [
            p.name,
            p.subLocality,
            p.locality,
            p.country,
          ].where((s) => s != null && s!.isNotEmpty).join(', ');
          label = parts.isNotEmpty
              ? parts
              : '${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}';
        } else {
          label = query;
        }
        results.add(
          _Suggestion(display: label, lat: loc.latitude, lng: loc.longitude),
        );
      }
      if (mounted) setState(() => _suggestions = results);
    } catch (_) {
      if (mounted) setState(() => _suggestions = []);
    }
    if (mounted) setState(() => _searching = false);
  }

  void _selectSuggestion(_Suggestion s) {
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
    HapticFeedback.selectionClick();
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    HapticFeedback.mediumImpact();
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
    HapticFeedback.heavyImpact();
    Navigator.pop(context, {
      'lat': _picked.latitude,
      'lng': _picked.longitude,
      'address': _resolvedAddress,
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // Full-screen map
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: _picked, zoom: 15),
              onMapCreated: (c) => _mapCtrl = c,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              onCameraMove: (pos) => setState(() => _picked = pos.target),
              onCameraIdle: () => _resolveAddress(_picked),
            ),
          ),

          // Fixed centre pin
          const Positioned.fill(
            child: IgnorePointer(child: Center(child: _CentrePin())),
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopBar(
              colors: colors,
              searchCtrl: _searchCtrl,
              searchFocus: _searchFocus,
              searchActive: _searchActive,
              searching: _searching,
              onSearchChanged: _onSearchChanged,
              onClear: () {
                _searchCtrl.clear();
                setState(() => _suggestions = []);
              },
              onBack: () => Navigator.pop(context),
            ),
          ),

          // Suggestions dropdown
          if (_suggestions.isNotEmpty ||
              (_searching && _searchCtrl.text.isNotEmpty))
            Positioned(
              top: MediaQuery.of(context).padding.top + 72,
              left: 16,
              right: 16,
              child: _SuggestionsDropdown(
                colors: colors,
                suggestions: _suggestions,
                searching: _searching,
                onSelect: _selectSuggestion,
              ),
            ),

          // My location FAB
          Positioned(
            right: 16,
            bottom: 210,
            child: _MyLocationFab(
              colors: colors,
              loading: _locating,
              onTap: _goToMyLocation,
            ),
          ),

          // Confirm bottom panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _panelSlide,
              child: _ConfirmPanel(
                colors: colors,
                address: _resolvedAddress,
                resolving: _resolving,
                onConfirm: _resolving ? null : _confirm,
                lat: _picked.latitude,
                lng: _picked.longitude,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 3.  ADD / EDIT ADDRESS SCREEN
// ═══════════════════════════════════════════════════════════════

class AddAddressScreen extends StatefulWidget {
  final AddressModel? existing;
  const AddAddressScreen({super.key, this.existing});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen>
    with SingleTickerProviderStateMixin {
  String _selectedLabel = 'Home';
  // late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  bool _isDefault = false;

  LatLng _pickedLocation = const LatLng(11.5564, 104.9282);
  bool _hasPickedLocation = false;
  bool _isSaving = false;
  bool _saveSuccess = false;

  late AnimationController _successAnim;
  late Animation<double> _successScale;

  bool get _isEdit => widget.existing != null;

  static const _labels = ['Home', 'Work', 'Office', 'Other'];
  static const _labelIcons = {
    'Home': Icons.home_rounded,
    'Work': Icons.work_rounded,
    'Office': Icons.business_rounded,
    'Other': Icons.location_on_rounded,
  };

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final e = widget.existing!;

      _selectedLabel = e.fullName ?? 'Home';

      _addressCtrl = TextEditingController(text: e.address);

      _isDefault = e.isDefault;

      _pickedLocation = LatLng(e.lat, e.lng);

      _hasPickedLocation = true;
    } else {
      _addressCtrl = TextEditingController();
    }
    _successAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = CurvedAnimation(
      parent: _successAnim,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _successAnim.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) =>
            MapPickerScreen(initialPosition: _pickedLocation),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
    if (result == null) return;
    HapticFeedback.lightImpact();
    setState(() {
      _pickedLocation = LatLng(
        result['lat'] as double,
        result['lng'] as double,
      );
      _addressCtrl.text = result['address'] as String;
      _hasPickedLocation = true;
    });
  }

  Future<void> _save() async {
    final address = _addressCtrl.text.trim();

    if (!_hasPickedLocation) {
      _showSnack('Please select a location on the map');
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      // await ApiService().storeAddress(...) or updateAddress(...)
      Map<String, dynamic> data;

      if (_isEdit) {
        data = await ApiService().updateAddress(
          id: widget.existing!.id,
          fullName: _selectedLabel,

          address: address,
          lat: _pickedLocation.latitude,
          lng: _pickedLocation.longitude,
        );
      } else {
        data = await ApiService().storeAddress(
          fullName: _selectedLabel,
          address: address,
          lat: _pickedLocation.latitude,
          lng: _pickedLocation.longitude,
        );
      }
      final result = AddressModel(
        id: _isEdit ? widget.existing!.id : data["address_id"],

        userId: widget.existing?.userId ?? 0,

        fullName: _selectedLabel,

        address: address,

        lat: _pickedLocation.latitude,

        lng: _pickedLocation.longitude,

        isDefault: _isDefault,

        createdAt: widget.existing?.createdAt ?? DateTime.now(),

        updatedAt: DateTime.now(),
      );
      final addressId = _isEdit ? widget.existing!.id : data["address_id"];

      if (_isDefault) {
        await ApiService().setDefaultAddress(addressId);
      }
      setState(() {
        _isSaving = false;
        _saveSuccess = true;
      });
      await _successAnim.forward();
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context, result);
    } catch (e) {
      setState(() => _isSaving = false);
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(colors),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildLabelSection(colors),
                    const SizedBox(height: 14),
                    // _buildPhoneField(colors),
                    const SizedBox(height: 14),
                    _buildMapCard(colors),
                    const SizedBox(height: 14),
                    _buildDefaultToggle(colors),
                  ]),
                ),
              ),
            ],
          ),
          _buildStickyBottom(colors),
          if (_saveSuccess) _buildSuccessOverlay(colors),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppColors colors) {
    return AppBar(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isEdit ? 'Edit Address' : 'Add New Address',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: colors.text1,
            ),
          ),
          Text(
            _isEdit ? 'Update your location' : 'Set a delivery location',
            style: TextStyle(fontSize: 11, color: colors.text2),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: colors.border),
      ),
    );
  }

  Widget _buildLabelSection(AppColors colors) {
    return _SectionCard(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(label: 'Address Label', colors: colors),
          const SizedBox(height: 12),
          Row(
            children: _labels.map((label) {
              final selected = label == _selectedLabel;
              final icon = _labelIcons[label]!;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedLabel = label);
                    HapticFeedback.selectionClick();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    margin: EdgeInsets.only(
                      right: label != _labels.last ? 8 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? colors.accentLight : colors.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? colors.accent : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          icon,
                          size: 20,
                          color: selected ? colors.accent : colors.text2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: selected ? colors.accent : colors.text2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Widget _buildPhoneField(AppColors colors) {
  //   return _SectionCard(
  //     colors: colors,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         _SectionTitle(label: 'Phone Number', colors: colors),
  //         const SizedBox(height: 12),
  //         _PremiumTextField(
  //           controller: _phoneCtrl,
  //           hint: '+855 xx xxx xxx',
  //           prefixIcon: Icons.phone_outlined,
  //           keyboardType: TextInputType.phone,
  //           colors: colors,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildMapCard(AppColors colors) {
    return _SectionCard(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SectionTitle(
                  label: 'Location & Address',
                  colors: colors,
                ),
              ),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.open_in_full_rounded,
                        size: 13,
                        color: colors.accent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _hasPickedLocation ? 'Change' : 'Pick on Map',
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

          // Map preview / placeholder
          GestureDetector(
            onTap: _openMapPicker,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _hasPickedLocation
                  ? SizedBox(
                      height: 140,
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _pickedLocation,
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('pin'),
                                position: _pickedLocation,
                              ),
                            },
                            zoomControlsEnabled: false,
                            scrollGesturesEnabled: false,
                            zoomGesturesEnabled: false,
                            rotateGesturesEnabled: false,
                            tiltGesturesEnabled: false,
                            myLocationButtonEnabled: false,
                            liteModeEnabled: true,
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surface.withOpacity(0.92),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit_location_rounded,
                                    size: 13,
                                    color: colors.accent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Tap to change',
                                    style: TextStyle(
                                      fontSize: 10,
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
                    )
                  : Container(
                      height: 140,
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
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: colors.accent.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_location_alt_rounded,
                                size: 28,
                                color: colors.accent,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Tap to select location',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: colors.accent,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Opens full-screen map with search',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.text3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),

          // Coordinates
          if (_hasPickedLocation) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.gps_fixed_rounded, size: 13, color: colors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_pickedLocation.latitude.toStringAsFixed(5)}, ${_pickedLocation.longitude.toStringAsFixed(5)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.text2,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  Text(
                    'GPS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: colors.text3,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          _SectionTitle(label: 'Address Details', colors: colors),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: colors.surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            child: TextField(
              controller: _addressCtrl,
              maxLines: 3,
              style: TextStyle(fontSize: 14, color: colors.text1),
              decoration: InputDecoration(
                hintText: 'Address auto-fills from map, or type manually',
                hintStyle: TextStyle(color: colors.text3, fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultToggle(AppColors colors) {
    return _SectionCard(
      colors: colors,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.accentLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.star_rounded, size: 20, color: colors.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set as Default',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.text1,
                  ),
                ),
                Text(
                  'Use this address by default',
                  style: TextStyle(fontSize: 12, color: colors.text2),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isDefault,
            activeColor: colors.accent,
            onChanged: (v) {
              setState(() => _isDefault = v);
              HapticFeedback.selectionClick();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottom(AppColors colors) {
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
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
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
        child: GestureDetector(
          onTap: _isSaving ? null : _save,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 54,
            decoration: BoxDecoration(
              color: _isSaving ? colors.accent.withOpacity(0.7) : colors.accent,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: colors.accent.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isEdit
                              ? Icons.save_rounded
                              : Icons.add_location_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isEdit ? 'Save Changes' : 'Save Address',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay(AppColors colors) {
    return Container(
      color: colors.background.withOpacity(0.85),
      child: Center(
        child: ScaleTransition(
          scale: _successScale,
          child: Container(
            width: 180,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 34,
                    color: Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isEdit ? 'Address Updated!' : 'Address Saved!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colors.text1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SHARED SMALL WIDGETS
// ═══════════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final AppColors colors;
  final Widget child;
  const _SectionCard({required this.colors, required this.child});

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
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
}

class _SectionTitle extends StatelessWidget {
  final String label;
  final AppColors colors;
  const _SectionTitle({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) => Text(
    label.toUpperCase(),
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: colors.text3,
      letterSpacing: 0.8,
    ),
  );
}

class _PremiumTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final AppColors colors;

  const _PremiumTextField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: colors.surface2,
      borderRadius: BorderRadius.circular(14),
    ),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14, color: colors.text1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colors.text3),
        prefixIcon: Icon(prefixIcon, size: 20, color: colors.text3),
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
  );
}

// ── Map-picker sub-widgets ──────────────────

class _CentrePin extends StatelessWidget {
  const _CentrePin();

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 20,
        height: 6,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.18),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      const SizedBox(height: 2),
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.45),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.location_on_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
    ],
  );
}

class _TopBar extends StatelessWidget {
  final AppColors colors;
  final TextEditingController searchCtrl;
  final FocusNode searchFocus;
  final bool searchActive, searching;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClear, onBack;

  const _TopBar({
    required this.colors,
    required this.searchCtrl,
    required this.searchFocus,
    required this.searchActive,
    required this.searching,
    required this.onSearchChanged,
    required this.onClear,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Row(
          children: [
            _MapIconBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              colors: colors,
              onTap: onBack,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: searchActive ? colors.accent : colors.border,
                    width: searchActive ? 1.8 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    searching
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.accent,
                            ),
                          )
                        : Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: searchActive ? colors.accent : colors.text3,
                          ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchCtrl,
                        focusNode: searchFocus,
                        onChanged: onSearchChanged,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.text1,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search address or place…',
                          hintStyle: TextStyle(
                            color: colors.text3,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                    if (searchCtrl.text.isNotEmpty)
                      GestureDetector(
                        onTap: onClear,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: colors.text3,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
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

class _SuggestionsDropdown extends StatelessWidget {
  final AppColors colors;
  final List<_Suggestion> suggestions;
  final bool searching;
  final ValueChanged<_Suggestion> onSelect;

  const _SuggestionsDropdown({
    required this.colors,
    required this.suggestions,
    required this.searching,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (searching)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
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
            else if (suggestions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 18,
                      color: colors.text3,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'No results found',
                      style: TextStyle(fontSize: 13, color: colors.text3),
                    ),
                  ],
                ),
              )
            else
              ...suggestions.asMap().entries.map(
                (e) => Column(
                  children: [
                    _SuggestionTile(
                      suggestion: e.value,
                      colors: colors,
                      onTap: () => onSelect(e.value),
                    ),
                    if (e.key < suggestions.length - 1)
                      Divider(height: 1, indent: 52, color: colors.border),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatefulWidget {
  final _Suggestion suggestion;
  final AppColors colors;
  final VoidCallback onTap;
  const _SuggestionTile({
    required this.suggestion,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_SuggestionTile> createState() => _SuggestionTileState();
}

class _SuggestionTileState extends State<_SuggestionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                    widget.suggestion.display.split(',').first,
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
                    widget.suggestion.display,
                    style: TextStyle(fontSize: 11, color: widget.colors.text3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.north_west_rounded,
              size: 14,
              color: widget.colors.text3,
            ),
          ],
        ),
      ),
    );
  }
}

class _MyLocationFab extends StatelessWidget {
  final AppColors colors;
  final bool loading;
  final VoidCallback onTap;
  const _MyLocationFab({
    required this.colors,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: colors.border),
      ),
      child: loading
          ? Padding(
              padding: const EdgeInsets.all(14),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.accent,
              ),
            )
          : Icon(Icons.my_location_rounded, color: colors.accent, size: 22),
    ),
  );
}

class _ConfirmPanel extends StatelessWidget {
  final AppColors colors;
  final String address;
  final bool resolving;
  final VoidCallback? onConfirm;
  final double lat, lng;

  const _ConfirmPanel({
    required this.colors,
    required this.address,
    required this.resolving,
    required this.onConfirm,
    required this.lat,
    required this.lng,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        20,
        16,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                    resolving
                        ? _ShimmerText(colors: colors)
                        : Text(
                            address,
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
                      '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
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
            onTap: onConfirm,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                color: onConfirm == null
                    ? colors.accent.withOpacity(0.5)
                    : colors.accent,
                borderRadius: BorderRadius.circular(18),
                boxShadow: onConfirm != null
                    ? [
                        BoxShadow(
                          color: colors.accent.withOpacity(0.38),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: resolving
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
    );
  }
}

class _MapIconBtn extends StatelessWidget {
  final IconData icon;
  final AppColors colors;
  final VoidCallback onTap;
  const _MapIconBtn({
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, size: 18, color: colors.text1),
    ),
  );
}

class _ShimmerText extends StatefulWidget {
  final AppColors colors;
  const _ShimmerText({required this.colors});

  @override
  State<_ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<_ShimmerText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_bar(200), const SizedBox(height: 6), _bar(140)],
      ),
    );
  }

  Widget _bar(double width) => Container(
    width: width,
    height: 12,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      gradient: LinearGradient(
        begin: Alignment(_anim.value - 1, 0),
        end: Alignment(_anim.value + 1, 0),
        colors: [
          widget.colors.surface2,
          widget.colors.border,
          widget.colors.surface2,
        ],
      ),
    ),
  );
}

// ── Shimmer card for loading state ──────────

class _ShimmerCard extends StatefulWidget {
  final AppColors colors;
  final int delay;
  const _ShimmerCard({required this.colors, required this.delay});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final gradient = LinearGradient(
          begin: Alignment(_anim.value - 1, 0),
          end: Alignment(_anim.value + 1, 0),
          colors: [
            widget.colors.surface2,
            widget.colors.border,
            widget.colors.surface2,
          ],
        );
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.colors.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 110,
                    height: 14,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 12,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 180,
                height: 12,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
