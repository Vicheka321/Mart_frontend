// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mart_frontend/screens/main/main_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class LanguageOnboardingScreen extends StatelessWidget {
//   LanguageOnboardingScreen({super.key});

//   final selectedLang = 'en'.obs;

//   final languages = [
//     {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
//     {'name': 'ភាសាខ្មែរ', 'code': 'km', 'flag': '🇰🇭'},
//     {'name': '中文', 'code': 'zh', 'flag': '🇨🇳'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,

//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF8B7CF6), Color(0xFF6D5DF6)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),

//         child: SafeArea(
//           child: Column(
//             children: [
//               const SizedBox(height: 40),

//               const Icon(Icons.shopping_bag, size: 80, color: Colors.white),

//               const SizedBox(height: 20),

//               const Text(
//                 "Welcome to Mart",
//                 style: TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),

//               const SizedBox(height: 8),

//               const Text(
//                 "Shop smarter, faster, easier",
//                 style: TextStyle(color: Colors.white70),
//               ),

//               const SizedBox(height: 40),

//               Expanded(
//                 child: Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.vertical(
//                       top: Radius.circular(30),
//                     ),
//                   ),

//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         "🌍 Select Language",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       Obx(
//                         () => Column(
//                           children: languages.map((lang) {
//                             final isSelected =
//                                 selectedLang.value == lang['code'];

//                             return GestureDetector(
//                               onTap: () {
//                                 selectedLang.value = lang['code']!;
//                               },
//                               child: Container(
//                                 margin: const EdgeInsets.only(bottom: 12),
//                                 padding: const EdgeInsets.all(16),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(16),
//                                   border: Border.all(
//                                     color: isSelected
//                                         ? const Color(0xFF8B7CF6)
//                                         : Colors.grey.shade300,
//                                     width: isSelected ? 2 : 1,
//                                   ),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Text(
//                                       lang['flag']!,
//                                       style: const TextStyle(fontSize: 24),
//                                     ),
//                                     const SizedBox(width: 12),
//                                     Text(
//                                       lang['name']!,
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: isSelected
//                                             ? FontWeight.bold
//                                             : FontWeight.normal,
//                                       ),
//                                     ),
//                                     const Spacer(),
//                                     if (isSelected)
//                                       const Icon(
//                                         Icons.check_circle,
//                                         color: Color(0xFF8B7CF6),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                       ),

//                       const Spacer(),

//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             final prefs = await SharedPreferences.getInstance();

//                             await prefs.setString(
//                               'language',
//                               selectedLang.value,
//                             );
//                             await prefs.setBool('first_time', false);

//                             Get.offAll(() => const MainScreen());
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF8B7CF6),
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14),
//                             ),
//                           ),
//                           child: const Text(
//                             "Continue",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 10),

//                       const Center(
//                         child: Text(
//                           "You can change language later",
//                           style: TextStyle(fontSize: 12, color: Colors.grey),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mart_frontend/screens/main/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Replace with your actual imports ──
// import 'package:mart_frontend/screens/main/main_screen.dart';

// ─────────────────────────────────────────────
// ONBOARDING ENTRY POINT
// Manages page flow: Language → About Mart (3 slides) → Done
// ─────────────────────────────────────────────

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _pageCtrl = PageController();
  int _page = 0; // 0 = language, 1-3 = about slides

  static const int _totalPages = 4;

  void _next() {
    HapticFeedback.lightImpact();
    if (_page < _totalPages - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _page = i),
        children: [
          // ── Page 0: Language ──────────────────────

          // ── Pages 1-3: About Mart slides ──────────
          _AboutSlide(
            pageIndex: 0,
            currentPage: _page - 1,
            onNext: _next,
            onSkip: _finish,
          ),
          _AboutSlide(
            pageIndex: 1,
            currentPage: _page - 1,
            onNext: _next,
            onSkip: _finish,
          ),
          _AboutSlide(
            pageIndex: 2,
            currentPage: _page - 1,
            onNext: _finish,
            onSkip: _finish,
            isLast: true,
          ),

          LanguageOnboardingScreen(onContinue: _next),
        ],
      ),
    );
  }

  Future<void> _finish() async {
    HapticFeedback.heavyImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    Get.offAll(() => const MainScreen());
  }
}

// ─────────────────────────────────────────────
// LANGUAGE SCREEN (redesigned, same logic)
// ─────────────────────────────────────────────

