import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mart_frontend/providers/ProductDetailProvider.dart';
import 'package:mart_frontend/providers/banner_provider.dart';
import 'package:mart_frontend/providers/best_seller_provider.dart';
import 'package:mart_frontend/providers/brands_provider.dart';
import 'package:mart_frontend/providers/cart_provider.dart';
import 'package:mart_frontend/providers/category_provider.dart';
import 'package:mart_frontend/providers/new_arrival_provider.dart';
import 'package:mart_frontend/providers/profile_provider.dart';
import 'package:mart_frontend/providers/recommend_provider.dart';
import 'package:mart_frontend/screens/onbording/onboarding_screen.dart';
import 'package:mart_frontend/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'dart:ui';

import '../main/main_screen.dart';
import '../theme/app_theme.dart';

// ── AppColors (paste your existing file or keep inline) ──────────────────────

extension AppThemeExt on BuildContext {
  AppColors get colors {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  }
}

// ── Entry point ───────────────────────────────────────────────────────────────

void main() => runApp(const MartApp());

class MartApp extends StatelessWidget {
  const MartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light),
      home: const SplashScreen(),
    );
  }
}

// ── SplashScreen ──────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Master sequencer
  late final AnimationController _master;

  // Individual controllers
  late final AnimationController _blobCtrl; // looping blob float
  late final AnimationController _ringCtrl; // looping pulse rings
  late final AnimationController _cardCtrl; // looping card float
  late final AnimationController _badgeCtrl; // looping blink

  // ── Master-driven animations ──────────────────────────────────────────────

  // Logo
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoRingScale;
  late final Animation<double> _logoRingOpacity;

  // Brand text
  late final Animation<Offset> _brandSlide;
  late final Animation<double> _brandOpacity;

  // Tagline
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _taglineOpacity;

  // Pills
  late final Animation<Offset> _pillsSlide;
  late final Animation<double> _pillsOpacity;

  // Cards
  late final Animation<double> _card1Opacity;
  late final Animation<double> _card2Opacity;
  late final Animation<double> _card3Opacity;
  late final Animation<double> _card1Scale;
  late final Animation<double> _card2Scale;
  late final Animation<double> _card3Scale;

  // Badges
  late final Animation<double> _saleBadgeOpacity;
  late final Animation<double> _newBadgeOpacity;
  late final Animation<double> _cartBadgeScale;

  // Progress
  late final Animation<double> _progress;

  // Loader text
  late final Animation<double> _loaderOpacity;

  @override
  void initState() {
    super.initState();

    // Master: 3 s one-shot drive
    _master = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Looping controllers
    _blobCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _badgeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // ── Wire master animations ──────────────────────────────────────────────

    _logoScale = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.10, 0.35, curve: Curves.elasticOut),
      ),
    );
    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.10, 0.25, curve: Curves.easeOut),
      ),
    );

    _logoRingScale = Tween(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _master, curve: const Interval(0.40, 1.0)),
    );
    _logoRingOpacity =
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _master, curve: const Interval(0.40, 0.75)),
        );

    _brandSlide = Tween(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.20, 0.45, curve: Curves.easeOutCubic),
      ),
    );
    _brandOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.20, 0.40, curve: Curves.easeOut),
      ),
    );

    _taglineSlide = Tween(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _master,
            curve: const Interval(0.28, 0.50, curve: Curves.easeOutCubic),
          ),
        );
    _taglineOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.28, 0.48, curve: Curves.easeOut),
      ),
    );

    _pillsSlide = Tween(begin: const Offset(0, 0.6), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.36, 0.58, curve: Curves.easeOutCubic),
      ),
    );
    _pillsOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.36, 0.55, curve: Curves.easeOut),
      ),
    );

    // Cards (staggered)
    _card1Opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _master, curve: const Interval(0.43, 0.58)),
    );
    _card1Scale = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.43, 0.60, curve: Curves.easeOutBack),
      ),
    );
    _card2Opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _master, curve: const Interval(0.50, 0.65)),
    );
    _card2Scale = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.50, 0.67, curve: Curves.easeOutBack),
      ),
    );
    _card3Opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _master, curve: const Interval(0.57, 0.72)),
    );
    _card3Scale = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.57, 0.74, curve: Curves.easeOutBack),
      ),
    );

    // Sale / New badges
    _saleBadgeOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _master, curve: const Interval(0.65, 0.80)),
    );
    _newBadgeOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _master, curve: const Interval(0.70, 0.85)),
    );
    _cartBadgeScale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.60, 0.72, curve: Curves.elasticOut),
      ),
    );

    // Progress bar
    _progress =
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.35), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 0.35, end: 0.65), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 0.65, end: 0.88), weight: 25),
          TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.00), weight: 15),
        ]).animate(
          CurvedAnimation(
            parent: _master,
            curve: const Interval(0.38, 1.0, curve: Curves.easeInOut),
          ),
        );

    _loaderOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _master, curve: const Interval(0.36, 0.50)),
    );

    _master.forward().whenComplete(() {
      Future.delayed(const Duration(milliseconds: 500), () async {
        if (!mounted) return;

        final prefs = await SharedPreferences.getInstance();
        final language = prefs.getString('language');

        if (language == null) {
          final loggedIn = await ApiService().isLoggedIn();

          final profileProvider = context.read<ProfileProvider>();

          if (loggedIn) {
            await profileProvider.loadCache();

            if (profileProvider.profile == null) {
              await profileProvider.fetchProfile();
            }

            final avatar = profileProvider.profile?.avatar;

            if (avatar?.isNotEmpty == true) {
              await precacheImage(CachedNetworkImageProvider(avatar!), context);
            }
          } else {
            await profileProvider.loadGuestProfile();

            final avatar = profileProvider.profile?.avatar;

            if (avatar?.isNotEmpty == true) {
              await precacheImage(CachedNetworkImageProvider(avatar!), context);
            }
          }

          await context.read<BannerProvider>().loadCache();
          await context.read<CategoryProvider>().loadCache();
          await context.read<BestSellerProvider>().loadCache();
          await context.read<NewArrivalsProvider>().loadCache();
          await context.read<RecommendProvider>().loadCache();
          // await context.read<CartProvider>().fetchCart();

          final bannerProvider = context.read<BannerProvider>();
          final categoryProvider = context.read<CategoryProvider>();
          final bestSellerProvider = context.read<BestSellerProvider>();
          final newArrivalProvider = context.read<NewArrivalsProvider>();
          final recommendProvider = context.read<RecommendProvider>();
          // final cartProvider = context.read<CartProvider>();

          if (bannerProvider.banners.isEmpty) {
            await bannerProvider.fetchBanners();
          }

          if (categoryProvider.categories.isEmpty) {
            await categoryProvider.fetchCategories();
          }

          if (bestSellerProvider.products.isEmpty) {
            await bestSellerProvider.fetchBestSellers();
          }

          if (newArrivalProvider.products.isEmpty) {
            await newArrivalProvider.fetchNewArrivals();
          }

          if (recommendProvider.recommended.isEmpty) {
            await recommendProvider.fetchRecommended();
          }

          // if (cartProvider.cart == null) {
          //   await cartProvider.fetchCart();
          // }

          for (final banner in bannerProvider.banners.take(5)) {
            await precacheImage(
              CachedNetworkImageProvider(banner.imageUrl),
              context,
            );
          }

          for (final category in categoryProvider.categories.take(5)) {
            if (category.image.isNotEmpty) {
              await precacheImage(
                CachedNetworkImageProvider(category.image),
                context,
              );
            }
          }

          for (final product in bestSellerProvider.products.take(3)) {
            if (product.images.isNotEmpty) {
              await precacheImage(
                CachedNetworkImageProvider(product.images.first),
                context,
              );
            }
          }

          for (final product in newArrivalProvider.products.take(3)) {
            if (product.images.isNotEmpty) {
              await precacheImage(
                CachedNetworkImageProvider(product.images.first),
                context,
              );
            }
          }

          for (final product in recommendProvider.recommended.take(2)) {
            if (product.images.isNotEmpty) {
              await precacheImage(
                CachedNetworkImageProvider(product.images.first),
                context,
              );
            }
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => OnboardingFlow()),
          );
        } else {
          final loggedIn = await ApiService().isLoggedIn();

          final profileProvider = context.read<ProfileProvider>();

          if (loggedIn) {
            await profileProvider.loadCache();

            if (profileProvider.profile == null) {
              await profileProvider.fetchProfile();
            }

            final avatar = profileProvider.profile?.avatar;

            if (avatar?.isNotEmpty == true) {
              await precacheImage(CachedNetworkImageProvider(avatar!), context);
            }
          } else {
            await profileProvider.loadGuestProfile();

            final avatar = profileProvider.profile?.avatar;

            if (avatar?.isNotEmpty == true) {
              await precacheImage(CachedNetworkImageProvider(avatar!), context);
            }
          }

          await context.read<BannerProvider>().loadCache();
          await context.read<CategoryProvider>().loadCache();
          await context.read<BestSellerProvider>().loadCache();
          await context.read<NewArrivalsProvider>().loadCache();
          await context.read<RecommendProvider>().loadCache();
          // await context.read<CartProvider>().fetchCart();

          final bannerProvider = context.read<BannerProvider>();
          final categoryProvider = context.read<CategoryProvider>();
          final bestSellerProvider = context.read<BestSellerProvider>();
          final newArrivalProvider = context.read<NewArrivalsProvider>();
          final recommendProvider = context.read<RecommendProvider>();
          // final cartProvider = context.read<CartProvider>();

          if (bannerProvider.banners.isEmpty) {
            await bannerProvider.fetchBanners();
          }

          if (categoryProvider.categories.isEmpty) {
            await categoryProvider.fetchCategories();
          }

          if (bestSellerProvider.products.isEmpty) {
            await bestSellerProvider.fetchBestSellers();
          }

          if (newArrivalProvider.products.isEmpty) {
            await newArrivalProvider.fetchNewArrivals();
          }

          if (recommendProvider.recommended.isEmpty) {
            await recommendProvider.fetchRecommended();
          }

          // if (cartProvider.cart == null) {
          //   await cartProvider.fetchCart();
          // }

          for (final banner in bannerProvider.banners.take(5)) {
            await precacheImage(
              CachedNetworkImageProvider(banner.imageUrl),
              context,
            );
          }

          for (final category in categoryProvider.categories.take(5)) {
            if (category.image.isNotEmpty) {
              await precacheImage(
                CachedNetworkImageProvider(category.image),
                context,
              );
            }
          }

          for (final product in bestSellerProvider.products.take(3)) {
            if (product.images.isNotEmpty) {
              await precacheImage(
                CachedNetworkImageProvider(product.images.first),
                context,
              );
            }
          }

          for (final product in newArrivalProvider.products.take(3)) {
            if (product.images.isNotEmpty) {
               await precacheImage(
                CachedNetworkImageProvider(product.images.first),
                context,
              );
            }
          }

          for (final product in recommendProvider.recommended.take(2)) {
            if (product.images.isNotEmpty) {
              precacheImage(
                CachedNetworkImageProvider(product.images.first),
                context,
              );
            }
          }

          // for (final p in bestSellerProvider.products.take(3)) {
          //   await context.read<ProductDetailProvider>().preload(p.id);
          // }

          // for (final p in newArrivalProvider.products.take(3)) {
          //   await context.read<ProductDetailProvider>().preload(p.id);
          // }

          // for (final p in cartProvider.cart!.items.take(3)) {
          //   await context.read<ProductDetailProvider>().preload(p.productId);
          // }

          // for (final p in recommendProvider.recommended.take(5)) {
          //   await context.read<ProductDetailProvider>().preload(p.id);
          // }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainScreen()),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _master.dispose();
    _blobCtrl.dispose();
    _ringCtrl.dispose();
    _cardCtrl.dispose();
    _badgeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppThemeExt(context).colors;
    return Scaffold(
      backgroundColor: c.surface,
      body: Stack(
        children: [
          // ── Animated blobs ───────────────────────────────────────────────
          _AnimatedBlob(
            ctrl: _blobCtrl,
            color: c.accent,
            size: 280,
            top: -80,
            right: -60,
            delay: 0,
          ),
          _AnimatedBlob(
            ctrl: _blobCtrl,
            color: Colors.green,
            size: 200,
            bottom: 60,
            left: -40,
            delay: 0.33,
          ),
          _AnimatedBlob(
            ctrl: _blobCtrl,
            color: c.accent,
            size: 150,
            bottom: 200,
            right: -30,
            delay: 0.66,
          ),

          // ── Grid overlay ──────────────────────────────────────────────────
          const _GridOverlay(),

          // ── Pulse rings ───────────────────────────────────────────────────
          Center(child: _PulseRings(ctrl: _ringCtrl)),

          // ── SALE badge ────────────────────────────────────────────────────
          Positioned(
            top: 96,
            left: 24,
            child: FadeTransition(
              opacity: _saleBadgeOpacity,
              child: _TagBadge(
                label: 'SALE',
                bg: c.flashBg,
                border: c.flashBorder,
                textColor: c.flashText,
              ),
            ),
          ),

          // ── NEW badge ─────────────────────────────────────────────────────
          Positioned(
            top: 96,
            right: 24,
            child: FadeTransition(
              opacity: _newBadgeOpacity,
              child: _TagBadge(
                label: 'NEW',
                bg: c.accent,
                textColor: Colors.white,
              ),
            ),
          ),

          // ── Floating product card 1 (left) ────────────────────────────────
          Positioned(
            left: 18,
            top: 175,
            child: _FloatingCard(
              masterOpacity: _card1Opacity,
              masterScale: _card1Scale,
              floatCtrl: _cardCtrl,
              floatOffset: -8.0,
              floatDelay: 0.5,
              badgeCtrl: _badgeCtrl,
              cartBadgeScale: _cartBadgeScale,
              showBadge: true,
              emoji: '🥑',
              name: 'Organic Avocado',
              price: '\$2.49',
              colors: c,
            ),
          ),

          // ── Floating product card 2 (right) ───────────────────────────────
          Positioned(
            right: 18,
            top: 260,
            child: _FloatingCard(
              masterOpacity: _card2Opacity,
              masterScale: _card2Scale,
              floatCtrl: _cardCtrl,
              floatOffset: -7.0,
              floatDelay: 0.6,
              emoji: '🧴',
              name: 'Daily Moisturizer',
              price: '\$14.99',
              colors: c,
            ),
          ),

          // ── Floating product card 3 (bottom-left) ────────────────────────
          Positioned(
            left: 32,
            bottom: 170,
            child: _FloatingCard(
              masterOpacity: _card3Opacity,
              masterScale: _card3Scale,
              floatCtrl: _cardCtrl,
              floatOffset: -6.0,
              floatDelay: 0.4,
              emoji: '☕',
              name: 'Ground Espresso',
              price: '\$11.50',
              colors: c,
            ),
          ),

          // ── Center content ────────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo mark
                AnimatedBuilder(
                  animation: _master,
                  builder: (_, __) => Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: _LogoMark(
                        ringScale: _logoRingScale.value,
                        ringOpacity: _logoRingOpacity.value,
                        color: c.text1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Brand name
                AnimatedBuilder(
                  animation: _master,
                  builder: (_, __) => FractionalTranslation(
                    translation: _brandSlide.value,
                    child: Opacity(
                      opacity: _brandOpacity.value,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'mart',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 52,
                                fontWeight: FontWeight.w700,
                                color: c.text1,
                                letterSpacing: -2,
                                height: 1,
                              ),
                            ),
                            TextSpan(
                              text: '.',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 52,
                                fontWeight: FontWeight.w700,
                                color: c.accent,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Tagline
                AnimatedBuilder(
                  animation: _master,
                  builder: (_, __) => FractionalTranslation(
                    translation: _taglineSlide.value,
                    child: Opacity(
                      opacity: _taglineOpacity.value,
                      child: Text(
                        'YOUR EVERYDAY MARKETPLACE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w300,
                          color: c.text2,
                          letterSpacing: 3.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Pills
                AnimatedBuilder(
                  animation: _master,
                  builder: (_, __) => FractionalTranslation(
                    translation: _pillsSlide.value,
                    child: Opacity(
                      opacity: _pillsOpacity.value,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _Pill(
                            label: 'Fresh',
                            bg: c.text1,
                            textColor: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          _Pill(
                            label: 'Fast Delivery',
                            bg: c.accentLight,
                            textColor: const Color(0xFF3949AB),
                          ),
                          const SizedBox(width: 8),
                          _Pill(
                            label: 'Local',
                            bg: Colors.transparent,
                            textColor: c.text2,
                            bordered: true,
                            borderColor: c.text1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Progress bar + loader text ────────────────────────────────────
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _master,
              builder: (_, __) => Opacity(
                opacity: _loaderOpacity.value,
                child: Column(
                  children: [
                    // Progress bar
                    Center(
                      child: SizedBox(
                        width: 140,
                        height: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: _progress.value,
                            backgroundColor: c.text1.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(c.text1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Blinking loader label
                    AnimatedBuilder(
                      animation: _badgeCtrl,
                      builder: (_, __) => Opacity(
                        opacity: 0.4 + 0.6 * _badgeCtrl.value,
                        child: Text(
                          'LOADING YOUR STORE',
                          style: TextStyle(
                            fontSize: 11,
                            color: c.text3,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w400,
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

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _AnimatedBlob extends StatelessWidget {
  final AnimationController ctrl;
  final Color color;
  final double size;
  final double? top, bottom, left, right;
  final double delay; // 0..1

  const _AnimatedBlob({
    required this.ctrl,
    required this.color,
    required this.size,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: AnimatedBuilder(
        animation: ctrl,
        builder: (_, __) {
          final t = ((ctrl.value + delay) % 1.0);
          final dy = math.sin(t * math.pi) * -20;
          return Transform.translate(
            offset: Offset(0, dy),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.18),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox.expand(),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Lightweight stand-in for ImageFilter.blur without dart:ui import issues.

class _GridOverlay extends StatelessWidget {
  const _GridOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: CustomPaint(painter: _GridPainter()));
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.025)
      ..strokeWidth = 0.5;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

class _PulseRings extends StatelessWidget {
  final AnimationController ctrl;
  const _PulseRings({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => CustomPaint(
        size: const Size(420, 420),
        painter: _RingsPainter(ctrl.value),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  final double t;
  const _RingsPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radii = [110.0, 160.0, 210.0];
    const delays = [0.0, 0.33, 0.66];

    for (int i = 0; i < 3; i++) {
      final progress = (t + delays[i]) % 1.0;
      final opacity = (1.0 - progress) * 0.5;
      final scale = 0.85 + 0.15 * progress;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = const Color(0xFF3949AB).withOpacity(opacity * 0.5);
      canvas.drawCircle(center, radii[i] * scale, paint);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) => old.t != t;
}

class _LogoMark extends StatelessWidget {
  final double ringScale, ringOpacity;
  final Color color;

  const _LogoMark({
    required this.ringScale,
    required this.ringOpacity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring halo
          Transform.scale(
            scale: ringScale,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: color.withOpacity(0.15 * ringOpacity),
                  width: 1.5,
                ),
              ),
            ),
          ),
          // Logo box
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.22),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(child: _BagIcon()),
          ),
        ],
      ),
    );
  }
}

class _BagIcon extends StatelessWidget {
  const _BagIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(44, 44), painter: _BagPainter());
  }
}

class _BagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Bag body
    final bagPath = Path()
      ..moveTo(10, 14)
      ..lineTo(34, 14)
      ..lineTo(31, 32)
      ..lineTo(13, 32)
      ..close();
    canvas.drawPath(bagPath, paint);

    // Handle
    final handlePath = Path()
      ..moveTo(17, 14)
      ..cubicTo(17, 8, 27, 8, 27, 14);
    canvas.drawPath(handlePath, paint);

    // Bag strap top (left side of handle base)
    canvas.drawLine(const Offset(10, 14), const Offset(8, 8), paint);

    // Wheels (circles at bottom)
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(17, 33), 2, dotPaint);
    canvas.drawCircle(const Offset(27, 33), 2, dotPaint);

    // Interior lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.45)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(14, 22), const Offset(30, 22), linePaint);
    final linePaint2 = Paint()
      ..color = Colors.white.withOpacity(0.28)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(15, 27), const Offset(29, 27), linePaint2);
  }

  @override
  bool shouldRepaint(_BagPainter old) => false;
}

class _TagBadge extends StatelessWidget {
  final String label;
  final Color bg, textColor;
  final Color? border;

  const _TagBadge({
    required this.label,
    required this.bg,
    required this.textColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: border != null ? Border.all(color: border!, width: 0.5) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
          color: textColor,
        ),
      ),
    );
  }
}

class _FloatingCard extends StatelessWidget {
  final Animation<double> masterOpacity, masterScale;
  final AnimationController floatCtrl;
  final double floatOffset, floatDelay;
  final AnimationController? badgeCtrl;
  final Animation<double>? cartBadgeScale;
  final bool showBadge;
  final String emoji, name, price;
  final AppColors colors;

  const _FloatingCard({
    required this.masterOpacity,
    required this.masterScale,
    required this.floatCtrl,
    required this.floatOffset,
    required this.floatDelay,
    this.badgeCtrl,
    this.cartBadgeScale,
    this.showBadge = false,
    required this.emoji,
    required this.name,
    required this.price,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([masterOpacity, floatCtrl]),
      builder: (_, __) {
        final floatT = ((floatCtrl.value + floatDelay) % 1.0);
        final dy = math.sin(floatT * math.pi) * floatOffset;
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(
            scale: masterScale.value,
            child: Opacity(
              opacity: masterOpacity.value,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.black.withOpacity(0.06),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: colors.text1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              price,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: colors.accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (showBadge && cartBadgeScale != null)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: AnimatedBuilder(
                        animation: cartBadgeScale!,
                        builder: (_, __) => Transform.scale(
                          scale: cartBadgeScale!.value,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE24B4A),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.surface,
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '3',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color bg, textColor;
  final bool bordered;
  final Color? borderColor;

  const _Pill({
    required this.label,
    required this.bg,
    required this.textColor,
    this.bordered = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: bordered
            ? Border.all(
                color: borderColor?.withOpacity(0.2) ?? Colors.grey,
                width: 1,
              )
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: textColor,
        ),
      ),
    );
  }
}

// ── Stub ImageFilter so the file compiles with_AnimatedBlobout dart:ui directly ─────────────
// Flutter's ImageFilter is from dart:ui — already available via flutter/material.dart
// The _BlurFilter stub above is unused; remove it and use BackdropFilter properly:

// Replace _AnimatedBlob's BackdropFilter child with a plain Container
// (blur on solid color blobs is optional — blobs look fine without it)
