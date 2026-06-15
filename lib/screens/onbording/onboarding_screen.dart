import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mart_frontend/controllers/language_controller.dart';
import 'package:mart_frontend/screens/main/main_screen.dart';
import 'package:mart_frontend/screens/theme/app_theme.dart';

import 'package:shared_preferences/shared_preferences.dart';

extension _C on BuildContext {
  AppColors get c => colors;
}

// ─────────────────────────────────────────────
// ENTRY POINT
// Flow: Slide 0 → 1 → 2 → Language → MainScreen
// ─────────────────────────────────────────────
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;
  static const int _total = 4;

  // Background orb animation
  late final AnimationController _orbCtrl;
  late final Animation<double> _orbAnim;

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _orbAnim = CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _orbCtrl.dispose();
    super.dispose();
  }

  void _next() {
    // HapticFeedback.lightImpact();
    if (_page < _total - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _skipToLanguage() {
    // HapticFeedback.lightImpact();
    _pageCtrl.animateToPage(
      3,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _finish() async {
    // HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    Get.offAll(
      () => const MainScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 400),
    );
  }


  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.background,
      body: Stack(
        children: [
          // ── Animated background orbs ──
          AnimatedBuilder(
            animation: _orbAnim,
            builder: (_, __) => _BackgroundOrbs(
              progress: _orbAnim.value,
              page: _page,
              accent: c.accent,
              accentLight: c.accentLight,
              isDark: Theme.of(context).brightness == Brightness.dark,
            ),
          ),

          // ── Page content ──
          PageView(
            controller: _pageCtrl,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (i) => setState(() => _page = i),
            children: [
              _FeatureSlide(
                key: const ValueKey(0),
                pageIndex: 0,
                onNext: _next,
                onSkip: _skipToLanguage,
              ),
              _FeatureSlide(
                key: const ValueKey(1),
                pageIndex: 1,
                onNext: _next,
                onSkip: _skipToLanguage,
              ),
              _FeatureSlide(
                key: const ValueKey(2),
                pageIndex: 2,
                onNext: _next,
                onSkip: _skipToLanguage,
                isLast: true,
              ),
              LanguageOnboardingScreen(onContinue: _finish),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ANIMATED BACKGROUND ORBS
// ─────────────────────────────────────────────
class _BackgroundOrbs extends StatelessWidget {
  final double progress;
  final int page;
  final Color accent;
  final Color accentLight;
  final bool isDark;

  const _BackgroundOrbs({
    required this.progress,
    required this.page,
    required this.accent,
    required this.accentLight,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final t = progress;
    return Stack(
      children: [
        // Top-right large orb
        Positioned(
          top: -60 + (t * 40),
          right: -80 + (t * 30),
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(isDark ? 0.18 : 0.09),
            ),
          ),
        ),
        // Middle-left orb
        Positioned(
          top: size.height * 0.28 - (t * 20),
          left: -100 + (t * 20),
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(isDark ? 0.1 : 0.05),
            ),
          ),
        ),
        // Bottom-right small orb
        Positioned(
          bottom: size.height * 0.1 + (t * 30),
          right: 20 - (t * 20),
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentLight.withOpacity(isDark ? 0.15 : 0.4),
            ),
          ),
        ),
        // Tiny accent dot
        Positioned(
          top: size.height * 0.55 + (t * 15),
          left: size.width * 0.6,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(isDark ? 0.12 : 0.07),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// FEATURE SLIDE
// ─────────────────────────────────────────────
class _FeatureSlide extends StatefulWidget {
  final int pageIndex;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool isLast;

  const _FeatureSlide({
    super.key,
    required this.pageIndex,
    required this.onNext,
    required this.onSkip,
    this.isLast = false,
  });

  @override
  State<_FeatureSlide> createState() => _FeatureSlideState();
}

class _FeatureSlideState extends State<_FeatureSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconRotate;

  static const _slides = [
    _SlideData(
      icon: Icons.local_shipping_rounded,
      badge: 'FAST DELIVERY',
      title: 'Lightning-fast\nDelivery',
      subtitle:
          'Orders delivered to your doorstep in record time. Track every step live.',
      features: [
        _Feature(Icons.bolt_rounded, 'Same-day delivery'),
        _Feature(Icons.location_on_rounded, 'Live order tracking'),
        _Feature(Icons.shield_rounded, 'Secure packaging'),
      ],
    ),
    _SlideData(
      icon: Icons.local_offer_rounded,
      badge: 'BEST DEALS',
      title: 'Unbeatable\nDeals Daily',
      subtitle:
          'Flash sales, exclusive coupons, and loyalty rewards every single day.',
      features: [
        _Feature(Icons.flash_on_rounded, 'Daily flash sales'),
        _Feature(Icons.card_giftcard_rounded, 'Loyalty rewards'),
        _Feature(Icons.percent_rounded, 'Member coupons'),
      ],
    ),
    _SlideData(
      icon: Icons.storefront_rounded,
      badge: 'MILLIONS OF ITEMS',
      title: 'Everything\nin One Place',
      subtitle:
          'Groceries, gadgets, fashion and more — always in stock, always fresh.',
      features: [
        _Feature(Icons.category_rounded, '50+ categories'),
        _Feature(Icons.star_rounded, 'Verified products'),
        _Feature(Icons.headset_mic_rounded, '24/7 support'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.1, 0.9, curve: Curves.easeOutCubic),
          ),
        );
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.65, curve: Curves.elasticOut),
      ),
    );
    _iconRotate = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final slide = _slides[widget.pageIndex];
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ── Top bar: dots + skip ──
            _buildTopBar(c),

            SizedBox(height: size.height * 0.05),

            // ── Illustration ──
            Center(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => Transform.scale(
                  scale: _iconScale.value,
                  child: Transform.rotate(
                    angle: _iconRotate.value,
                    child: _IconIllustration(
                      icon: slide.icon,
                      accent: c.accent,
                      accentLight: c.accentLight,
                      isDark: Theme.of(context).brightness == Brightness.dark,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: size.height * 0.045),

            // ── Content ──
            Expanded(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: _buildContent(c, slide),
                ),
              ),
            ),

            // ── Bottom actions ──
            FadeTransition(opacity: _fade, child: _buildActions(c, slide)),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(AppColors c) {
    return Row(
      children: [
        // Logo mark
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: c.accent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.shopping_bag_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Mart',
          style: TextStyle(
            color: c.text1,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const Spacer(),
        // Progress dots
        Row(
          children: List.generate(3, (i) {
            final active = i == widget.pageIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              margin: const EdgeInsets.only(left: 5),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? c.accent : c.border,
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: widget.onSkip,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: c.surface2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.border, width: 1),
            ),
            child: Text(
              widget.isLast ? 'Language' : 'Skip',
              style: TextStyle(
                color: c.text2,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(AppColors c, _SlideData slide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: c.accentLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            slide.badge,
            style: TextStyle(
              color: c.accent,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Title
        Text(
          slide.title,
          style: TextStyle(
            color: c.text1,
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),

        // Subtitle
        Text(
          slide.subtitle,
          style: TextStyle(
            color: c.text2,
            fontSize: 15,
            height: 1.55,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 24),

        // Features
        ...slide.features.asMap().entries.map((e) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + e.key * 80),
            curve: Curves.easeOutCubic,
            builder: (_, v, child) => Opacity(
              opacity: v,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - v)),
                child: child,
              ),
            ),
            child: _FeatureChip(feature: e.value, colors: c),
          );
        }),
      ],
    );
  }

  Widget _buildActions(AppColors c, _SlideData slide) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            // Back / page indicator
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.border, width: 1),
              ),
              child: Center(
                child: Text(
                  '${widget.pageIndex + 1}/3',
                  style: TextStyle(
                    color: c.text2,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Next button
            Expanded(
              child: _NextButton(
                label: widget.isLast ? 'Choose Language' : 'Continue',
                icon: widget.isLast
                    ? Icons.language_rounded
                    : Icons.arrow_forward_rounded,
                accentColor: c.accent,
                onTap: widget.onNext,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ICON ILLUSTRATION
// ─────────────────────────────────────────────
class _IconIllustration extends StatefulWidget {
  final IconData icon;
  final Color accent;
  final Color accentLight;
  final bool isDark;

  const _IconIllustration({
    required this.icon,
    required this.accent,
    required this.accentLight,
    required this.isDark,
  });

  @override
  State<_IconIllustration> createState() => _IconIllustrationState();
}

class _IconIllustrationState extends State<_IconIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _float = Tween<double>(
      begin: -6.0,
      end: 6.0,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _float.value),
        child: SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outermost ring
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.accent.withOpacity(widget.isDark ? 0.06 : 0.04),
                  border: Border.all(
                    color: widget.accent.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              // Middle ring
              Container(
                width: 155,
                height: 155,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.accent.withOpacity(widget.isDark ? 0.1 : 0.06),
                  border: Border.all(
                    color: widget.accent.withOpacity(0.15),
                    width: 1,
                  ),
                ),
              ),
              // Inner circle (solid)
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.accent,
                  boxShadow: [
                    BoxShadow(
                      color: widget.accent.withOpacity(0.35),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 48),
              ),
              // Small decorative dots
              ..._buildOrbitDots(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOrbitDots() {
    final positions = [
      const Offset(16, 30),
      const Offset(170, 50),
      const Offset(22, 155),
      const Offset(162, 148),
    ];
    final sizes = [10.0, 8.0, 6.0, 10.0];
    return positions.asMap().entries.map((e) {
      return Positioned(
        left: e.value.dx,
        top: e.value.dy,
        child: Container(
          width: sizes[e.key],
          height: sizes[e.key],
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.accentLight.withOpacity(widget.isDark ? 0.6 : 1.0),
            border: Border.all(color: widget.accent.withOpacity(0.3), width: 1),
          ),
        ),
      );
    }).toList();
  }
}

// ─────────────────────────────────────────────
// FEATURE CHIP (horizontal pill style)
// ─────────────────────────────────────────────
class _FeatureChip extends StatelessWidget {
  final _Feature feature;
  final AppColors colors;

  const _FeatureChip({required this.feature, required this.colors});

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c.accentLight,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(feature.icon, color: c.accent, size: 17),
          ),
          const SizedBox(width: 12),
          Text(
            feature.label,
            style: TextStyle(
              color: c.text1,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Icon(Icons.check_circle_rounded, color: c.accent, size: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// NEXT BUTTON with ripple + scale
// ─────────────────────────────────────────────
class _NextButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _NextButton({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        // HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: widget.accentColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
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
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(width: 8),
              Icon(widget.icon, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LANGUAGE SCREEN
// ─────────────────────────────────────────────
class LanguageOnboardingScreen extends StatefulWidget {
  final VoidCallback? onContinue;
  const LanguageOnboardingScreen({super.key, this.onContinue});

  @override
  State<LanguageOnboardingScreen> createState() =>
      _LanguageOnboardingScreenState();
}

class _LanguageOnboardingScreenState extends State<LanguageOnboardingScreen>
    with SingleTickerProviderStateMixin {
  String _selected = 'en';
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  static const _languages = [
    _LangData(name: 'English', code: 'en', flag: '🇺🇸', sub: 'United States'),
    _LangData(name: 'ភាសាខ្មែរ', code: 'km', flag: '🇰🇭', sub: 'Cambodia'),
    _LangData(name: '中文', code: 'zh', flag: '🇨🇳', sub: 'China'),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    // HapticFeedback.mediumImpact();

    Get.find<LanguageController>().changeLanguage(_selected);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('first_time', false);

    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      Get.offAll(() => const MainScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ── Logo row ──
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Mart',
                      style: TextStyle(
                        color: c.text1,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // ── Headline ──
                Text(
                  'Almost\nthere.',
                  style: TextStyle(
                    color: c.text1,
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Pick your preferred language to get started.',
                  style: TextStyle(color: c.text2, fontSize: 15, height: 1.5),
                ),

                const SizedBox(height: 36),

                // ── Language tiles ──
                ..._languages.asMap().entries.map((e) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 350 + e.key * 80),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, child) => Opacity(
                      opacity: v,
                      child: Transform.translate(
                        offset: Offset(0, 16 * (1 - v)),
                        child: child,
                      ),
                    ),
                    child: _LanguageTile(
                      data: e.value,
                      isSelected: _selected == e.value.code,
                      colors: c,
                      onTap: () {
                        // HapticFeedback.selectionClick();

                        setState(() {
                          _selected = e.value.code;
                        });

                        Get.find<LanguageController>().changeLanguage(
                          e.value.code,
                        );
                      },
                    ),
                  );
                }),

                const Spacer(),

                // ── Info line ──
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 14, color: c.text3),
                    const SizedBox(width: 6),
                    Text(
                      'You can change language anytime in Settings',
                      style: TextStyle(fontSize: 12, color: c.text3),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Continue button ──
                _NextButton(
                  label: 'Start Shopping',
                  icon: Icons.shopping_bag_rounded,
                  accentColor: c.accent,
                  onTap: _handleContinue,
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LANGUAGE TILE
// ─────────────────────────────────────────────
class _LanguageTile extends StatelessWidget {
  final _LangData data;
  final bool isSelected;
  final AppColors colors;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.data,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 230),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? c.accentLight : c.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? c.accent : c.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? c.accent.withOpacity(0.12)
                  : Colors.black.withOpacity(0.03),
              blurRadius: isSelected ? 16 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Flag
            AnimatedContainer(
              duration: const Duration(milliseconds: 230),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.7) : c.surface2,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: Text(data.flag, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),

            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    style: TextStyle(
                      color: c.text1,
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.sub,
                    style: TextStyle(
                      color: isSelected ? c.accent : c.text3,
                      fontSize: 12,
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
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: isSelected
                  ? Container(
                      key: const ValueKey('on'),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: c.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: c.accent.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    )
                  : Container(
                      key: const ValueKey('off'),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: c.border, width: 1.5),
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
// DATA MODELS
// ─────────────────────────────────────────────
class _SlideData {
  final IconData icon;
  final String badge;
  final String title;
  final String subtitle;
  final List<_Feature> features;

  const _SlideData({
    required this.icon,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.features,
  });
}

class _Feature {
  final IconData icon;
  final String label;
  const _Feature(this.icon, this.label);
}

class _LangData {
  final String name;
  final String code;
  final String flag;
  final String sub;
  const _LangData({
    required this.name,
    required this.code,
    required this.flag,
    required this.sub,
  });
}
