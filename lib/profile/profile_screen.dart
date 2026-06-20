// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mart_frontend/screens/home/home_screen.dart';
// import 'package:mart_frontend/screens/main/main_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:get/get.dart';
// import '../controllers/language_controller.dart';
// import '../main.dart';

// import '../models/profile_model.dart';
// import '../screens/theme/theme_controller.dart';
// // ═══════════════════════════════════════════════════════════════
// // ENTRY POINT
// // ═══════════════════════════════════════════════════════════════

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   static _MyAppState? of(BuildContext context) =>
//       context.findAncestorStateOfType<_MyAppState>();

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   ThemeMode _themeMode = ThemeMode.light;

//   void toggleTheme(bool isDark) {
//     setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Profile',
//       themeMode: _themeMode,
//       theme: ThemeData(
//         useMaterial3: true,
//         brightness: Brightness.light,
//         scaffoldBackgroundColor: const Color(0xFFF6F5F3),
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF111111),
//           brightness: Brightness.light,
//         ),
//       ),
//       darkTheme: ThemeData(
//         useMaterial3: true,
//         brightness: Brightness.dark,
//         scaffoldBackgroundColor: const Color(0xFF0E0E0E),
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF8B7CF6),
//           brightness: Brightness.dark,
//         ),
//       ),
//       home: const ProfileScreen(),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // THEME HELPERS
// // ═══════════════════════════════════════════════════════════════

// extension ThemeX on BuildContext {
//   bool get isDark => Theme.of(this).brightness == Brightness.dark;

//   Color get bg => isDark ? const Color(0xFF0E0E0E) : const Color(0xFFF6F5F3);
//   Color get card => isDark ? const Color(0xFF1A1A1A) : Colors.white;
//   Color get text1 => isDark ? const Color(0xFFF0F0F0) : const Color(0xFF111111);
//   Color get text2 => isDark ? const Color(0xFF888888) : const Color(0xFF777777);
//   Color get text3 => isDark ? const Color(0xFF444444) : const Color(0xFFEEEEEE);
//   Color get border =>
//       isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0);
//   Color get accent =>
//       isDark ? const Color(0xFF8B7CF6) : const Color(0xFF111111);
//   Color get accentBg =>
//       isDark ? const Color(0xFF2A2340) : const Color(0xFFF3F3F3);
// }

// // ═══════════════════════════════════════════════════════════════
// // PROFILE SCREEN
// // ═══════════════════════════════════════════════════════════════

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen>
//     with SingleTickerProviderStateMixin {
//   bool _notificationsOn = true;
//   final themeController = Get.find<ThemeController>();
//   final langController = Get.find<LanguageController>();

//   bool _twoFAEnabled = false;

//   late AnimationController _headerAnim;
//   late Animation<double> _headerFade;
//   late Animation<Offset> _headerSlide;

//   @override
//   void initState() {
//     super.initState();
//     _headerAnim = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
//     _headerSlide = Tween<Offset>(
//       begin: const Offset(0, -0.08),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutCubic));
//     _headerAnim.forward();

//   }

//   @override
//   void dispose() {
//     _headerAnim.dispose();
//     super.dispose();
//   }

//   // ── Logout ───────────────────────────────────────────────────
//   Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove("token");
//   }

//   // ── Stats data ───────────────────────────────────────────────
//   static const _stats = [
//     {'icon': Icons.shopping_bag_outlined, 'value': '24', 'label': 'Orders'},
//     {'icon': Icons.favorite_border_rounded, 'value': '18', 'label': 'Wishlist'},
//     {'icon': Icons.star_outline_rounded, 'value': '1,240', 'label': 'Points'},
//     {'icon': Icons.local_offer_outlined, 'value': '6', 'label': 'Coupons'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final c = context;
//     return Scaffold(
//       backgroundColor: c.bg,
//       body: CustomScrollView(
//         slivers: [
//           // ── SliverAppBar ─────────────────────────────────────
//           SliverAppBar(
//             expandedHeight: 0,
//             pinned: true,
//             backgroundColor: c.bg,
//             elevation: 0,
//             title: Text(
//               'My Profile',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w800,
//                 color: c.text1,
//                 letterSpacing: -0.3,
//               ),
//             ),
//             actions: [
//               _IconBtn(
//                 icon: Icons.edit_outlined,
//                 onTap: () => _showEditProfile(context),
//               ),
//               const SizedBox(width: 8),
//               _IconBtn(icon: Icons.qr_code_rounded, onTap: () {}),
//               const SizedBox(width: 16),
//             ],
//           ),

//           SliverToBoxAdapter(
//             child: Column(
//               children: [
//                 // ── 1. Profile Header ─────────────────────────
//                 FadeTransition(
//                   opacity: _headerFade,
//                   child: SlideTransition(
//                     position: _headerSlide,
//                     child: _ProfileHeader(stats: _stats),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // ── 2. My Account ─────────────────────────────
//                 _SectionLabel(label: 'My Account'),
//                 _MenuGroup(
//                   items: [
//                     // _MenuItem(
//                     //   icon: Icons.shopping_bag_outlined,
//                     //   iconBg: const Color(0xFFDBEAFE),
//                     //   iconColor: const Color(0xFF3B82F6),
//                     //   title: 'My Orders',
//                     //   subtitle: '24 total orders',
//                     //   trailing: _badge('3'),
//                     //   onTap: () => _navigate(context, _OrdersPage()),
//                     // ),
//                     _MenuItem(
//                       icon: Icons.favorite_border_rounded,
//                       iconBg: const Color(0xFFFFE4E6),
//                       iconColor: const Color(0xFFF43F5E),
//                       title: 'Wishlist',
//                       subtitle: '18 saved items',
//                       onTap: () => _navigate(context, _WishlistPage()),
//                     ),
//                     _MenuItem(
//                       icon: Icons.location_on_outlined,
//                       iconBg: const Color(0xFFD1FAE5),
//                       iconColor: const Color(0xFF10B981),
//                       title: 'Addresses',
//                       subtitle: '2 saved addresses',
//                       onTap: () => _navigate(context, _AddressPage()),
//                     ),
//                     _MenuItem(
//                       icon: Icons.credit_card_rounded,
//                       iconBg: const Color(0xFFFEF3C7),
//                       iconColor: const Color(0xFFF59E0B),
//                       title: 'Payment Methods',
//                       subtitle: 'Visa, Cash on delivery',
//                       onTap: () => _navigate(context, _PaymentPage()),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 // ── 3. Preferences ────────────────────────────
//                 _SectionLabel(label: 'Preferences'),
//                 _MenuGroup(
//                   items: [
//                     _MenuItem(
//                       icon: themeController.isDark.value
//                           ? Icons.dark_mode_rounded
//                           : Icons.light_mode_rounded,

//                       iconBg: themeController.isDark.value
//                           ? const Color(0xFF2A2340)
//                           : const Color(0xFFFEF3C7),

