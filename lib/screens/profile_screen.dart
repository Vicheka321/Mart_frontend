import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mart_frontend/screens/home_screen.dart';
import 'package:mart_frontend/screens/main/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════
// ENTRY POINT
// ═══════════════════════════════════════════════════════════════

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme(bool isDark) {
    setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile',
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF6F5F3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF111111),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E0E0E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B7CF6),
          brightness: Brightness.dark,
        ),
      ),
      home: const ProfileScreen(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// THEME HELPERS
// ═══════════════════════════════════════════════════════════════

extension ThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get bg => isDark ? const Color(0xFF0E0E0E) : const Color(0xFFF6F5F3);
  Color get card => isDark ? const Color(0xFF1A1A1A) : Colors.white;
  Color get text1 => isDark ? const Color(0xFFF0F0F0) : const Color(0xFF111111);
  Color get text2 => isDark ? const Color(0xFF888888) : const Color(0xFF777777);
  Color get text3 => isDark ? const Color(0xFF444444) : const Color(0xFFEEEEEE);
  Color get border =>
      isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0);
  Color get accent =>
      isDark ? const Color(0xFF8B7CF6) : const Color(0xFF111111);
  Color get accentBg =>
      isDark ? const Color(0xFF2A2340) : const Color(0xFFF3F3F3);
}

