import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mart_frontend/providers/profile_provider.dart';
import 'package:mart_frontend/screens/main/main_screen.dart';
import 'package:mart_frontend/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/theme/app_theme.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String login;

  const VerifyOtpScreen({super.key, required this.login});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen>
    with SingleTickerProviderStateMixin {
  // 6 separate controllers + focus nodes for each digit box
  static const int _otpLength = 6;
  final List<TextEditingController> _ctrls = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _nodes = List.generate(_otpLength, (_) => FocusNode());

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  bool _isLoading = false;
  String? _errorMsg;

  // Resend countdown
  static const int _resendSeconds = 60;
  int _countdown = _resendSeconds;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();

    // Entry animation
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();

    _startCountdown();

    // Auto-focus first box
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_nodes[0]);
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _timer?.cancel();
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  // ── Countdown logic ──

  void _startCountdown() {
    _countdown = _resendSeconds;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  // ── OTP input handling ──

  String get _otpValue => _ctrls.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    setState(() => _errorMsg = null);

    if (value.length > 1) {
      // Handle paste: distribute digits
      final digits = value.replaceAll(RegExp(r'\D'), '').split('');
      for (int i = 0; i < _otpLength && i < digits.length; i++) {
        _ctrls[i].text = digits[i];
      }
      final nextEmpty = digits.length < _otpLength
          ? digits.length
          : _otpLength - 1;
      FocusScope.of(context).requestFocus(_nodes[nextEmpty]);
      if (_otpValue.length == _otpLength) _handleVerify();
      return;
    }

    if (value.isNotEmpty && index < _otpLength - 1) {
      FocusScope.of(context).requestFocus(_nodes[index + 1]);
    }

    if (_otpValue.length == _otpLength) {
      _handleVerify();
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _ctrls[index].text.isEmpty &&
        index > 0) {
      FocusScope.of(context).requestFocus(_nodes[index - 1]);
      _ctrls[index - 1].clear();
    }
  }

  // ── Verify API call ──

  Future<void> _handleVerify() async {
    final otp = _otpValue;
    if (otp.length < _otpLength) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Error'),
            ],
          ),
          content: Text('Please enter all $_otpLength digits'),
          actions: [
            FilledButton(onPressed: () => Get.back(), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    // HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      await ApiService().verifyOtp(login: widget.login, otp: otp);

      if (!mounted) return;

      // ── Success ──
      // HapticFeedback.heavyImpact();
      // Get.snackbar(
      //   'Success',
      //   'Login successful',
      //   backgroundColor: const Color(0xFF22C55E),
      //   colorText: Colors.white,
      //   snackPosition: SnackPosition.TOP,  
      //   margin: const EdgeInsets.all(16),
      //   borderRadius: 14,
      //   duration: const Duration(seconds: 2),
      //   icon: const Icon(
      //     Icons.check_circle_rounded,
      //     color: Colors.white,
      //     size: 22,
      //   ),
      // );

      await context.read<ProfileProvider>().fetchProfile();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
        (route) => false,
      );
    } catch (e) {
      // HapticFeedback.vibrate();
      if (!mounted) return;
      setState(() {
        _errorMsg = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
      // Shake the boxes on error
      _shakeBoxes();
    }
  }

  void _shakeBoxes() {
    // Reset all boxes to show error state briefly
    for (final c in _ctrls) {
      c.clear();
    }
    FocusScope.of(context).requestFocus(_nodes[0]);
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          const _CurvedHeader(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Back button
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

                  const SizedBox(height: 12),
                  _buildHeaderText(),
                  const SizedBox(height: 28),

                  // Card
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _buildCard(colors),
                    ),
                  ),
                  const SizedBox(height: 32),
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
        // Animated shield icon
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (_, v, child) => Transform.scale(scale: v, child: child),
          child: Container(
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
              Icons.verified_user_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Verify OTP',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'We sent a code to your account',
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
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
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
          children: [
            // ── Title ──
            Text(
              'Enter Verification Code',
              style: TextStyle(
                color: colors.text1,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),

            // ── Sent-to hint ──
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(color: colors.text2, fontSize: 13),
                children: [
                  const TextSpan(text: 'Code sent to '),
                  TextSpan(
                    text: _maskLogin(widget.login),
                    style: TextStyle(
                      color: colors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── OTP boxes ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                _otpLength,
                (i) => _OtpBox(
                  controller: _ctrls[i],
                  focusNode: _nodes[i],
                  hasError: _errorMsg != null,
                  onChanged: (v) => _onDigitChanged(i, v),
                  onKeyEvent: (e) => _onKeyEvent(i, e),
                  colors: colors,
                ),
              ),
            ),

            // ── Error message ──
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: _errorMsg != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 14,
                            color: colors.flashText,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _errorMsg!,
                              style: TextStyle(
                                color: colors.flashText,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 28),

            // ── Verify button ──
            _VerifyButton(
              isLoading: _isLoading,
              onTap: _handleVerify,
              colors: colors,
            ),

            const SizedBox(height: 24),

            // ── Resend row ──
            _buildResendRow(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildResendRow(AppColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive the code?",
          style: TextStyle(color: colors.text2, fontSize: 13),
        ),
        const SizedBox(width: 6),
        _canResend
            ? GestureDetector(
                onTap: () {
                  // HapticFeedback.selectionClick();
                  ApiService().resendOtp(login: widget.login);
                  _startCountdown();
                },
                child: Text(
                  'Resend',
                  style: TextStyle(
                    color: colors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : Text(
                'Resend in ${_countdown}s',
                style: TextStyle(
                  color: colors.text3,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ],
    );
  }

  String _maskLogin(String login) {
    if (login.contains('@')) {
      final parts = login.split('@');
      final name = parts[0];
      final masked = name.length > 3
          ? '${name.substring(0, 3)}***@${parts[1]}'
          : '***@${parts[1]}';
      return masked;
    }
    // Phone
    if (login.length >= 6) {
      return '${login.substring(0, 3)}****${login.substring(login.length - 3)}';
    }
    return login;
  }
}

// ─────────────────────────────────────────────
// SINGLE OTP DIGIT BOX
// ─────────────────────────────────────────────

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;
  final AppColors colors;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
    required this.onKeyEvent,
    required this.colors,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      if (mounted) setState(() => _focused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final filled = widget.controller.text.isNotEmpty;

    Color borderColor;
    if (widget.hasError) {
      borderColor = colors.flashText;
    } else if (_focused) {
      borderColor = colors.accent;
    } else if (filled) {
      borderColor = colors.accent.withOpacity(0.5);
    } else {
      borderColor = colors.border;
    }

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: widget.onKeyEvent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 46,
        height: 56,
        decoration: BoxDecoration(
          color: _focused
              ? colors.accentLight.withOpacity(0.18)
              : filled
              ? colors.accentLight.withOpacity(0.10)
              : colors.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: _focused ? 2.0 : 1.4),
          boxShadow: _focused
              ? [
                  BoxShadow(
                    color: colors.accent.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 6, // allow paste detection
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            color: colors.text1,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// VERIFY BUTTON
// ─────────────────────────────────────────────

class _VerifyButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final AppColors colors;

  const _VerifyButton({
    required this.isLoading,
    required this.onTap,
    required this.colors,
  });

  @override
  State<_VerifyButton> createState() => _VerifyButtonState();
}

class _VerifyButtonState extends State<_VerifyButton>
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
    final colors = widget.colors;
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
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Verify Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
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

// ─────────────────────────────────────────────
// CURVED HEADER (same style as login/register)
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
          Positioned(top: 150, left: 48, child: _badge(Icons.shield_outlined)),
          Positioned(
            top: 48,
            right: 36,
            child: _badge(Icons.lock_outline_rounded),
          ),
          Positioned(
            top: 100,
            right: 82,
            child: _badge(Icons.security_rounded),
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

  Widget _badge(IconData icon) {
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
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF60A5FA)],
        stops: [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

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

    final glow = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width - 20, -10), 110, glow);
    canvas.drawCircle(Offset(size.width * 0.08, size.height * 0.65), 80, glow);
  }

  @override
  bool shouldRepaint(_) => false;
}