//                       iconColor: themeController.isDark.value
//                           ? const Color(0xFF8B7CF6)
//                           : const Color(0xFFF59E0B),

//                       title: 'Dark Mode',

//                       subtitle: themeController.isDark.value
//                           ? 'Enabled'
//                           : 'Disabled',

//                       customTrailing: Obx(
//                         () => Switch.adaptive(
//                           value: themeController.isDark.value,
//                           activeColor: const Color(0xFF8B7CF6),
//                           onChanged: (v) {
//                             themeController.toggleTheme(v);
//                             HapticFeedback.selectionClick();
//                           },
//                         ),
//                       ),

//                       onTap: null,
//                     ),

//                     _MenuItem(
//                       icon: _notificationsOn
//                           ? Icons.notifications_active_outlined
//                           : Icons.notifications_off_outlined,
//                       iconBg: _notificationsOn
//                           ? const Color(0xFFFFE4E6)
//                           : const Color(0xFFF3F4F6),
//                       iconColor: _notificationsOn
//                           ? const Color(0xFFF43F5E)
//                           : const Color(0xFF9CA3AF),
//                       title: 'Notifications',
//                       subtitle: _notificationsOn
//                           ? 'Push & email on'
//                           : 'All off',
//                       customTrailing: Obx(
//                         () => Switch.adaptive(
//                           value: themeController.isDark.value,
//                           activeColor: const Color(0xFF8B7CF6),
//                           onChanged: (v) {
//                             themeController.toggleTheme(v);
//                             HapticFeedback.selectionClick();
//                           },
//                         ),
//                       ),
//                       onTap: null,
//                     ),
//                     _MenuItem(
//                       icon: Icons.language_rounded,
//                       iconBg: const Color(0xFFDBEAFE),
//                       iconColor: const Color(0xFF3B82F6),

//                       title: 'language'.tr,

//                       subtitle: langController.language.value.toUpperCase(),

//                       onTap: () => _showLanguagePicker(context),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 // ── 4. Security ───────────────────────────────
//                 _SectionLabel(label: 'Security'),
//                 _MenuGroup(
//                   items: [
//                     _MenuItem(
//                       icon: Icons.lock_outline_rounded,
//                       iconBg: const Color(0xFFEDE9FE),
//                       iconColor: const Color(0xFF8B5CF6),
//                       title: 'Change Password',
//                       subtitle: 'Last changed 30 days ago',
//                       onTap: () => _navigate(context, _ChangePasswordPage()),
//                     ),
//                     _MenuItem(
//                       icon: Icons.verified_user_outlined,
//                       iconBg: _twoFAEnabled
//                           ? const Color(0xFFD1FAE5)
//                           : const Color(0xFFF3F4F6),
//                       iconColor: _twoFAEnabled
//                           ? const Color(0xFF10B981)
//                           : const Color(0xFF9CA3AF),
//                       title: '2-Factor Authentication',
//                       subtitle: _twoFAEnabled ? '✓ Enabled' : 'Tap to enable',
//                       customTrailing: Switch.adaptive(
//                         value: _twoFAEnabled,
//                         activeColor: const Color(0xFF10B981),
//                         onChanged: (v) {
//                           setState(() => _twoFAEnabled = v);
//                           HapticFeedback.mediumImpact();
//                           if (v) _show2FASnack(context);
//                         },
//                       ),
//                       onTap: null,
//                     ),
//                     _MenuItem(
//                       icon: Icons.shield_outlined,
//                       iconBg: const Color(0xFFFEF3C7),
//                       iconColor: const Color(0xFFF59E0B),
//                       title: 'Privacy Settings',
//                       subtitle: 'Data & permissions',
//                       onTap: () {},
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 // ── 5. Support ────────────────────────────────
//                 _SectionLabel(label: 'Support'),
//                 _MenuGroup(
//                   items: [
//                     _MenuItem(
//                       icon: Icons.help_outline_rounded,
//                       iconBg: const Color(0xFFDBEAFE),
//                       iconColor: const Color(0xFF3B82F6),
//                       title: 'Help Center',
//                       subtitle: 'FAQ & support',
//                       onTap: () {},
//                     ),
//                     _MenuItem(
//                       icon: Icons.chat_bubble_outline_rounded,
//                       iconBg: const Color(0xFFD1FAE5),
//                       iconColor: const Color(0xFF10B981),
//                       title: 'Contact Us',
//                       subtitle: 'Chat, email, phone',
//                       onTap: () {},
//                     ),
//                     _MenuItem(
//                       icon: Icons.star_outline_rounded,
//                       iconBg: const Color(0xFFFEF3C7),
//                       iconColor: const Color(0xFFF59E0B),
//                       title: 'Rate the App',
//                       subtitle: 'Share your feedback',
//                       onTap: () {},
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 // ── 6. Logout ─────────────────────────────────
//                 _LogoutButton(onTap: () => _showLogoutDialog(context)),

//                 const SizedBox(height: 12),
//                 Text(
//                   'Version 2.4.1 · Build 201',
//                   style: TextStyle(fontSize: 11, color: context.text2),
//                 ),
//                 const SizedBox(height: 32),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Helpers ──────────────────────────────────────────────────

//   Widget _badge(String count) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//     decoration: BoxDecoration(
//       color: const Color(0xFFEF4444),
//       borderRadius: BorderRadius.circular(20),
//     ),
//     child: Text(
//       count,
//       style: const TextStyle(
//         color: Colors.white,
//         fontSize: 11,
//         fontWeight: FontWeight.w700,
//       ),
//     ),
//   );

//   void _navigate(BuildContext context, Widget page) {
//     HapticFeedback.selectionClick();
//     Navigator.push(
//       context,
//       PageRouteBuilder(
//         transitionDuration: const Duration(milliseconds: 280),
//         pageBuilder: (_, __, ___) => page,
//         transitionsBuilder: (_, anim, __, child) => FadeTransition(
//           opacity: anim,
//           child: SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(0.04, 0),
//               end: Offset.zero,
//             ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
//             child: child,
//           ),
//         ),
//       ),
//     );
//   }

//   void _showEditProfile(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _EditProfileSheet(),
//     );
//   }

//   void _showLanguagePicker(BuildContext context) {
//     final langController = Get.find<LanguageController>();

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _LanguageSheet(
//         selected: langController.language.value,

//         onSelect: (langCode) {
//           langController.changeLanguage(langCode); // ✅ GetX
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }

//   void _show2FASnack(BuildContext context) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('2FA enabled — your account is now more secure!'),
//         backgroundColor: const Color(0xFF10B981),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         backgroundColor: context.card,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text(
//           'Log out?',
//           style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
//         ),
//         content: Text(
//           'You will be returned to login.',
//           style: TextStyle(fontSize: 14, color: context.text2),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: TextStyle(
//                 color: context.text2,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               // 1. Close the dialog
//               Navigator.pop(context);