// ═══════════════════════════════════════════════════════════════
// PROFILE SCREEN
// ═══════════════════════════════════════════════════════════════

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _notificationsOn = true;
  bool _darkMode = false;
  String _selectedLanguage = 'English';
  bool _twoFAEnabled = false;

  late AnimationController _headerAnim;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutCubic));
    _headerAnim.forward();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  // ── Logout ───────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  // ── Stats data ───────────────────────────────────────────────
  static const _stats = [
    {'icon': Icons.shopping_bag_outlined, 'value': '24', 'label': 'Orders'},
    {'icon': Icons.favorite_border_rounded, 'value': '18', 'label': 'Wishlist'},
    {'icon': Icons.star_outline_rounded, 'value': '1,240', 'label': 'Points'},
    {'icon': Icons.local_offer_outlined, 'value': '6', 'label': 'Coupons'},
  ];

  @override
  Widget build(BuildContext context) {
    final c = context;
    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar ─────────────────────────────────────
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor: c.bg,
            elevation: 0,
            title: Text(
              'My Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: c.text1,
                letterSpacing: -0.3,
              ),
            ),
            actions: [
              _IconBtn(
                icon: Icons.edit_outlined,
                onTap: () => _showEditProfile(context),
              ),
              const SizedBox(width: 8),
              _IconBtn(icon: Icons.qr_code_rounded, onTap: () {}),
              const SizedBox(width: 16),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // ── 1. Profile Header ─────────────────────────
                FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: _ProfileHeader(stats: _stats),
                  ),
                ),

                const SizedBox(height: 20),

                // ── 2. My Account ─────────────────────────────
                _SectionLabel(label: 'My Account'),
                _MenuGroup(
                  items: [
                    _MenuItem(
                      icon: Icons.shopping_bag_outlined,
                      iconBg: const Color(0xFFDBEAFE),
                      iconColor: const Color(0xFF3B82F6),
                      title: 'My Orders',
                      subtitle: '24 total orders',
                      trailing: _badge('3'),
                      onTap: () => _navigate(context, _OrdersPage()),
                    ),
                    _MenuItem(
                      icon: Icons.favorite_border_rounded,
                      iconBg: const Color(0xFFFFE4E6),
                      iconColor: const Color(0xFFF43F5E),
                      title: 'Wishlist',
                      subtitle: '18 saved items',
                      onTap: () => _navigate(context, _WishlistPage()),
                    ),
                    _MenuItem(
                      icon: Icons.location_on_outlined,
                      iconBg: const Color(0xFFD1FAE5),
                      iconColor: const Color(0xFF10B981),
                      title: 'Addresses',
                      subtitle: '2 saved addresses',
                      onTap: () => _navigate(context, _AddressPage()),
                    ),
                    _MenuItem(
                      icon: Icons.credit_card_rounded,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Payment Methods',
                      subtitle: 'Visa, Cash on delivery',
                      onTap: () => _navigate(context, _PaymentPage()),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── 3. Preferences ────────────────────────────
                _SectionLabel(label: 'Preferences'),
                _MenuGroup(
                  items: [
                    _MenuItem(
                      icon: _darkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      iconBg: _darkMode
                          ? const Color(0xFF2A2340)
                          : const Color(0xFFFEF3C7),
                      iconColor: _darkMode
                          ? const Color(0xFF8B7CF6)
                          : const Color(0xFFF59E0B),
                      title: 'Dark Mode',
                      subtitle: _darkMode ? 'Enabled' : 'Disabled',
                      customTrailing: Switch.adaptive(
                        value: _darkMode,
                        activeColor: const Color(0xFF8B7CF6),
                        onChanged: (v) {
                          setState(() => _darkMode = v);
                          MyApp.of(context)?.toggleTheme(v);
                          HapticFeedback.selectionClick();
                        },
                      ),
                      onTap: null,
                    ),
                    _MenuItem(
                      icon: _notificationsOn
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_off_outlined,
                      iconBg: _notificationsOn
                          ? const Color(0xFFFFE4E6)
                          : const Color(0xFFF3F4F6),
                      iconColor: _notificationsOn
                          ? const Color(0xFFF43F5E)
                          : const Color(0xFF9CA3AF),
                      title: 'Notifications',
                      subtitle: _notificationsOn
                          ? 'Push & email on'
                          : 'All off',
                      customTrailing: Switch.adaptive(
                        value: _notificationsOn,
                        activeColor: const Color(0xFFF43F5E),
                        onChanged: (v) {
                          setState(() => _notificationsOn = v);
                          HapticFeedback.selectionClick();
                        },
                      ),
                      onTap: null,
                    ),
                    _MenuItem(
                      icon: Icons.language_rounded,
                      iconBg: const Color(0xFFDBEAFE),
                      iconColor: const Color(0xFF3B82F6),
                      title: 'Language',
                      subtitle: _selectedLanguage,
                      onTap: () => _showLanguagePicker(context),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── 4. Security ───────────────────────────────
                _SectionLabel(label: 'Security'),
                _MenuGroup(
                  items: [
                    _MenuItem(
                      icon: Icons.lock_outline_rounded,
                      iconBg: const Color(0xFFEDE9FE),
                      iconColor: const Color(0xFF8B5CF6),
                      title: 'Change Password',
                      subtitle: 'Last changed 30 days ago',
                      onTap: () => _navigate(context, _ChangePasswordPage()),
                    ),
                    _MenuItem(
                      icon: Icons.verified_user_outlined,
                      iconBg: _twoFAEnabled
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFF3F4F6),
                      iconColor: _twoFAEnabled
                          ? const Color(0xFF10B981)
                          : const Color(0xFF9CA3AF),
                      title: '2-Factor Authentication',
                      subtitle: _twoFAEnabled ? '✓ Enabled' : 'Tap to enable',
                      customTrailing: Switch.adaptive(
                        value: _twoFAEnabled,
                        activeColor: const Color(0xFF10B981),
                        onChanged: (v) {
                          setState(() => _twoFAEnabled = v);
                          HapticFeedback.mediumImpact();
                          if (v) _show2FASnack(context);
                        },
                      ),
                      onTap: null,
                    ),
                    _MenuItem(
                      icon: Icons.shield_outlined,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Privacy Settings',
                      subtitle: 'Data & permissions',
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── 5. Support ────────────────────────────────
                _SectionLabel(label: 'Support'),
                _MenuGroup(
                  items: [
                    _MenuItem(
                      icon: Icons.help_outline_rounded,
                      iconBg: const Color(0xFFDBEAFE),
                      iconColor: const Color(0xFF3B82F6),
                      title: 'Help Center',
                      subtitle: 'FAQ & support',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      iconBg: const Color(0xFFD1FAE5),
                      iconColor: const Color(0xFF10B981),
                      title: 'Contact Us',
                      subtitle: 'Chat, email, phone',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.star_outline_rounded,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Rate the App',
                      subtitle: 'Share your feedback',
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── 6. Logout ─────────────────────────────────
                _LogoutButton(onTap: () => _showLogoutDialog(context)),

                const SizedBox(height: 12),
                Text(
                  'Version 2.4.1 · Build 201',
                  style: TextStyle(fontSize: 11, color: context.text2),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────

  Widget _badge(String count) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFFEF4444),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      count,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  void _navigate(BuildContext context, Widget page) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        ),
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LanguageSheet(
        selected: _selectedLanguage,
        onSelect: (lang) {
          setState(() => _selectedLanguage = lang);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _show2FASnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('2FA enabled — your account is now more secure!'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log out?',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: Text(
          'You will be returned to login.',
          style: TextStyle(fontSize: 14, color: context.text2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: context.text2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // 1. Close the dialog
              Navigator.pop(context);

              // 2. Show loading spinner
              if (!context.mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: context.card,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const CircularProgressIndicator(),
                  ),
                ),
              );

              // 3. Perform logout (clear token)
              await logout();
              await Future.delayed(const Duration(milliseconds: 700));

              // 4. Guard against unmounted context
              if (!context.mounted) return;

              // 5. Close loader
              Navigator.pop(context);

              // 6. Navigate to LoginScreen, clearing all routes
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Log out',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PROFILE HEADER
// ═══════════════════════════════════════════════════════════════

class _ProfileHeader extends StatelessWidget {
  final List<Map<String, dynamic>> stats;
  const _ProfileHeader({required this.stats});

  @override
  Widget build(BuildContext context) {
    final c = context;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(c.isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar row
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Text(
                            'A',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: c.card, width: 2.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Alex Johnson',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: c.text1,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'VIP',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'alex.johnson@email.com',
                      style: TextStyle(fontSize: 12, color: c.text2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '+855 12 345 678',
                      style: TextStyle(fontSize: 12, color: c.text2),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Divider
          Divider(height: 1, color: c.border),

          const SizedBox(height: 16),

          // Stats row
          Row(
            children: stats.asMap().entries.map((e) {
              final s = e.value;
              return Expanded(
                child: Column(
                  children: [
                    Icon(s['icon'] as IconData, size: 20, color: c.accent),
                    const SizedBox(height: 4),
                    Text(
                      s['value'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: c.text1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s['label'] as String,
                      style: TextStyle(fontSize: 10, color: c.text2),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MENU COMPONENTS
// ═══════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 16, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: context.text2,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(context.isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return Column(
            children: [
              item,
              if (i < items.length - 1)
                Divider(height: 1, indent: 60, color: context.border),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem extends StatefulWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget? customTrailing;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.customTrailing,
    this.onTap,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = context;
    return GestureDetector(
      onTapDown: (_) =>
          widget.onTap != null ? setState(() => _pressed = true) : null,
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _pressed ? c.border.withOpacity(0.5) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            // Icon box
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: widget.iconBg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(widget.icon, size: 19, color: widget.iconColor),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.text1,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    widget.subtitle,
                    style: TextStyle(fontSize: 11, color: c.text2),
                  ),
                ],
              ),
            ),
            // Trailing
            if (widget.customTrailing != null)
              widget.customTrailing!
            else if (widget.trailing != null)
              widget.trailing!
            else if (widget.onTap != null)
              Icon(Icons.chevron_right_rounded, size: 20, color: c.text2),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ICON BUTTON
// ═══════════════════════════════════════════════════════════════

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: context.border),
        ),
        child: Icon(icon, size: 18, color: context.text1),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// LOGOUT BUTTON
// ═══════════════════════════════════════════════════════════════

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded, size: 18, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text(
              'Log Out',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BOTTOM SHEETS
// ═══════════════════════════════════════════════════════════════

class _EditProfileSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: context.text1,
            ),
          ),
          const SizedBox(height: 20),
          _SheetField(label: 'Full Name', hint: 'Alex Johnson'),
          const SizedBox(height: 14),
          _SheetField(label: 'Email', hint: 'alex.johnson@email.com'),
          const SizedBox(height: 14),
          _SheetField(label: 'Phone', hint: '+855 12 345 678'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final String label, hint;
  const _SheetField({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.text2,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          style: TextStyle(fontSize: 14, color: context.text1),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.text2, fontSize: 14),
            filled: true,
            fillColor: context.accentBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _LanguageSheet extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;
  const _LanguageSheet({required this.selected, required this.onSelect});

  static const _languages = [
    {'name': 'English', 'flag': '🇺🇸'},
    {'name': 'ភាសាខ្មែរ', 'flag': '🇰🇭'},
    {'name': '中文', 'flag': '🇨🇳'},
    {'name': '日本語', 'flag': '🇯🇵'},
    {'name': 'Français', 'flag': '🇫🇷'},
    {'name': 'Español', 'flag': '🇪🇸'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Select Language',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: context.text1,
            ),
          ),
          const SizedBox(height: 16),
          ..._languages.map((lang) {
            final isSelected = lang['name'] == selected;
            return GestureDetector(
              onTap: () => onSelect(lang['name']!),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? context.accentBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? context.accent : context.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(lang['flag']!, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 14),
                    Text(
                      lang['name']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected ? context.accent : context.text1,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        size: 20,
                        color: context.accent,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PLACEHOLDER SUB-SCREENS
// ═══════════════════════════════════════════════════════════════

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;

  const _PlaceholderScreen({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.border),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: context.text1,
            ),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: context.text1,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: context.text1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: context.text2),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(
    title: 'My Orders',
    icon: Icons.shopping_bag_outlined,
    color: const Color(0xFF3B82F6),
    description: 'Your order history goes here',
  );
}

class _WishlistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(
    title: 'Wishlist',
    icon: Icons.favorite_border_rounded,
    color: const Color(0xFFF43F5E),
    description: 'Your saved items go here',
  );
}

class _AddressPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(
    title: 'Addresses',
    icon: Icons.location_on_outlined,
    color: const Color(0xFF10B981),
    description: 'Manage your delivery addresses',
  );
}

class _PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(
    title: 'Payment Methods',
    icon: Icons.credit_card_rounded,
    color: const Color(0xFFF59E0B),
    description: 'Your saved payment methods',
  );
}

class _ChangePasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.border),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: context.text1,
            ),
          ),
        ),
        title: Text(
          'Change Password',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: context.text1,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetField(label: 'Current Password', hint: '••••••••'),
            const SizedBox(height: 14),
            _SheetField(label: 'New Password', hint: '••••••••'),
            const SizedBox(height: 14),
            _SheetField(label: 'Confirm New Password', hint: '••••••••'),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Update Password',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
