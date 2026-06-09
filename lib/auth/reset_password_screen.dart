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

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────

class ResetPasswordScreen extends StatefulWidget {
  /// The reset_token received from the OTP verification step
  final String resetToken;

  const ResetPasswordScreen({super.key, required this.resetToken});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  bool _isLoading = false;
  String? _newPassError;
  String? _confirmPassError;
  String? _globalError;

  // Password strength
  double _strength = 0;
  String _strengthLabel = '';
  Color _strengthColor = Colors.transparent;

  // Requirements checklist
  bool _hasMinLength = false;
  bool _hasMixedCase = false;
  bool _hasNumber = false;
  bool _hasSymbol = false;

  @override
  void initState() {
    super.initState();
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

    _newPassCtrl.addListener(_evaluatePassword);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // ── Password evaluation (mirrors Laravel rules) ──

  void _evaluatePassword() {
    final p = _newPassCtrl.text;

    final minLen = p.length >= 8;
    final mixed = p.contains(RegExp(r'[A-Z]')) && p.contains(RegExp(r'[a-z]'));
    final number = p.contains(RegExp(r'[0-9]'));
    final symbol = p.contains(RegExp(r'[!@#\$&*~^%\-_+=<>?]'));

    double strength = 0;
    if (minLen) strength += 0.25;
    if (mixed) strength += 0.25;
    if (number) strength += 0.25;
    if (symbol) strength += 0.25;

    String label;
    Color color;
    if (p.isEmpty) {
      label = '';
      color = Colors.transparent;
    } else if (strength <= 0.25) {
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
      color = const Color(0xFF22C55E);
    }

    setState(() {
      _hasMinLength = minLen;
      _hasMixedCase = mixed;
      _hasNumber = number;
      _hasSymbol = symbol;
      _strength = p.isEmpty ? 0 : strength;
      _strengthLabel = label;
      _strengthColor = color;
      _newPassError = null;
      _globalError = null;
    });
  }

  // ── Validation ──

  bool _validate() {
    bool ok = true;
    final p = _newPassCtrl.text;
    final c = _confirmPassCtrl.text;

    if (p.isEmpty) {
      setState(() => _newPassError = 'Password is required');
      ok = false;
    } else if (!_hasMinLength) {
      setState(() => _newPassError = 'At least 8 characters required');
      ok = false;
    } else if (!_hasMixedCase) {
      setState(
        () => _newPassError = 'Must contain uppercase & lowercase letters',
      );
      ok = false;
    } else if (!_hasNumber) {
      setState(() => _newPassError = 'Must contain at least one number');
      ok = false;
    } else if (!_hasSymbol) {
      setState(() => _newPassError = 'Must contain at least one symbol');
      ok = false;
    } else {
      setState(() => _newPassError = null);
    }

    if (c.isEmpty) {
      setState(() => _confirmPassError = 'Please confirm your password');
      ok = false;
    } else if (c != p) {
      setState(() => _confirmPassError = 'Passwords do not match');
      ok = false;
    } else {
      setState(() => _confirmPassError = null);
    }

    return ok;
  }

  // ── Submit ──

  Future<void> _handleReset() async {
    if (!_validate()) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
      _globalError = null;
    });