//               // 2. Show loading spinner
//               if (!context.mounted) return;
//               showDialog(
//                 context: context,
//                 barrierDismissible: false,
//                 builder: (_) => Center(
//                   child: Container(
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: context.card,
//                       borderRadius: BorderRadius.circular(18),
//                     ),
//                     child: const CircularProgressIndicator(),
//                   ),
//                 ),
//               );

//               // 3. Perform logout (clear token)
//               await logout();
//               await Future.delayed(const Duration(milliseconds: 700));

//               // 4. Guard against unmounted context
//               if (!context.mounted) return;

//               // 5. Close loader
//               Navigator.pop(context);

//               // 6. Navigate to LoginScreen, clearing all routes
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (_) => const MainScreen()),
//                 (route) => false,
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFEF4444),
//               foregroundColor: Colors.white,
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: const Text(
//               'Log out',
//               style: TextStyle(fontWeight: FontWeight.w700),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // PROFILE HEADER
// // ═══════════════════════════════════════════════════════════════

// class _ProfileHeader extends StatelessWidget {
//   final List<Map<String, dynamic>> stats;
//   const _ProfileHeader({required this.stats});

//   @override
//   Widget build(BuildContext context) {
//     final c = context;
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: c.card,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(c.isDark ? 0.3 : 0.06),
//             blurRadius: 20,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Avatar row
//           Row(
//             children: [
//               Stack(
//                 children: [
//                   Container(
//                     width: 76,
//                     height: 76,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFF8B5CF6).withOpacity(0.35),
//                           blurRadius: 16,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: ClipOval(
//                       child: Image.network(
//                         'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
//                         fit: BoxFit.cover,
//                         errorBuilder: (_, __, ___) => const Center(
//                           child: Text(
//                             'A',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 28,
//                               fontWeight: FontWeight.w800,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     right: 0,
//                     bottom: 0,
//                     child: Container(
//                       width: 22,
//                       height: 22,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF10B981),
//                         shape: BoxShape.circle,
//                         border: Border.all(color: c.card, width: 2.5),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           'Alex Johnson',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w800,
//                             color: c.text1,
//                             letterSpacing: -0.3,
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 7,
//                             vertical: 2,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFFEF3C7),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Text(
//                             'VIP',
//                             style: TextStyle(
//                               fontSize: 9,
//                               fontWeight: FontWeight.w800,
//                               color: Color(0xFFF59E0B),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 3),
//                     Text(
//                       'alex.johnson@email.com',
//                       style: TextStyle(fontSize: 12, color: c.text2),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       '+855 12 345 678',
//                       style: TextStyle(fontSize: 12, color: c.text2),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           // Divider
//           Divider(height: 1, color: c.border),

//           const SizedBox(height: 16),

//           // Stats row
//           Row(
//             children: stats.asMap().entries.map((e) {
//               final s = e.value;
//               return Expanded(
//                 child: Column(
//                   children: [
//                     Icon(s['icon'] as IconData, size: 20, color: c.accent),
//                     const SizedBox(height: 4),
//                     Text(
//                       s['value'] as String,
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w800,
//                         color: c.text1,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       s['label'] as String,
//                       style: TextStyle(fontSize: 10, color: c.text2),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // MENU COMPONENTS
// // ═══════════════════════════════════════════════════════════════

// class _SectionLabel extends StatelessWidget {
//   final String label;
//   const _SectionLabel({required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 0, 16, 8),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w700,
//           color: context.text2,
//           letterSpacing: 0.5,
//         ),
//       ),
//     );
//   }
// }

// class _MenuGroup extends StatelessWidget {
//   final List<_MenuItem> items;
//   const _MenuGroup({required this.items});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: context.card,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(context.isDark ? 0.25 : 0.04),
//             blurRadius: 12,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         children: items.asMap().entries.map((e) {
//           final i = e.key;
//           final item = e.value;
//           return Column(
//             children: [
//               item,
//               if (i < items.length - 1)
//                 Divider(height: 1, indent: 60, color: context.border),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

// class _MenuItem extends StatefulWidget {
//   final IconData icon;
//   final Color iconBg;
//   final Color iconColor;
//   final String title;
//   final String subtitle;
//   final Widget? trailing;
//   final Widget? customTrailing;
//   final VoidCallback? onTap;

//   const _MenuItem({
//     required this.icon,
//     required this.iconBg,
//     required this.iconColor,
//     required this.title,
//     required this.subtitle,
//     this.trailing,
//     this.customTrailing,
//     this.onTap,
//   });

//   @override
//   State<_MenuItem> createState() => _MenuItemState();
// }

// class _MenuItemState extends State<_MenuItem> {
//   bool _pressed = false;

//   @override
//   Widget build(BuildContext context) {
//     final c = context;
//     return GestureDetector(
//       onTapDown: (_) =>
//           widget.onTap != null ? setState(() => _pressed = true) : null,
//       onTapUp: (_) {
//         setState(() => _pressed = false);
//         widget.onTap?.call();
//       },
//       onTapCancel: () => setState(() => _pressed = false),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 120),
//         color: _pressed ? c.border.withOpacity(0.5) : Colors.transparent,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
//         child: Row(
//           children: [
//             // Icon box
//             Container(
//               width: 38,
//               height: 38,
//               decoration: BoxDecoration(
//                 color: widget.iconBg,
//                 borderRadius: BorderRadius.circular(11),
//               ),
//               child: Icon(widget.icon, size: 19, color: widget.iconColor),
//             ),
//             const SizedBox(width: 14),
//             // Text
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.title,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: c.text1,
//                     ),
//                   ),
//                   const SizedBox(height: 1),
//                   Text(
//                     widget.subtitle,
//                     style: TextStyle(fontSize: 11, color: c.text2),
//                   ),
//                 ],
//               ),
//             ),
//             // Trailing
//             if (widget.customTrailing != null)
//               widget.customTrailing!
//             else if (widget.trailing != null)
//               widget.trailing!
//             else if (widget.onTap != null)
//               Icon(Icons.chevron_right_rounded, size: 20, color: c.text2),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // ICON BUTTON
// // ═══════════════════════════════════════════════════════════════

// class _IconBtn extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//   const _IconBtn({required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 38,
//         height: 38,
//         decoration: BoxDecoration(
//           color: context.card,
//           borderRadius: BorderRadius.circular(11),
//           border: Border.all(color: context.border),
//         ),
//         child: Icon(icon, size: 18, color: context.text1),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // LOGOUT BUTTON
// // ═══════════════════════════════════════════════════════════════

// class _LogoutButton extends StatelessWidget {
//   final VoidCallback onTap;
//   const _LogoutButton({required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         HapticFeedback.mediumImpact();
//         onTap();
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16),
//         padding: const EdgeInsets.symmetric(vertical: 15),
//         decoration: BoxDecoration(
//           color: const Color(0xFFFEF2F2),
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: const Color(0xFFFECACA)),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const [
//             Icon(Icons.logout_rounded, size: 18, color: Color(0xFFEF4444)),
//             SizedBox(width: 8),
//             Text(
//               'Log Out',
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFFEF4444),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // BOTTOM SHEETS
// // ═══════════════════════════════════════════════════════════════

