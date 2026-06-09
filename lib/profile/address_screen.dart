import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mart_frontend/models/address_model.dart';
import 'package:mart_frontend/profile/add_address.dart';
import 'package:mart_frontend/screens/theme/app_theme.dart';
import 'package:mart_frontend/services/api_service.dart';

// ─────────────────────────────────────────────
// MY ADDRESSES SCREEN
// ─────────────────────────────────────────────

class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({super.key});

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────
  List<AddressModel> _addresses = [];
  bool _loading = true;
  bool _refreshing = false;
  String? _error;

  // Track which card is swiped open
  int? _swipedIndex;

  // Per-card delete animation controllers
  final Map<int, AnimationController> _deleteAnims = {};

  static const _labelIcons = {
    'Home': Icons.home_rounded,
    'Work': Icons.work_rounded,
    'Office': Icons.business_rounded,
    'Other': Icons.location_on_rounded,
  };

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    for (final c in _deleteAnims.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Data ───────────────────────────────────
  Future<void> _loadAddresses({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final list = await ApiService().myAddresses();
      if (mounted) {
        setState(() {
          _addresses = list;
          _loading = false;
          _refreshing = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
          _refreshing = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _refreshing = true);
    await _loadAddresses(silent: true);
  }

  Future<void> _deleteAddress(int index) async {
    final addr = _addresses[index];
    HapticFeedback.mediumImpact();

    // Animate row out
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    setState(() => _deleteAnims[addr.id] = ctrl);

    try {
      await ApiService().deleteAddress(addr.id);
      await ctrl.forward();
      if (mounted) {
        setState(() {
          _addresses.removeAt(index);
          _deleteAnims.remove(addr.id);
          _swipedIndex = null;
        });
      }
    } catch (e) {
      ctrl.dispose();
      _deleteAnims.remove(addr.id);
      if (mounted) {
        _showSnack(e.toString().replaceFirst('Exception: ', ''), isError: true);
      }
    }
  }

  Future<void> _setDefault(int index) async {
    final addr = _addresses[index];
    HapticFeedback.selectionClick();
    try {
      await ApiService().setDefaultAddress(addr.id);
      if (mounted) {
        setState(() {
          for (int i = 0; i < _addresses.length; i++) {
            _addresses[i] = AddressModel(
              id: _addresses[i].id,
              userId: _addresses[i].userId,
              fullName: _addresses[i].fullName,

              address: _addresses[i].address,
              lat: _addresses[i].lat,
              lng: _addresses[i].lng,
              isDefault: i == index,
              createdAt: _addresses[i].createdAt,
              updatedAt: _addresses[i].updatedAt,
            );
          }
          _swipedIndex = null;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnack(e.toString().replaceFirst('Exception: ', ''), isError: true);
      }
    }
  }

  void _openAdd() async {
    final result = await Navigator.push<AddressModel>(
      context,
      MaterialPageRoute(builder: (_) => AddAddressScreen()),
    );
    if (result != null && mounted) {
      setState(() => _addresses.insert(0, result));
    }
    if (result != null) {
      await _loadAddresses();
    }
  }

  void _openEdit(int index) async {
    final result = await Navigator.push<AddressModel>(
      context,
      MaterialPageRoute(
        builder: (_) => AddAddressScreen(existing: _addresses[index]),
      ),
    );
    if (result != null && mounted) {
      setState(() => _addresses[index] = result);
    }
    if (result != null) {
      await _loadAddresses();
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
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

  // ── Build ──────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(colors),
      floatingActionButton: _buildFAB(colors),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _loading ? _buildLoading(colors) : _buildBody(colors),
    );
  }

  PreferredSizeWidget _buildAppBar(AppColors colors) {
    return AppBar(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
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
            'My Addresses',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: colors.text1,
            ),
          ),
          Text(
            'Manage your delivery locations',
            style: TextStyle(
              fontSize: 11,
              color: colors.text2,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      // actions: [
      //   Padding(
      //     padding: const EdgeInsets.only(right: 12),
      //     child: GestureDetector(
      //       onTap: _openAdd,
      //       child: Container(
      //         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      //         decoration: BoxDecoration(
      //           color: colors.accent,
      //           borderRadius: BorderRadius.circular(12),
      //         ),
      //         child: Row(
      //           mainAxisSize: MainAxisSize.min,
      //           children: [
      //             const Icon(Icons.add_rounded, size: 16, color: Colors.white),
      //             const SizedBox(width: 4),
      //             const Text(
      //               'Add',
      //               style: TextStyle(
      //                 fontSize: 12,
      //                 fontWeight: FontWeight.w700,
      //                 color: Colors.white,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ),
      // ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: colors.border),
      ),
    );
  }

  // ── FAB ────────────────────────────────────
  Widget _buildFAB(AppColors colors) {
    return FloatingActionButton.extended(
      onPressed: _openAdd,
      backgroundColor: colors.accent,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      icon: const Icon(Icons.add_location_rounded, color: Colors.white),
      label: const Text(
        '+ Add Address',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  // ── Loading ────────────────────────────────
  Widget _buildLoading(AppColors colors) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: 3,
      itemBuilder: (_, i) => _buildShimmerCard(colors, i),
    );
  }

  Widget _buildShimmerCard(AppColors colors, int i) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 0.9),
      duration: Duration(milliseconds: 800 + i * 150),
      curve: Curves.easeInOut,
      builder: (_, v, __) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.cardBg.withOpacity(v),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
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
                      color: colors.surface2.withOpacity(v),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colors.surface2.withOpacity(v),
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
                  color: colors.surface2.withOpacity(v),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 180,
                height: 12,
                decoration: BoxDecoration(
                  color: colors.surface2.withOpacity(v),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Body ───────────────────────────────────
  Widget _buildBody(AppColors colors) {
    if (_error != null) return _buildError(colors);
    if (_addresses.isEmpty) return _buildEmpty(colors);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: colors.accent,
      backgroundColor: colors.surface,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Pull-to-refresh hint banner
          // SliverToBoxAdapter(child: _buildRefreshHint(colors)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildAddressCard(colors, index),
                childCount: _addresses.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildRefreshHint(AppColors colors) {
  //   return Container(
  //     margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
  //     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  //     decoration: BoxDecoration(
  //       color: colors.accentLight,
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: colors.accent.withOpacity(0.2)),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Icon(Icons.refresh_rounded, size: 14, color: colors.accent),
  //         const SizedBox(width: 6),
  //         Text(
  //           'Pull to refresh your addresses',
  //           style: TextStyle(
  //             fontSize: 12,
  //             fontWeight: FontWeight.w600,
  //             color: colors.accent,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ── Address card with swipe ─────────────────
  Widget _buildAddressCard(AppColors colors, int index) {
    final addr = _addresses[index];
    final isDefault = addr.isDefault;
    final isSwiped = _swipedIndex == index;
    final deleteAnim = _deleteAnims[addr.id];
    final icon =
        _labelIcons[addr.fullName ?? 'Other'] ?? Icons.location_on_rounded;

    Widget card = GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < -300) {
          // swipe left → show delete
          setState(() => _swipedIndex = index);
          HapticFeedback.selectionClick();
        } else if (details.primaryVelocity! > 300) {
          // swipe right → set default
          if (!isDefault) _setDefault(index);
          setState(() => _swipedIndex = null);
        }
      },
      onTap: () {
        if (isSwiped) {
          setState(() => _swipedIndex = null);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDefault ? colors.accent.withOpacity(0.5) : colors.border,
            width: isDefault ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDefault
                  ? colors.accent.withOpacity(0.08)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header row ──
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDefault
                              ? colors.accent.withOpacity(0.12)
                              : colors.surface2,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          size: 18,
                          color: isDefault ? colors.accent : colors.text2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              addr.fullName ?? 'Address',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: colors.text1,
                              ),
                            ),
                            if (isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.accent.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: colors.accent.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 10,
                                      color: colors.accent,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      'DEFAULT',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: colors.accent,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ── Phone ──
                  // Row(
                  //   children: [
                  //     Icon(Icons.phone_outlined, size: 13, color: colors.text3),
                  //     const SizedBox(width: 5),
                  //     Text(
                  //       addr.phone,
                  //       style: TextStyle(
                  //         fontSize: 13,
                  //         color: colors.text2,
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 4),

                  // ── Address ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          addr.address,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.text2,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Action buttons ──
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.border)),
              ),
              child: isSwiped
                  ? _buildSwipeActions(colors, index, isDefault)
                  : _buildNormalActions(colors, index),
            ),
          ],
        ),
      ),
    );

    // Wrap with delete animation if animating out
    if (deleteAnim != null) {
      return AnimatedBuilder(
        animation: deleteAnim,
        builder: (_, child) => SizeTransition(
          sizeFactor: Tween<double>(begin: 1, end: 0).animate(
            CurvedAnimation(parent: deleteAnim, curve: Curves.easeInCubic),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0).animate(deleteAnim),
            child: child,
          ),
        ),
        child: card,
      );
    }

    return card;
  }

  Widget _buildNormalActions(AppColors colors, int index) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _openEdit(index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: colors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_rounded, size: 14, color: colors.text2),
                  const SizedBox(width: 6),
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.text2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _confirmDelete(index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.delete_outline_rounded,
                    size: 14,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeActions(AppColors colors, int index, bool isDefault) {
    return Column(
      children: [
        // Swipe hint text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '← swipe left to delete',
                style: TextStyle(fontSize: 10, color: colors.text3),
              ),
              Text(
                'swipe right to set default →',
                style: TextStyle(fontSize: 10, color: colors.text3),
              ),
            ],
          ),
        ),
        Row(
          children: [
            if (!isDefault)
              Expanded(
                child: GestureDetector(
                  onTap: () => _setDefault(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: colors.accentLight,
                      border: Border(right: BorderSide(color: colors.border)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: colors.accent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Set Default',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: colors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: GestureDetector(
                onTap: () => _confirmDelete(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  color: const Color(0xFFEF4444).withOpacity(0.08),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_rounded,
                        size: 14,
                        color: Color(0xFFEF4444),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmDelete(int index) async {
    final colors = context.colors;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 28,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Delete Address?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.text1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This address will be permanently removed.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: colors.text2),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.surface2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.border),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colors.text1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      await _deleteAddress(index);
    } else {
      setState(() => _swipedIndex = null);
    }
  }

  // ── Empty state ────────────────────────────
  Widget _buildEmpty(AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.accentLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                size: 36,
                color: colors.accent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Addresses Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: colors.text1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a delivery address to get started',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: colors.text2),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _openAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colors.accent.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_location_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Add Address',
                      style: TextStyle(
                        fontSize: 15,
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
    );
  }

  // ── Error state ────────────────────────────
  Widget _buildError(AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 36,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to Load',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: colors.text1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.text2),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _loadAddresses,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 15,
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
    );
  }
}