    try {
      await ApiService().resetPassword(
        resetToken: widget.resetToken,
        newPassword: _newPassCtrl.text,
        confirmPassword: _confirmPassCtrl.text,
      );

      if (!mounted) return;
      HapticFeedback.heavyImpact();

      // ── Success: show success sheet then navigate ──
      await context.read<ProfileProvider>().fetchProfile();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    } catch (e) {
      HapticFeedback.vibrate();
      if (!mounted) return;
      setState(() {
        _globalError = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
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
              Icons.lock_reset_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Reset Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Create a strong new password',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Password',
              style: TextStyle(
                color: colors.text1,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Must be 8+ chars with uppercase, number & symbol',
              style: TextStyle(color: colors.text3, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // ── New Password ──
            _AuthInput(
              controller: _newPassCtrl,
              hint: 'Enter new password',
              label: 'New Password',
              icon: Icons.lock_outline_rounded,
              obscure: true,
              errorText: _newPassError,
            ),

            // ── Strength bar ──
            if (_strength > 0) ...[
              const SizedBox(height: 12),
              _StrengthBar(
                strength: _strength,
                label: _strengthLabel,
                color: _strengthColor,
                colors: colors,
              ),
            ],

            const SizedBox(height: 16),

            // ── Confirm Password ──
            _AuthInput(
              controller: _confirmPassCtrl,
              hint: 'Re-enter new password',
              label: 'Confirm Password',
              icon: Icons.lock_person_outlined,
              obscure: true,
              errorText: _confirmPassError,
              onChanged: (_) => setState(() => _confirmPassError = null),
            ),

            const SizedBox(height: 20),

            // ── Requirements checklist ──
            _RequirementsList(
              hasMinLength: _hasMinLength,
              hasMixedCase: _hasMixedCase,
              hasNumber: _hasNumber,
              hasSymbol: _hasSymbol,
              colors: colors,
              show: _newPassCtrl.text.isNotEmpty,
            ),

            // ── Global error ──
            if (_globalError != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colors.flashBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.flashBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 16,
                      color: colors.flashText,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _globalError!,
                        style: TextStyle(
                          color: colors.flashText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // ── Reset button ──
            _ResetButton(
              isLoading: _isLoading,
              onTap: _handleReset,
              colors: colors,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STRENGTH BAR
// ─────────────────────────────────────────────

class _StrengthBar extends StatelessWidget {
  final double strength;
  final String label;
  final Color color;
  final AppColors colors;

  const _StrengthBar({
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
              strength >= 1.0
                  ? Icons.check_circle_rounded
                  : Icons.info_outline_rounded,
              size: 13,
              color: color,
            ),
            const SizedBox(width: 5),
            Text(
              'Strength: $label',
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
// REQUIREMENTS CHECKLIST
// ─────────────────────────────────────────────

class _RequirementsList extends StatelessWidget {
  final bool hasMinLength, hasMixedCase, hasNumber, hasSymbol, show;
  final AppColors colors;

  const _RequirementsList({
    required this.hasMinLength,
    required this.hasMixedCase,
    required this.hasNumber,
    required this.hasSymbol,
    required this.colors,
    required this.show,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: show
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.bginfo,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password requirements',
                    style: TextStyle(
                      color: colors.text2,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _Req(
                    met: hasMinLength,
                    label: 'At least 8 characters',
                    colors: colors,
                  ),
                  const SizedBox(height: 6),
                  _Req(
                    met: hasMixedCase,
                    label: 'Uppercase & lowercase letters',
                    colors: colors,
                  ),
                  const SizedBox(height: 6),
                  _Req(
                    met: hasNumber,
                    label: 'At least one number',
                    colors: colors,
                  ),
                  const SizedBox(height: 6),
                  _Req(
                    met: hasSymbol,
                    label: 'At least one symbol (!@#\$&*)',
                    colors: colors,
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _Req extends StatelessWidget {
  final bool met;
  final String label;
  final AppColors colors;

  const _Req({required this.met, required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: met ? const Color(0xFF22C55E) : colors.surface2,
            shape: BoxShape.circle,
            border: Border.all(
              color: met ? const Color(0xFF22C55E) : colors.border,
              width: 1.5,
            ),
          ),
          child: met
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 11)
              : null,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: met ? colors.text1 : colors.text3,
            fontSize: 13,
            fontWeight: met ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SUCCESS BOTTOM SHEET
// ─────────────────────────────────────────────

class _SuccessSheet extends StatelessWidget {
  final VoidCallback onContinue;

  const _SuccessSheet({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 36),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated success icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF22C55E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Password Reset!',
            style: TextStyle(
              color: colors.text1,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your password has been updated successfully.\nYou are now logged in.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.text2, fontSize: 14, height: 1.5),
          ),

          const SizedBox(height: 32),

          // Continue button
          GestureDetector(
            onTap: onContinue,
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
                    color: colors.accent.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Continue Shopping',
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// AUTH INPUT
// ─────────────────────────────────────────────

class _AuthInput extends StatefulWidget {
  final TextEditingController controller;
  final String hint, label;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _AuthInput({
    required this.controller,
    required this.hint,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onChanged,
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
      ..addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = widget.errorText?.isNotEmpty == true;

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
            onChanged: widget.onChanged,
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
              Flexible(
                child: Text(
                  widget.errorText!,
                  style: TextStyle(
                    color: colors.flashText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
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
// RESET BUTTON
// ─────────────────────────────────────────────

class _ResetButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final AppColors colors;

  const _ResetButton({
    required this.isLoading,
    required this.onTap,
    required this.colors,
  });

  @override
  State<_ResetButton> createState() => _ResetButtonState();
}

class _ResetButtonState extends State<_ResetButton>
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
        HapticFeedback.lightImpact();
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
                        Icons.lock_reset_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Reset Password',
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
            top: 160,
            left: 58,
            child: _badge(Icons.lock_outline_rounded),
          ),
          Positioned(top: 48, right: 36, child: _badge(Icons.key_rounded)),
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

  Widget _badge(IconData icon) => Container(
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

    canvas.drawPath(
      Path()
        ..lineTo(0, size.height - 55)
        ..quadraticBezierTo(
          size.width * 0.5,
          size.height + 35,
          size.width,
          size.height - 55,
        )
        ..lineTo(size.width, 0)
        ..close(),
      paint,
    );

    final glow = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width - 20, -10), 110, glow);
    canvas.drawCircle(Offset(size.width * 0.08, size.height * 0.65), 80, glow);
  }

  @override
  bool shouldRepaint(_) => false;
}