// class _EditProfileSheet extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom + 24,
//         top: 20,
//         left: 20,
//         right: 20,
//       ),
//       decoration: BoxDecoration(
//         color: context.card,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Container(
//               width: 36,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: context.border,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Edit Profile',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w800,
//               color: context.text1,
//             ),
//           ),
//           const SizedBox(height: 20),
//           _SheetField(label: 'Full Name', hint: 'Alex Johnson'),
//           const SizedBox(height: 14),
//           _SheetField(label: 'Email', hint: 'alex.johnson@email.com'),
//           const SizedBox(height: 14),
//           _SheetField(label: 'Phone', hint: '+855 12 345 678'),
//           const SizedBox(height: 24),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: context.accent,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 15),
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//               ),
//               child: const Text(
//                 'Save Changes',
//                 style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SheetField extends StatelessWidget {
//   final String label, hint;
//   const _SheetField({required this.label, required this.hint});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: context.text2,
//           ),
//         ),
//         const SizedBox(height: 6),
//         TextField(
//           style: TextStyle(fontSize: 14, color: context.text1),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(color: context.text2, fontSize: 14),
//             filled: true,
//             fillColor: context.accentBg,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide.none,
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 14,
//               vertical: 12,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _LanguageSheet extends StatelessWidget {
//   final String selected;
//   final void Function(String) onSelect;
//   const _LanguageSheet({required this.selected, required this.onSelect});

//   // static const _languages = [
//   //   {'name': 'English', 'flag': '🇺🇸'},
//   //   {'name': 'ភាសាខ្មែរ', 'flag': '🇰🇭'},
//   //   {'name': '中文', 'flag': '🇨🇳'},
//   //   {'name': '日本語', 'flag': '🇯🇵'},
//   //   {'name': 'Français', 'flag': '🇫🇷'},
//   //   {'name': 'Español', 'flag': '🇪🇸'},
//   // ];
//   static const _languages = [
//     {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
//     {'name': 'ភាសាខ្មែរ', 'code': 'km', 'flag': '🇰🇭'},
//     {'name': '中文', 'code': 'zh', 'flag': '🇨🇳'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
//       decoration: BoxDecoration(
//         color: context.card,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Container(
//               width: 36,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: context.border,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Select Language',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w800,
//               color: context.text1,
//             ),
//           ),
//           const SizedBox(height: 16),
//           ..._languages.map((lang) {
//             final isSelected = lang['code'] == selected;
//             return GestureDetector(
//               onTap: () => onSelect(lang['code']!),
//               child: Container(
//                 margin: const EdgeInsets.only(bottom: 8),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 13,
//                 ),
//                 decoration: BoxDecoration(
//                   color: isSelected ? context.accentBg : Colors.transparent,
//                   borderRadius: BorderRadius.circular(14),
//                   border: Border.all(
//                     color: isSelected ? context.accent : context.border,
//                     width: isSelected ? 1.5 : 1,
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Text(lang['flag']!, style: const TextStyle(fontSize: 22)),
//                     const SizedBox(width: 14),
//                     Text(
//                       lang['name']!,
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: isSelected
//                             ? FontWeight.w700
//                             : FontWeight.w500,
//                         color: isSelected ? context.accent : context.text1,
//                       ),
//                     ),
//                     const Spacer(),
//                     if (isSelected)
//                       Icon(
//                         Icons.check_circle_rounded,
//                         size: 20,
//                         color: context.accent,
//                       ),
//                   ],
//                 ),
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // PLACEHOLDER SUB-SCREENS
// // ═══════════════════════════════════════════════════════════════

// class _PlaceholderScreen extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final Color color;
//   final String description;

//   const _PlaceholderScreen({
//     required this.title,
//     required this.icon,
//     required this.color,
//     required this.description,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: context.bg,
//       appBar: AppBar(
//         backgroundColor: context.bg,
//         elevation: 0,
//         leading: GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: Container(
//             margin: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: context.card,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: context.border),
//             ),
//             child: Icon(
//               Icons.arrow_back_ios_new_rounded,
//               size: 16,
//               color: context.text1,
//             ),
//           ),
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             fontSize: 17,
//             fontWeight: FontWeight.w800,
//             color: context.text1,
//           ),
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.12),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, size: 36, color: color),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w800,
//                 color: context.text1,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               description,
//               style: TextStyle(fontSize: 14, color: context.text2),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // class _OrdersPage extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) => _PlaceholderScreen(
// //     title: 'My Orders',
// //     icon: Icons.shopping_bag_outlined,
// //     color: const Color(0xFF3B82F6),
// //     description: 'Your order history goes here',
// //   );
// // }

// class _WishlistPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => _PlaceholderScreen(
//     title: 'Wishlist',
//     icon: Icons.favorite_border_rounded,
//     color: const Color(0xFFF43F5E),
//     description: 'Your saved items go here',
//   );
// }

// class _AddressPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => _PlaceholderScreen(
//     title: 'Addresses',
//     icon: Icons.location_on_outlined,
//     color: const Color(0xFF10B981),
//     description: 'Manage your delivery addresses',
//   );
// }

// class _PaymentPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => _PlaceholderScreen(
//     title: 'Payment Methods',
//     icon: Icons.credit_card_rounded,
//     color: const Color(0xFFF59E0B),
//     description: 'Your saved payment methods',
//   );
// }