class LanguageOnboardingScreen extends StatefulWidget {
  final VoidCallback?
  onContinue; // null = standalone mode (saves & goes to main)

  const LanguageOnboardingScreen({super.key, this.onContinue});

  @override
  State<LanguageOnboardingScreen> createState() =>
      _LanguageOnboardingScreenState();
}

class _LanguageOnboardingScreenState extends State<LanguageOnboardingScreen>
    with SingleTickerProviderStateMixin {
  String _selected = 'en';
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  static const _languages = [
    {'name': 'English', 'code': 'en', 'flag': '🇺🇸', 'sub': 'United States'},
    {'name': 'ភាសាខ្មែរ', 'code': 'km', 'flag': '🇰🇭', 'sub': 'Cambodia'},
    {'name': '中文', 'code': 'zh', 'flag': '🇨🇳', 'sub': 'China'},
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selected);
    await prefs.setBool('first_time', false);

    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      Get.offAll(() => const MainScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background gradient ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1D4ED8),
                  Color(0xFF2563EB),
                  Color(0xFF60A5FA),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ── Decorative circles ──
          ..._buildDecoCircles(),

          SafeArea(
            child: Column(
              children: [
                // ── Top hero area ──
                Expanded(
                  flex: 4,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: _buildHero(),
                  ),
                ),

                // ── Bottom card ──
                Expanded(
                  flex: 6,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _buildCard(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDecoCircles() {
    return [
      Positioned(
        top: -60,
        right: -40,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.06),
          ),
        ),
      ),
      Positioned(
        top: 80,
        left: -60,
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
    ];
  }

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo badge
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: Colors.white.withOpacity(0.35),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                size: 42,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Welcome to\nMart',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Shop smarter, faster, easier',
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Label ──
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    color: Color(0xFF2563EB),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Choose your language',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.only(left: 42),
              child: Text(
                'You can change this later in settings',
                style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
            ),

            const SizedBox(height: 22),

            // ── Language tiles ──
            ..._languages.map(
              (lang) => _LanguageTile(
                flag: lang['flag']!,
                name: lang['name']!,
                subtitle: lang['sub']!,
                code: lang['code']!,
                isSelected: _selected == lang['code'],
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selected = lang['code']!);
                },
              ),
            ),

            const Spacer(),

            // ── Continue button ──
            _GradientButton(
              label: 'Continue',
              icon: Icons.arrow_forward_rounded,
              onTap: _handleContinue,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String flag, name, subtitle, code;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.flag,
    required this.name,
    required this.subtitle,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDBEAFE) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Flag
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.7)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(flag, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: const Color(0xFF111827),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF9CA3AF),
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Check
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? Container(
                      key: const ValueKey('check'),
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    )
                  : Container(
                      key: const ValueKey('empty'),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1.5,
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

// ─────────────────────────────────────────────
// ABOUT MART SLIDES
// ─────────────────────────────────────────────

class _AboutSlide extends StatefulWidget {
  final int pageIndex; // 0, 1, 2
  final int currentPage; // which page is currently active (for dots)
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool isLast;

  const _AboutSlide({
    required this.pageIndex,
    required this.currentPage,
    required this.onNext,
    required this.onSkip,
    this.isLast = false,
  });

  @override
  State<_AboutSlide> createState() => _AboutSlideState();
}

class _AboutSlideState extends State<_AboutSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _scaleAnim;

  static const _slides = [
    _SlideData(
      gradient: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
      icon: Icons.local_shipping_rounded,
      badge: 'FAST DELIVERY',
      badgeColor: Color(0xFF60A5FA),
      title: 'Lightning-fast\nDelivery',
      subtitle:
          'Get your orders delivered to your doorstep in record time. Track every step in real-time.',
      features: [
        _Feature(Icons.bolt_rounded, 'Same-day delivery available'),
        _Feature(Icons.location_on_rounded, 'Live order tracking'),
        _Feature(Icons.shield_rounded, 'Safe & secure packaging'),
      ],
      illustrationIcon: Icons.local_shipping_rounded,
    ),
    _SlideData(
      gradient: [Color(0xFF7C3AED), Color(0xFFA855F7)],
      icon: Icons.percent_rounded,
      badge: 'BEST DEALS',
      badgeColor: Color(0xFFC084FC),
      title: 'Unbeatable\nDeals Daily',
      subtitle:
          'Flash sales, exclusive coupons, and loyalty rewards — save more every time you shop.',
      features: [
        _Feature(Icons.flash_on_rounded, 'Daily flash sales'),
        _Feature(Icons.card_giftcard_rounded, 'Loyalty rewards points'),
        _Feature(Icons.local_offer_rounded, 'Exclusive member coupons'),
      ],
      illustrationIcon: Icons.percent_rounded,
    ),
    _SlideData(
      gradient: [Color(0xFF059669), Color(0xFF10B981)],
      icon: Icons.storefront_rounded,
      badge: 'MILLIONS OF ITEMS',
      badgeColor: Color(0xFF34D399),
      title: 'Everything\nin One Place',
      subtitle:
          'From electronics to fashion, groceries to gadgets — Mart has it all, always in stock.',
      features: [
        _Feature(Icons.category_rounded, '50+ product categories'),
        _Feature(Icons.star_rounded, 'Verified quality products'),
        _Feature(Icons.headset_mic_rounded, '24/7 customer support'),
      ],
      illustrationIcon: Icons.storefront_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[widget.pageIndex];
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Gradient background ──
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: slide.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ── Background decoration ──
          ..._buildBgDeco(slide),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar: Skip + Dots ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      // Progress dots
                      Row(
                        children: List.generate(3, (i) {
                          final active = i == widget.pageIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 6),
                            width: active ? 24 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          );
                        }),
                      ),
                      const Spacer(),
                      if (!widget.isLast)
                        GestureDetector(
                          onTap: widget.onSkip,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Illustration ──
                Expanded(
                  flex: 5,
                  child: Center(
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: _IllustrationArea(slide: slide),
                    ),
                  ),
                ),

                // ── Bottom card ──
                Expanded(
                  flex: 6,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _buildBottomCard(slide),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBgDeco(_SlideData slide) {
    return [
      Positioned(
        top: -80,
        right: -60,
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.06),
          ),
        ),
      ),
      Positioned(
        bottom: MediaQuery.of(context).size.height * 0.35,
        left: -80,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
    ];
  }

  Widget _buildBottomCard(_SlideData slide) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: slide.badgeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                slide.badge,
                style: TextStyle(
                  color: slide.gradient.first,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              slide.title,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                height: 1.15,
              ),
            ),

            const SizedBox(height: 10),

            // Subtitle
            Text(
              slide.subtitle,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                height: 1.55,
              ),
            ),

            const SizedBox(height: 20),

            // Feature list
            ...slide.features.map(
              (f) => _FeatureRow(feature: f, accentColor: slide.gradient.first),
            ),

            const Spacer(),

            // CTA button
            _GradientButton(
              label: widget.isLast ? 'Get Started' : 'Next',
              icon: widget.isLast
                  ? Icons.shopping_bag_rounded
                  : Icons.arrow_forward_rounded,
              onTap: widget.onNext,
              gradientColors: slide.gradient,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _IllustrationArea extends StatelessWidget {
  final _SlideData slide;
  const _IllustrationArea({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Outer ring
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Center(
            // Inner badge
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                slide.illustrationIcon,
                size: 54,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Floating stat pills
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatPill(label: '2M+', sub: 'Products'),
            const SizedBox(width: 12),
            _StatPill(label: '98%', sub: 'Satisfaction'),
            const SizedBox(width: 12),
            _StatPill(label: '50+', sub: 'Categories'),
          ],
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String sub;
  const _StatPill({required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final _Feature feature;
  final Color accentColor;

  const _FeatureRow({required this.feature, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(feature.icon, color: accentColor, size: 17),
          ),
          const SizedBox(width: 12),
          Text(
            feature.label,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// GRADIENT BUTTON (shared)
// ─────────────────────────────────────────────

class _GradientButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final List<Color>? gradientColors;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.gradientColors,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        widget.gradientColors ??
        [const Color(0xFF2563EB), const Color(0xFF60A5FA)];

    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: colors.first.withOpacity(0.38),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 8),
              Icon(widget.icon, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODELS (immutable config)
// ─────────────────────────────────────────────

class _SlideData {
  final List<Color> gradient;
  final IconData icon;
  final String badge;
  final Color badgeColor;
  final String title;
  final String subtitle;
  final List<_Feature> features;
  final IconData illustrationIcon;

  const _SlideData({
    required this.gradient,
    required this.icon,
    required this.badge,
    required this.badgeColor,
    required this.title,
    required this.subtitle,
    required this.features,
    required this.illustrationIcon,
  });
}

class _Feature {
  final IconData icon;
  final String label;

  const _Feature(this.icon, this.label);
}
