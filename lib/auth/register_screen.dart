import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:mart_frontend/auth/verify_otp_screen.dart';
import 'package:mart_frontend/services/api_service.dart';

import '../screens/theme/app_theme.dart';

// ─────────────────────────────────────────────
// REGISTER SCREEN
// ─────────────────────────────────────────────

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  bool _isLoading = false;
  double _passwordStrength = 0;
  String _strengthLabel = '';
  Color _strengthColor = Colors.transparent;

  String _confirmLabel = '';
  Color _confirmColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    _animCtrl.forward();
    _passCtrl.addListener(_evaluateStrength);
    _passCtrl.addListener(_checkPasswordMatch);
    _confirmCtrl.addListener(_checkPasswordMatch);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _evaluateStrength() {
    final p = _passCtrl.text;
    double strength = 0;

    if (p.length >= 8) strength += 0.25;
    if (p.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (p.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (p.contains(RegExp(r'[!@#\$&*~^%]'))) strength += 0.25;

    String label;
    Color color;
    if (strength <= 0.25) {
      label = 'Weak';
      color = const Color(0xFFEF4444);
    } else if (strength <= 0.5) {
      label = 'Fair';
      color = const Color(0xFFF97316);
    } else if (strength <= 0.75) {
      label = 'Good';
      color = const Color(0xFFEAB308);
    } else {
      label = 'Strong';
      color = const Color(0xFF2563EB);
    }

    setState(() {
      _passwordStrength = p.isEmpty ? 0 : strength;
      _strengthLabel = p.isEmpty ? '' : label;
      _strengthColor = color;
    });
  }

  void _checkPasswordMatch() {
    if (_confirmCtrl.text.isEmpty) {
      setState(() {
        _confirmLabel = '';
        _confirmColor = Colors.transparent;
      });
      return;
    }

    if (_passCtrl.text == _confirmCtrl.text) {
      setState(() {
        _confirmLabel = 'Passwords match';
        _confirmColor = const Color(0xFF2563EB);
      });
    } else {
      setState(() {
        _confirmLabel = 'Passwords do not match';
        _confirmColor = const Color(0xFFEF4444);
      });
    }
  }

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();

    if (_nameCtrl.text.trim().isEmpty) {
      _showError('Please enter your name');
      return;
    }

    if (_emailCtrl.text.trim().isEmpty) {
      _showError('Please enter email or phone');
      return;
    }

    if (_passCtrl.text.length < 8) {
      _showError('Password must be at least 8 characters');
      return;
    }

    if (_passCtrl.text != _confirmCtrl.text) {
      _showError('Passwords do not match');
      return;
    }

    // if (!_formKey.currentState!.validate()) {
    //   return;
    // }

    // HapticFeedback.mediumImpact();

    setState(() => _isLoading = true);

    try {
      final result = await ApiService().register(
        fullName: _nameCtrl.text.trim(),
        login: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        confirmPassword: _confirmCtrl.text,
      );

      if (!mounted) return;

      // Get.snackbar('Success', result['message'] ?? 'OTP sent successfully');

      Get.to(
        () => VerifyOtpScreen(login: _emailCtrl.text.trim()),
        transition: Transition.rightToLeft,
      );
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red.shade400,
                  size: 40,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Registration Failed',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 12),

              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, height: 1.5),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () => Get.back(),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // ── Curved blue header ──
          const _CurvedHeader(),

          // ── Scrollable content ──
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Back button (top-left inside SafeArea)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // const SizedBox(height: 12),

                  // Header text + icon
                  _buildHeaderText(),

                  const SizedBox(height: 10),

                  // Floating card
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _buildCard(colors),
                    ),
                  ),
                  // const SizedBox(height: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.person_add_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Create Account',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Join Mart and start shopping today',
          style: TextStyle(color: Colors.white.withOpacity(0.78), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCard(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.09),
              blurRadius: 32,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section label ──
            Text(
              'Sign Up',
              style: TextStyle(
                color: colors.text1,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fill in the details below to get started',
              style: TextStyle(color: colors.text3, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // ── Full Name ──
            _AuthInput(
              controller: _nameCtrl,
              hint: 'Your name',
              label: 'Name',
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 16),

            // ── Email / Phone ──
            _AuthInput(
              controller: _emailCtrl,
              hint: 'Email or phone number',
              label: 'Email / Phone',
              icon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // ── Password ──
            _AuthInput(
              controller: _passCtrl,
              hint: 'Create a strong password',
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              obscure: true,
            ),

            // ── Password strength indicator ──
            if (_passwordStrength > 0) ...[
              const SizedBox(height: 10),
              _StrengthIndicator(
                strength: _passwordStrength,
                label: _strengthLabel,
                color: _strengthColor,
                colors: colors,
              ),
            ],

            const SizedBox(height: 16),

            // ── Confirm Password ──
            _AuthInput(
              controller: _confirmCtrl,
              hint: 'Re-enter your password',
              label: 'Confirm Password',
              icon: Icons.lock_person_outlined,
              obscure: true,
            ),
            if (_confirmLabel.isNotEmpty) ...[
              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(
                    _confirmColor == const Color(0xFF2563EB)
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    size: 13,
                    color: _confirmColor,
                  ),

                  const SizedBox(width: 5),

                  Text(
                    _confirmLabel,
                    style: TextStyle(
                      color: _confirmColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 28),

            // ── Sign Up button ──
            _AuthButton(
              label: 'Create Account',
              isLoading: _isLoading,
              onTap: _handleSignUp,
            ),

            const SizedBox(height: 24),

            // ── Divider ──
            // _OrDivider(colors: colors),

            // const SizedBox(height: 20),

            // ── Social buttons ──
            // _SocialButton(
            //   label: 'Sign up with Google',
            //   icon: _GoogleIcon(),
            //   colors: colors,
            //   onTap: () {},
            // ),
            // const SizedBox(height: 12),
            // _SocialButton(
            //   label: 'Sign up with Apple',
            //   icon: Icon(Icons.apple_rounded, size: 22, color: colors.text1),
            //   colors: colors,
            //   onTap: () {},
            // ),
            // const SizedBox(height: 24),

            // ── Login footer ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: TextStyle(color: colors.text2, fontSize: 14),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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

// ─────────────────────────────────────────────
// PASSWORD STRENGTH INDICATOR
// ─────────────────────────────────────────────

class _StrengthIndicator extends StatelessWidget {
  final double strength;
  final String label;
  final Color color;
  final AppColors colors;

  const _StrengthIndicator({
    required this.strength,
    required this.label,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 4-segment bar
        Row(
          children: List.generate(4, (i) {
            final filled = strength >= (i + 1) * 0.25;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.only(right: i < 3 ? 5 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: filled ? color : colors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              strength >= 0.75
                  ? Icons.check_circle_rounded
                  : Icons.info_outline_rounded,
              size: 13,
              color: color,
            ),
            const SizedBox(width: 5),
            Text(
              'Password strength: $label',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// CURVED HEADER
// ─────────────────────────────────────────────

class _CurvedHeader extends StatelessWidget {
  const _CurvedHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 300),
            painter: _HeaderPainter(),
          ),
          ..._dots(),
          Positioned(
            top: 150,
            left: 36,
            child: _floatingBadge(Icons.storefront_outlined),
          ),
          Positioned(
            top: 48,
            right: 36,
            child: _floatingBadge(Icons.favorite_border_rounded),
          ),
          Positioned(
            top: 100,
            right: 82,
            child: _floatingBadge(Icons.card_giftcard_rounded),
          ),
        ],
      ),
    );
  }

  List<Widget> _dots() {
    const data = [
      [32.0, 90.0, 5.0],
      [55.0, 155.0, 3.5],
      [18.0, 200.0, 6.0],
      [330.0, 72.0, 4.5],
      [355.0, 138.0, 6.5],
      [305.0, 188.0, 3.5],
      [175.0, 44.0, 7.0],
    ];
    return data
        .map(
          (d) => Positioned(
            left: d[0],
            top: d[1],
            child: Container(
              width: d[2],
              height: d[2],
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.28),
                shape: BoxShape.circle,
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _floatingBadge(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
      ),
      child: Icon(icon, color: Colors.white.withOpacity(0.9), size: 18),
    );
  }
}

class _HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF60A5FA)],
      stops: [0.0, 0.55, 1.0],
    );
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    final path = Path()
      ..lineTo(0, size.height - 55)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height + 35,
        size.width,
        size.height - 55,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width - 20, -10), 110, glowPaint);
    canvas.drawCircle(
      Offset(size.width * 0.08, size.height * 0.65),
      80,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────
// AUTH INPUT
// ─────────────────────────────────────────────

class _AuthInput extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final String? errorText;

  const _AuthInput({
    required this.controller,
    required this.hint,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
  });

  @override
  State<_AuthInput> createState() => _AuthInputState();
}

class _AuthInputState extends State<_AuthInput> {
  bool _obscure = true;
  bool _focused = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() => _focused = _focusNode.hasFocus);
      });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _focused
                ? colors.accent
                : hasError
                ? colors.flashText
                : colors.text2,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: colors.accent.withOpacity(0.13),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscure ? _obscure : false,
            keyboardType: widget.keyboardType,
            style: TextStyle(
              color: colors.text1,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: colors.text3, fontSize: 14),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: _focused
                      ? colors.accent
                      : hasError
                      ? colors.flashText
                      : colors.text3,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 52,
                minHeight: 52,
              ),
              suffixIcon: widget.obscure
                  ? GestureDetector(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Icon(
                          _obscure
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 20,
                          color: colors.text3,
                        ),
                      ),
                    )
                  : null,
              filled: true,
              fillColor: _focused ? colors.surface : colors.surface2,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: hasError
                      ? colors.flashText.withOpacity(0.5)
                      : colors.border,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: hasError ? colors.flashText : colors.accent,
                  width: 1.8,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 13,
                color: colors.flashText,
              ),
              const SizedBox(width: 5),
              Text(
                widget.errorText!,
                style: TextStyle(
                  color: colors.flashText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
// AUTH BUTTON
// ─────────────────────────────────────────────

class _AuthButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  const _AuthButton({required this.label, this.onTap, this.isLoading = false});

  @override
  State<_AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<_AuthButton>
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
    final colors = context.colors;

    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        // HapticFeedback.lightImpact();
      },
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.isLoading ? null : widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.accent,
                Color.lerp(colors.accent, const Color(0xFF60A5FA), 0.4)!,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: colors.accent.withOpacity(0.38),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SOCIAL BUTTON
// ─────────────────────────────────────────────

class _SocialButton extends StatefulWidget {
  final String label;
  final Widget icon;
  final AppColors colors;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
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
    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        // HapticFeedback.selectionClick();
      },
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: widget.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.colors.border, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.icon,
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.colors.text1,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// OR DIVIDER
// ─────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  final AppColors colors;
  const _OrDivider({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: colors.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or sign up with',
            style: TextStyle(
              color: colors.text3,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: colors.border, thickness: 1)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// GOOGLE ICON
// ─────────────────────────────────────────────

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final colors = [
      const Color(0xFF4285F4),
      const Color(0xFF34A853),
      const Color(0xFFFBBC05),
      const Color(0xFFEA4335),
    ];

    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        (i * 90 - 45) * 3.14159 / 180,
        90 * 3.14159 / 180,
        true,
        paint,
      );
    }

    canvas.drawCircle(Offset(cx, cy), r * 0.55, Paint()..color = Colors.white);

    canvas.drawRect(
      Rect.fromLTWH(cx, cy - r * 0.13, r, r * 0.26),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