// class _ChangePasswordPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: context.bg,
//       appBar: AppBar(
//         backgroundColor: context.bg,
//         elevation: 0,
//         leading: GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: Container(
//             margin: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: context.card,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: context.border),
//             ),
//             child: Icon(
//               Icons.arrow_back_ios_new_rounded,
//               size: 16,
//               color: context.text1,
//             ),
//           ),
//         ),
//         title: Text(
//           'Change Password',
//           style: TextStyle(
//             fontSize: 17,
//             fontWeight: FontWeight.w800,
//             color: context.text1,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _SheetField(label: 'Current Password', hint: '••••••••'),
//             const SizedBox(height: 14),
//             _SheetField(label: 'New Password', hint: '••••••••'),
//             const SizedBox(height: 14),
//             _SheetField(label: 'Confirm New Password', hint: '••••••••'),
//             const SizedBox(height: 28),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF8B5CF6),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//                 child: const Text(
//                   'Update Password',
//                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mart_frontend/auth/login_screen.dart';
import 'package:mart_frontend/profile/address_screen.dart';
import 'package:mart_frontend/profile/address_screen.dart';
import 'package:mart_frontend/profile/edit_profile_screen.dart';
import 'package:mart_frontend/providers/profile_provider.dart';
import 'package:mart_frontend/screens/main/coming_soon_screen.dart';
import 'package:mart_frontend/screens/main/main_screen.dart';
import 'package:mart_frontend/screens/product/product_detail_screen.dart';
import 'package:mart_frontend/services/address_history_service.dart';
import 'package:mart_frontend/services/api_service.dart';
import 'package:mart_frontend/services/wishlist_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../controllers/language_controller.dart';
import '../models/profile_model.dart';
import '../screens/theme/theme_controller.dart';
import '../translations/catalog_translation.dart';
import '../widgets/skeleton_loader.dart';
import 'rate_app_screen.dart';
import 'contact_us_screen.dart';
import 'faq_screen.dart';
import 'tell_a_friend_screen.dart';
import 'social_media_screen.dart';
import 'about_us_screen.dart';
import 'terms_screen.dart';
import 'privacy_policy_screen.dart';
import 'package:hugeicons/hugeicons.dart';

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
  Color get bgicon => isDark ? Color(0xFF2A2340) : const Color(0xFFF6F5F3);
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
  bool _isLoggedIn = false;
  final themeController = Get.find<ThemeController>();
  final langController = Get.find<LanguageController>();
  final _profileService = ApiService();

  bool _twoFAEnabled = false;
  // MyProfileModel? _profile;
  bool _isLoading = false;
  String? _error;
  int _wishlistCount = 0;
  int _addressCount = 0;

  late AnimationController _headerAnim;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  // Stats — will update from API where possible
  List<Map<String, dynamic>> get _stats => [
    {'image': 'lib/icons/order.png', 'value': '24', 'label': 'orders'.tr},
    {
      'image': 'lib/icons/wishlist.png',
      'value': _wishlistCount.toString(),
      'label': 'wishlist'.tr,
    },
    {'image': 'lib/icons/point.png', 'value': '1,240', 'label': 'points'.tr},
    {'image': 'lib/icons/coupon.png', 'value': '6', 'label': 'coupons'.tr},
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final provider = context.read<ProfileProvider>();

    //   setState(() {
    //     _profile = provider.profile;
    //     _isLoading = false;
    //   });
    // });

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
    // _loadProfile();
    _loadLocalCounts();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
    });
  }

  // ── Load profile from API ─────────────────────────────────────
  // Future<void> _loadProfile() async {
  //   try {
  //     setState(() {
  //       _isLoading = true;
  //       _error = null;
  //     });
  //     final profile = await _profileService.fetchMyProfile();
  //     setState(() {
  //       _profile = profile;
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _error = e.toString();
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> _loadLocalCounts() async {
    final counts = await Future.wait<int>([
      WishlistService().count(),
      AddressHistoryService().count(),
    ]);
    if (!mounted) return;
    setState(() {
      _wishlistCount = counts[0];
      _addressCount = counts[1];
    });
  }

  // ── Logout ─────────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("my_profile_cache");
    context.read<ProfileProvider>().clear();
  }

  @override
  Widget build(BuildContext context) {
    final c = context;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Center(
              child: Text(
                'my_profile'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: c.text1,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            // actions: [
            //   _IconBtn(
            //     icon: Icons.edit_outlined,
            //     onTap: () {
            //       if (_profile != null) {
            //         _showEditProfile(context, _profile!);
            //       }
            //     },
            //   ),
            //   const SizedBox(width: 8),
            //   _IconBtn(icon: Icons.qr_code_rounded, onTap: () {}),
            //   const SizedBox(width: 16),
            // ],
          ),

          SliverToBoxAdapter(
            child: _isLoading
                ? _buildLoadingSkeleton(c)
                : _error != null
                ? _buildLoadingSkeleton(c)
                : _buildContent(c),
          ),
        ],
      ),
    );
  }

  // ── Loading skeleton ──────────────────────────────────────────
  Widget _buildLoadingSkeleton(BuildContext c) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SkeletonBox(height: 160, radius: 24),
          const SizedBox(height: 20),
          _SkeletonBox(height: 180, radius: 20),
          const SizedBox(height: 20),
          _SkeletonBox(height: 180, radius: 20),
        ],
      ),
    );
  }

  // ── Error state ───────────────────────────────────────────────
  // Widget _buildErrorState(BuildContext c) {
  //   return Padding(
  //     padding: const EdgeInsets.all(40),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(Icons.cloud_off_rounded, size: 56, color: c.text2),
  //         const SizedBox(height: 16),
  //         Text(
  //           'failed_to_load_profile'.tr,
  //           style: TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.w700,
  //             color: c.text1,
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           _error ?? '',
  //           style: TextStyle(fontSize: 12, color: c.text2),
  //           textAlign: TextAlign.center,
  //         ),
  //         const SizedBox(height: 24),
  //         ElevatedButton.icon(
  //           onPressed: _loadProfile,
  //           icon: const Icon(Icons.refresh_rounded, size: 16),
  //           label: Text('retry'.tr),
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: c.accent,
  //             foregroundColor: Colors.white,
  //             elevation: 0,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ── Main content ──────────────────────────────────────────────
  Widget _buildContent(BuildContext c) {
    return Column(
      children: [
        // 1. Profile Header
        FadeTransition(
          opacity: _headerFade,
          child: SlideTransition(
            position: _headerSlide,
            child: Consumer<ProfileProvider>(
              builder: (context, provider, child) {
                if (provider.profile == null) {
                  return const SizedBox();
                }

                return _ProfileHeader(
                  profile: provider.profile!,
                  stats: _stats,
                  onTap: () async {
                    // Not logged in
                    if (provider.profile!.id == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                      return;
                    }

                    // Logged in
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditProfileScreen(profile: provider.profile!),
                      ),
                    );

                    if (result == true) {
                      await context.read<ProfileProvider>().fetchProfile();
                    }
                  },
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 2. My Account
        _SectionLabel(label: 'my_account'.tr),
        _MenuGroup(
          items: [
            _MenuItem(
              icon: Icons.shopping_bag_outlined,
              iconBg: c.bgicon,
              iconColor: c.text1,
              title: 'my_orders'.tr,
              subtitle: 'total_orders'.tr,
              onTap: () => _navigate(context, MainScreen()),
            ),
            _MenuItem(
              icon: Icons.favorite_border_rounded,
              // iconBg: const Color(0xFFFFE4E6),
              // iconColor: const Color(0xFFF43F5E),
              iconBg: c.bgicon,
              iconColor: c.text1,
              title: 'wishlist'.tr,
              subtitle: 'favorite_items'.tr,
              onTap: () => _navigate(context, ComingSoonScreen()),
            ),

            _MenuItem(
              icon: Icons.location_on_outlined,
              iconBg: c.bgicon,
              iconColor: c.text1,
              title: 'addresses'.tr,
              subtitle: 'saved_addresses'.tr,
              onTap: () => _navigate(context, MyAddressesScreen()),
            ),
            _MenuItem(
              icon: Icons.credit_card_rounded,
              iconBg: c.bgicon,
              iconColor: c.text1,
              title: 'payment_methods'.tr,
              subtitle: 'visa'.tr,
              onTap: () => _navigate(context, ComingSoonScreen()),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 3. Preferences
        _SectionLabel(label: 'preferences'.tr),
        _MenuGroup(
          items: [
            _MenuItem(
              icon: themeController.isDark.value
                  ? Icons.light_mode
                  : Icons.dark_mode,

              iconBg: themeController.isDark.value
                  ? const Color(0xFF2A2340)
                  : c.bg,

              iconColor: themeController.isDark.value ? Colors.white : c.text1,

              title: 'dark_mode'.tr,

              subtitle: themeController.isDark.value
                  ? 'enabled'.tr
                  : 'disabled'.tr,

              customTrailing: Obx(
                () => Switch.adaptive(
                  value: themeController.isDark.value,
                  activeColor: const Color(0xFF8B7CF6),
                  onChanged: (v) {
                    themeController.toggleTheme(v);
                    // HapticFeedback.selectionClick();
                  },
                ),
              ),

              onTap: null,
            ),
            // _MenuItem(
            //   icon: _notificationsOn
            //       ? Icons.notifications_active_outlined
            //       : Icons.notifications_off_outlined,
            //   iconBg: _notificationsOn
            //       ? const Color(0xFFFFE4E6)
            //       : const Color(0xFFF3F4F6),
            //   iconColor: _notificationsOn
            //       ? const Color(0xFFF43F5E)
            //       : const Color(0xFF9CA3AF),
            //   title: 'Notifications',
            //   subtitle: _notificationsOn ? 'Push & email on' : 'All off',
            //   customTrailing: Switch.adaptive(
            //     value: _notificationsOn,
            //     activeColor: const Color(0xFFF43F5E),
            //     onChanged: (v) {
            //       setState(() => _notificationsOn = v);
            //       HapticFeedback.selectionClick();
            //     },
            //   ),
            //   onTap: null,
            // ),
            _MenuItem(
              icon: Icons.language_rounded,
              iconBg: c.bgicon,
              iconColor: c.text1,

              title: 'language'.tr,

              subtitle: langController.language.value.toUpperCase(),

              onTap: () => _showLanguagePicker(context),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 4. Security
        _SectionLabel(label: 'security'.tr),
        _MenuGroup(
          items: [
            _MenuItem(
              icon: Icons.lock_outline_rounded,
              iconBg: c.bgicon,
              iconColor: c.text1,
              title: 'change_password'.tr,
              subtitle: 'change_your_password'.tr,
              onTap: () => _navigate(context, ComingSoonScreen()),
            ),
            // _MenuItem(
            //   icon: Icons.verified_user_outlined,
            //   iconBg: _twoFAEnabled
            //       ? const Color(0xFF2A2340)
            //       : const Color(0xFF2A2340),
            //   iconColor: _twoFAEnabled
            //       ? const Color(0xFFF6F5F3)
            //       : const Color(0xFFF6F5F3),
            //   title: 'two_fa'.tr,
            //   subtitle: _twoFAEnabled ? '✓ Enabled' : 'Tap to enable',
            //   customTrailing: Switch.adaptive(
            //     value: _twoFAEnabled,
            //     activeColor: const Color(0xFF8B7CF6),
            //     onChanged: (v) {
            //       setState(() => _twoFAEnabled = v);
            //       // HapticFeedback.mediumImpact();
            //       if (v) _show2FASnack(context);
            //     },
            //   ),
            //   onTap: null,
            // ),
            _MenuItem(
              icon: Icons.shield_outlined,
              iconBg: c.bgicon,
              iconColor: c.text1,
              title: 'privacy_settings'.tr,
              subtitle: 'data_permissions'.tr,
              onTap: () => _navigate(context, ComingSoonScreen()),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 5. Support
        _SectionLabel(label: 'support'.tr),
        _MenuGroup(
          items: [
            _MenuItem(
              icon: Icons.help_outline_rounded,
              iconBg: c.bgicon,
              iconColor: c.text1,
              title: 'help_center'.tr,
              subtitle: 'faq_support'.tr,
              onTap: () => _navigate(context, ComingSoonScreen()),
            ),
            _MenuItem(
              icon: Icons.chat_bubble_outline_rounded,
              iconBg: c.bgicon,
              iconColor: c.text1,
              title: 'contact_us'.tr,
              subtitle: 'chat_email_phone'.tr,
              onTap: () => _navigate(context, ComingSoonScreen()),
            ),
            _MenuItem(
              icon: Icons.star_outline_rounded,
              iconBg: c.bgicon,
              iconColor: c.text1,
              title: 'rate_app'.tr,
              subtitle: 'share_your_feedback'.tr,
              onTap: () => _navigate(context, ComingSoonScreen()),
            ),
            _MenuItem(
              icon: Icons.public_rounded,
              iconBg: c.bgicon,
              iconColor: c.text1,
              title: 'social_media'.tr,
              subtitle: 'follow_us'.tr,
              onTap: () => _navigate(context, ComingSoonScreen()),
            ),
            _MenuItem(
              icon: Icons.storefront_rounded,
              iconBg: c.bgicon,
              iconColor: c.text1,
              title: 'about_us'.tr,
              subtitle: 'learn_more'.tr,
              onTap: () => _navigate(context, ComingSoonScreen()),
            ),
            _MenuItem(
              icon: Icons.policy_rounded,
              iconBg: c.bgicon,
              iconColor: c.text1,
              title: 'terms_and_conditions'.tr,
              subtitle: 'our_policies'.tr,
              onTap: () => _navigate(context, ComingSoonScreen()),
            ),
            _MenuItem(
              icon: Icons.shield_outlined,
              iconBg: c.bgicon,
              iconColor: c.text1,
              title: 'privacy_policy'.tr,
              subtitle: 'data_privacy'.tr,
              onTap: () => _navigate(context, ComingSoonScreen()),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 6. Logout
        // _LogoutButton(onTap: () => _showLogoutDialog(context)),
        _isLoggedIn
            ? _LogoutButton(onTap: () => _showLogoutDialog(context))
            : SizedBox(height: 1),

        // const SizedBox(height: 12),
        // Text(
        //   'Version 2.4.1 · Build 201',
        //   style: TextStyle(fontSize: 11, color: context.text2),
        // ),
        SizedBox(height: 10 + MediaQuery.of(context).padding.bottom),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────

  Future<void> _navigate(BuildContext context, Widget page) async {
    // HapticFeedback.selectionClick();
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) _loadLocalCounts();
  }

  // void _showEditProfile(BuildContext context, MyProfileModel profile) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (_) => _EditProfileSheet(
  //       profile: profile,
  //       onSaved: (updatedProfile) {
  //         setState(() => _profile = updatedProfile);
  //       },
  //     ),
  //   );
  // }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LanguageSheet(
        selected: langController.language.value,
        onSelect: (langCode) {
          langController.changeLanguage(langCode);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFEF4444),
                size: 36,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'logout_question'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.text1,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'logout_message'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.text2, fontSize: 14),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('cancel'.tr),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);

                      await logout();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MainScreen()),
                        (_) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                    ),
                    child: Text(
                      'logout'.tr,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SKELETON BOX
// ═══════════════════════════════════════════════════════════════

class _SkeletonBox extends StatefulWidget {
  final double height;
  final double radius;
  const _SkeletonBox({required this.height, required this.radius});

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
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
      builder: (_, __) => Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          color: Color.lerp(
            context.isDark ? const Color(0xFF1A1A1A) : const Color(0xFFE8E8E8),
            context.isDark ? const Color(0xFF252525) : const Color(0xFFF0F0F0),
            _anim.value,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PROFILE HEADER  (uses real API data)
// ═══════════════════════════════════════════════════════════════
class _ProfileHeader extends StatelessWidget {
  final MyProfileModel profile;
  final List<Map<String, dynamic>> stats;
  final VoidCallback onTap;

  const _ProfileHeader({
    required this.profile,
    required this.stats,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
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
        child: Row(
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
                child: profile.id == 0
                    ? const Icon(Icons.person, color: Colors.white, size: 34)
                    : (profile.avatar != null)
                    ? Image.network(
                        profile.avatar.toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _avatarFallback(profile.fullName),
                      )
                    : _avatarFallback(profile.fullName),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: profile.id == 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Log_in_or_Sign_up'.tr,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: c.text1,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'start_shopping_track_orders'.tr,
                          style: TextStyle(fontSize: 12, color: c.text2),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.fullName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: c.text1,
                            letterSpacing: -0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          profile.email,
                          style: TextStyle(fontSize: 12, color: c.text2),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.phone?.toString() ?? 'No phone',
                          style: TextStyle(fontSize: 12, color: c.text2),
                        ),
                      ],
                    ),
            ),

            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: c.isDark ? Colors.white10 : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chevron_right, size: 20, color: c.text2),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _avatarFallback(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
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
  final Widget? customIconWidget;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.customTrailing,
    this.customIconWidget,
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
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: widget.iconBg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: widget.customIconWidget != null
                  ? Center(child: widget.customIconWidget)
                  : Icon(widget.icon, size: 19, color: widget.iconColor),
            ),
            const SizedBox(width: 14),
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
        // HapticFeedback.mediumImpact();
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
          children: [
            const Icon(
              Icons.logout_rounded,
              size: 18,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(width: 8),
            Text(
              'logout'.tr,
              style: const TextStyle(
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
// EDIT PROFILE SHEET  (with image picker + API update)
// ═══════════════════════════════════════════════════════════════

class _EditProfileSheet extends StatefulWidget {
  final MyProfileModel profile;
  final void Function(MyProfileModel) onSaved;

  const _EditProfileSheet({required this.profile, required this.onSaved});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;

  File? _pickedImage;
  bool _isSaving = false;
  String? _saveError;

  final _picker = ImagePicker();
  final _profileService = ApiService();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.fullName);
    _emailCtrl = TextEditingController(text: widget.profile.email);
    _phoneCtrl = TextEditingController(
      text: widget.profile.phone?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ── Pick image ──────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
      );
      if (picked != null) {
        setState(() => _pickedImage = File(picked.path));
      }
    } catch (e) {
      // permission denied or other error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'could_not_pick_image'.tr}: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'choose_photo'.tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: context.text1,
              ),
            ),
            const SizedBox(height: 16),
            _ImageSourceTile(
              icon: Icons.camera_alt_outlined,
              label: 'take_photo'.tr,
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 10),
            _ImageSourceTile(
              icon: Icons.photo_library_outlined,
              label: 'choose_gallery'.tr,
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_pickedImage != null || widget.profile.avatar != null) ...[
              const SizedBox(height: 10),
              _ImageSourceTile(
                icon: Icons.delete_outline_rounded,
                label: 'remove_photo'.tr,
                color: const Color(0xFFEF4444),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _pickedImage = null);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Save to API ─────────────────────────────────────────────
  // Future<void> _save() async {
  //   if (_nameCtrl.text.trim().isEmpty) return;

  //   setState(() {
  //     _isSaving = true;
  //     _saveError = null;
  //   });

  //   try {
  //     final updated = await _profileService.updateProfile(
  //       name: _nameCtrl.text.trim(),
  //       email: _emailCtrl.text.trim(),
  //       phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
  //       avatarFile: _pickedImage,
  //     );

  //     if (!mounted) return;
  //     widget.onSaved(updated);
  //     Navigator.pop(context);

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: const Text('Profile updated successfully!'),
  //         backgroundColor: const Color(0xFF10B981),
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12)),
  //       ),
  //     );
  //   } catch (e) {
  //     setState(() {
  //       _isSaving = false;
  //       _saveError = 'Failed to save: $e';
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = widget.profile.avatar?.toString();

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
            'edit_profile'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: context.text1,
            ),
          ),
          const SizedBox(height: 24),

          // ── Avatar picker ─────────────────────────────────
          Center(
            child: GestureDetector(
              onTap: _showImageSourceSheet,
              child: Stack(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ClipOval(
                      child: _pickedImage != null
                          ? Image.file(_pickedImage!, fit: BoxFit.cover)
                          : (avatarUrl != null
                                ? Image.network(
                                    avatarUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _fallbackText(),
                                  )
                                : _fallbackText()),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: context.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.card, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
          Center(
            child: Text(
              'tap_change_photo'.tr,
              style: TextStyle(fontSize: 12, color: context.text2),
            ),
          ),

          const SizedBox(height: 24),

          // ── Fields ────────────────────────────────────────
          _SheetField(
            label: 'full_name'.tr,
            hint: 'your_name'.tr,
            controller: _nameCtrl,
          ),
          const SizedBox(height: 14),
          _SheetField(
            label: 'email'.tr,
            hint: 'your@email.com',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _SheetField(
            label: 'phone'.tr,
            hint: '+855 12 345 678',
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
          ),

          // ── Error ─────────────────────────────────────────
          if (_saveError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 16,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _saveError!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // SizedBox(
          //   width: double.infinity,
          //   child: ElevatedButton(
          //     onPressed: _isSaving ? null : _save,
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: context.accent,
          //       foregroundColor: Colors.white,
          //       padding: const EdgeInsets.symmetric(vertical: 15),
          //       elevation: 0,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(16),
          //       ),
          //     ),
          //     child: _isSaving
          //         ? const SizedBox(
          //             width: 20,
          //             height: 20,
          //             child: CircularProgressIndicator(
          //               strokeWidth: 2,
          //               color: Colors.white,
          //             ),
          //           )
          //         : const Text(
          //             'Save Changes',
          //             style: TextStyle(
          //                 fontSize: 15, fontWeight: FontWeight.w700),
          //           ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _fallbackText() {
    final name = widget.profile.fullName;
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ImageSourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _ImageSourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final col = color ?? context.text1;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.accentBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: col),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: col,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SHEET FIELD  (controller-based)
// ═══════════════════════════════════════════════════════════════

class _SheetField extends StatelessWidget {
  final String label, hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const _SheetField({
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType,
  });

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
          controller: controller,
          keyboardType: keyboardType,
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

// ═══════════════════════════════════════════════════════════════
// LANGUAGE SHEET
// ═══════════════════════════════════════════════════════════════

class _LanguageSheet extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;
  const _LanguageSheet({required this.selected, required this.onSelect});

  static const _languages = [
    {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
    {'name': 'ភាសាខ្មែរ', 'code': 'km', 'flag': '🇰🇭'},
    {'name': '中文', 'code': 'zh', 'flag': '🇨🇳'},
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
            'select_language'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: context.text1,
            ),
          ),
          const SizedBox(height: 16),
          ..._languages.map((lang) {
            final isSelected = lang['code'] == selected;
            return GestureDetector(
              onTap: () => onSelect(lang['code']!),
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

class _WishlistPage extends StatefulWidget {
  @override
  State<_WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<_WishlistPage> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadWishlistProducts();
  }

  Future<List<dynamic>> _loadWishlistProducts() async {
    final ids = await WishlistService().getProductIds();
    final products = <dynamic>[];

    for (final id in ids) {
      try {
        products.add(await ApiService().fetchProduct(id));
      } catch (_) {
        // Keep the rest of the wishlist visible if one product is unavailable.
      }
    }

    return products;
  }

  Future<void> _remove(dynamic product) async {
    await WishlistService().remove(product.id as int);
    if (!mounted) return;
    setState(() => _future = _loadWishlistProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: _ProfileSubAppBar(title: 'wishlist'.tr),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonList(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 32),
            );
          }

          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return _ProfileEmptyState(
              icon: Icons.favorite_border_rounded,
              color: const Color(0xFFF43F5E),
              title: 'no_saved_products'.tr,
              subtitle: 'save_product_hint'.tr,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _future = _loadWishlistProducts());
              await _future;
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: products.length,
              itemBuilder: (_, index) => _WishlistProductTile(
                product: products[index],
                onRemove: () => _remove(products[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}

// class _AddressPage extends StatefulWidget {
//   @override
//   State<_AddressPage> createState() => _AddressPageState();
// }

// class _AddressPageState extends State<_AddressPage> {
//   late Future<List<AddressHistoryEntry>> _future;

//   @override
//   void initState() {
//     super.initState();
//     _future = _loadAddresses();
//   }

//   Future<List<AddressHistoryEntry>> _loadAddresses() async {
//     final byKey = <String, AddressHistoryEntry>{};

//     for (final entry in await AddressHistoryService().loadAddresses()) {
//       byKey[_keyFor(entry)] = entry;
//     }

//     try {
//       final orders = await ApiService().fetchMyOrders();
//       for (final order in orders.orders) {
//         if (order.address.trim().isEmpty) continue;
//         final entry = AddressHistoryEntry(
//           phone: order.phone,
//           address: order.address,
//           savedAt: DateTime.tryParse(order.createdAt) ?? DateTime.now(),
//         );
//         byKey.putIfAbsent(_keyFor(entry), () => entry);
//       }
//     } catch (_) {
//       // Local history is still useful when orders cannot be loaded.
//     }

//     final addresses = byKey.values.toList()
//       ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
//     return addresses;
//   }

//   String _keyFor(AddressHistoryEntry entry) {
//     return '${entry.phone.trim().toLowerCase()}|${entry.address.trim().toLowerCase()}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: context.bg,
//       appBar: _ProfileSubAppBar(title: 'addresses'.tr),
//       body: FutureBuilder<List<AddressHistoryEntry>>(
//         future: _future,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const SkeletonList(
//               padding: EdgeInsets.fromLTRB(16, 12, 16, 32),
//               showImage: false,
//             );
//           }

//           final addresses = snapshot.data ?? [];
//           if (addresses.isEmpty) {
//             return _ProfileEmptyState(
//               icon: Icons.location_on_outlined,
//               color: const Color(0xFF10B981),
//               title: 'no_address_history'.tr,
//               subtitle: 'address_history_hint'.tr,
//             );
//           }

//           return RefreshIndicator(
//             onRefresh: () async {
//               setState(() => _future = _loadAddresses());
//               await _future;
//             },
//             child: ListView.builder(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
//               itemCount: addresses.length,
//               itemBuilder: (_, index) =>
//                   _AddressHistoryTile(entry: addresses[index]),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

class _ProfileSubAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const _ProfileSubAppBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.bg,
      foregroundColor: context.text1,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: context.text1,
        ),
      ),
    );
  }
}

class _WishlistProductTile extends StatelessWidget {
  final dynamic product;
  final VoidCallback onRemove;

  const _WishlistProductTile({required this.product, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final images = (product.images as List?) ?? [];
    final imageUrl = images.isNotEmpty ? images.first.toString() : null;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: product.id as int),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(context.isDark ? 0.22 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: imageUrl == null
                  ? _ProfileImageFallback()
                  : Image.network(
                      imageUrl,
                      width: 74,
                      height: 74,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _ProfileImageFallback(),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name?.toString() ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.text1,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CatalogTranslation.translate(product.brandName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: context.text2, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.finalPrice}',
                    style: TextStyle(
                      color: context.accent,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(
                Icons.favorite_rounded,
                color: Color(0xFFF43F5E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressHistoryTile extends StatelessWidget {
  final AddressHistoryEntry entry;

  const _AddressHistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: Color(0xFF10B981),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.address,
                  style: TextStyle(
                    color: context.text1,
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                if (entry.phone.isNotEmpty)
                  Text(
                    entry.phone,
                    style: TextStyle(color: context.text2, fontSize: 12),
                  ),
                const SizedBox(height: 4),
                Text(
                  _formatAddressDate(entry.savedAt),
                  style: TextStyle(color: context.text2, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAddressDate(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} ${two(value.hour)}:${two(value.minute)}';
  }
}

class _ProfileImageFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 74,
      color: context.accentBg,
      child: Icon(Icons.image_outlined, color: context.text2),
    );
  }
}

class _ProfileEmptyState extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _ProfileEmptyState({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.text1,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.text2, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(
    title: 'payment_methods'.tr,
    icon: Icons.credit_card_rounded,
    color: const Color(0xFFF59E0B),
    description: 'payment_methods_hint'.tr,
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
          'change_password'.tr,
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
            _SheetField(label: 'current_password'.tr, hint: '••••••••'),
            const SizedBox(height: 14),
            _SheetField(label: 'new_password'.tr, hint: '••••••••'),
            const SizedBox(height: 14),
            _SheetField(label: 'confirm_new_password'.tr, hint: '••••••••'),
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
                child: Text(
                  'update_password'.tr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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
