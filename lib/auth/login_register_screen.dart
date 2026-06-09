import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import '../widgets/skeleton_loader.dart';

// ─────────────────────────────────────────────
// ENTRY POINT — call this to open the sheet
// ─────────────────────────────────────────────

void showAuthBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AuthSheet(),
  );
}
// ─────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────

const _kAccent = Colors.green;
const _kGreen = Color(0xFF00C896);
const _kSurface = Color(0xFFF7F8FA);
const _kBorder = Color(0xFFE4E7EE);
const _kText1 = Color(0xFF0D0F14);
const _kText2 = Color(0xFF6B7280);
const _kRed = Color(0xFFEF4444);

// ─────────────────────────────────────────────
// COUNTRY MODEL
// ─────────────────────────────────────────────

class _Country {
  final String name;
  final String flag;
  final String dial;
  const _Country(this.name, this.flag, this.dial);
}

const _countries = [
  _Country('Cambodia', '🇰🇭', '+855'),
  _Country('United States', '🇺🇸', '+1'),
  _Country('United Kingdom', '🇬🇧', '+44'),

  _Country('Vietnam', '🇻🇳', '+84'),
  _Country('Singapore', '🇸🇬', '+65'),
  _Country('Indonesia', '🇮🇩', '+62'),
  _Country('Malaysia', '🇲🇾', '+60'),
  _Country('Philippines', '🇵🇭', '+63'),
  _Country('China', '🇨🇳', '+86'),
  _Country('Japan', '🇯🇵', '+81'),
  _Country('South Korea', '🇰🇷', '+82'),
  _Country('India', '🇮🇳', '+91'),
  _Country('Australia', '🇦🇺', '+61'),
  _Country('France', '🇫🇷', '+33'),
  _Country('Germany', '🇩🇪', '+49'),
];

// ─────────────────────────────────────────────
// MAIN SHEET
// ─────────────────────────────────────────────

class _AuthSheet extends StatefulWidget {
  const _AuthSheet();

  @override
  State<_AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<_AuthSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();

    _tab = TabController(length: 2, vsync: this);

    _tab.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,

      // closed height
      height: keyboardOpen
          ? MediaQuery.of(context).size.height * .75
          : MediaQuery.of(context).size.height * .45,

      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),

      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),

            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _kBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // logo
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Container(
            //       width: 36,
            //       height: 36,
            //       decoration: BoxDecoration(
            //         color: _kAccent,
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //       child: const Icon(
            //         Icons.shopping_bag_rounded,
            //         color: Colors.white,
            //         size: 20,
            //       ),
            //     ),

            //     const SizedBox(width: 10),

            //     const Text(
            //       'Darita Mart',
            //       style: TextStyle(
            //         fontSize: 20,
            //         fontWeight: FontWeight.w800,
            //         color: _kAccent,
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 24),

            // tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 45,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  controller: _tab,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: Colors.white, // active pill
                    borderRadius: BorderRadius.circular(26),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.green.shade900.withOpacity(0.7),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  tabs: const [
                    Tab(text: "Login"),
                    Tab(text: "Register"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 4),

            Expanded(
              child: TabBarView(
                controller: _tab,
                physics: const NeverScrollableScrollPhysics(),
                children: const [_LoginTab(), _RegisterFlow()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ═════════════════════════════════════════════
// LOGIN TAB
// ═════════════════════════════════════════════

class _LoginTab extends StatefulWidget {
  const _LoginTab();

  @override
  State<_LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<_LoginTab> {
  final emailCtrl = TextEditingController();
  final otpCtrls = List.generate(6, (_) => TextEditingController());

  bool loading = false;
  bool showOtp = false;

  Future sendOtp() async {
    if (emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter email")));
      return;
    }

    if (!RegExp(
      r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(emailCtrl.text.trim())) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid email")));
      return;
    }

    try {
      setState(() => loading = true);

      await ApiService().sendEmailOtp(email: emailCtrl.text.trim());

      setState(() {
        loading = false;
        showOtp = true;
      });
    } catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future verifyOtp() async {
    final otp = otpCtrls.map((e) => e.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter 6-digit OTP")));
      return;
    }

    try {
      setState(() => loading = true);

      await ApiService().verifyOtp(login: emailCtrl.text.trim(), otp: otp);

      if (!mounted) return;

      setState(() => loading = false);

      Navigator.pop(context);
    } catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        28,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: !showOtp ? _buildLogin() : _buildOtp(),
    );
  }

  // ───────────────── LOGIN VIEW ─────────────────
  Widget _buildLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InputField(
          controller: emailCtrl,
          hint: "Email or Phone Number",
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 30),

        _PrimaryButton(label: "LOG IN", loading: loading, onTap: sendOtp),

        const SizedBox(height: 24),

        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: _kBorder)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "or continue with",
                style: TextStyle(fontSize: 12, color: _kText2),
              ),
            ),
            Expanded(child: Divider(color: _kBorder)),
          ],
        ),

        const SizedBox(height: 20),

        // Social buttons
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                label: "Google",
                icon: _GoogleIcon(),
                color: Colors.white,
                textColor: _kText1,
                borderColor: _kBorder,
                onTap: () {
                  // TODO: Google login
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SocialButton(
                label: "Facebook",
                icon: _FacebookIcon(),
                color: const Color(0xFF1877F2),
                onTap: () {
                  // TODO: Facebook login
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ───────────────── OTP VIEW ─────────────────
  Widget _buildOtp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => showOtp = false),
          child: const Icon(Icons.arrow_back),
        ),

        const SizedBox(height: 20),

        Text(
          "OTP sent to ${emailCtrl.text}",
          style: const TextStyle(fontSize: 16),
        ),

        const SizedBox(height: 30),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            6,
            (i) => SizedBox(
              width: 46,
              height: 54,
              child: TextField(
                controller: otpCtrls[i],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: _kSurface,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _kBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _kAccent, width: 2),
                  ),
                ),

                onChanged: (value) {
                  // 👉 Move forward
                  if (value.isNotEmpty) {
                    if (i < 5) {
                      FocusScope.of(context).nextFocus();
                    }
                  }
                  // 👉 Move backward
                  else {
                    if (i > 0) {
                      FocusScope.of(context).previousFocus();
                    }
                  }

                  // 👉 Check full OTP
                  final otp = otpCtrls.map((e) => e.text).join();

                  if (otp.length == 6 && !loading) {
                    verifyOtp(); // 🔥 AUTO API CALL
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════
// REGISTER FLOW (multi-step)
// ═════════════════════════════════════════════

enum _RegStep { phone, otp, profile }

class _RegisterFlow extends StatefulWidget {
  const _RegisterFlow();

  @override
  State<_RegisterFlow> createState() => _RegisterFlowState();
}

class _RegisterFlowState extends State<_RegisterFlow> {
  _RegStep _step = _RegStep.phone;
  _Country _country = _countries.first;
  final _phoneCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrl = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  String? _avatarPath;
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    for (final c in _otpCtrl) c.dispose();
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == _RegStep.phone)
      setState(() => _step = _RegStep.otp);
    else if (_step == _RegStep.otp)
      setState(() => _step = _RegStep.profile);
    else {
      // submit
      Navigator.pop(context);
    }
  }

  void _back() {
    if (_step == _RegStep.otp)
      setState(() => _step = _RegStep.phone);
    else if (_step == _RegStep.profile)
      setState(() => _step = _RegStep.otp);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, anim) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: switch (_step) {
        _RegStep.phone => _PhoneStep(
          key: const ValueKey('phone'),
          country: _country,
          controller: _phoneCtrl,
          onCountryTap: () => _showCountryPicker(),
          onNext: _next,
        ),
        _RegStep.otp => _OtpStep(
          key: const ValueKey('otp'),
          phone: '${_country.dial} ${_phoneCtrl.text}',
          controllers: _otpCtrl,
          onBack: _back,
          onNext: _next,
        ),
        _RegStep.profile => _ProfileStep(
          key: const ValueKey('profile'),
          firstCtrl: _firstCtrl,
          lastCtrl: _lastCtrl,
          avatarPath: _avatarPath,
          onPickAvatar: () => setState(() => _avatarPath = 'picked'),
          onBack: _back,
          onDone: _next,
        ),
      },
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CountryPicker(
        selected: _country,
        onSelect: (c) {
          setState(() => _country = c);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STEP 1 — PHONE
// ─────────────────────────────────────────────

class _PhoneStep extends StatelessWidget {
  final _Country country;
  final TextEditingController controller;
  final VoidCallback onCountryTap;
  final VoidCallback onNext;

  const _PhoneStep({
    super.key,
    required this.country,
    required this.controller,
    required this.onCountryTap,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        28,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepIndicator(current: 0, total: 3),
          const SizedBox(height: 20),
          const Text(
            'Create account',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _kText1,
              letterSpacing: -.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter your phone number to get started',
            style: TextStyle(fontSize: 14, color: _kText2),
          ),
          const SizedBox(height: 32),

          _Label('Country'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onCountryTap,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kBorder),
              ),
              child: Row(
                children: [
                  Text(country.flag, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      country.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _kText1,
                      ),
                    ),
                  ),
                  Text(
                    country.dial,
                    style: const TextStyle(
                      fontSize: 14,
                      color: _kText2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _kText2,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          _Label('Phone Number'),
          const SizedBox(height: 8),
          _InputField(
            controller: controller,
            hint: 'Enter phone number',
            keyboardType: TextInputType.phone,
            prefix: Container(
              padding: const EdgeInsets.only(right: 10),
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: _kBorder, width: 1)),
              ),
              child: Text(
                country.dial,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _kText1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          _PrimaryButton(label: 'Send OTP', onTap: onNext),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STEP 2 — OTP
// ─────────────────────────────────────────────

class _OtpStep extends StatefulWidget {
  final String phone;
  final List<TextEditingController> controllers;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _OtpStep({
    super.key,
    required this.phone,
    required this.controllers,
    required this.onBack,
    required this.onNext,
  });

  @override
  State<_OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<_OtpStep> {
  final _nodes = List.generate(6, (_) => FocusNode());
  int _resendSeconds = 30;
  late final _timer = Stream.periodic(const Duration(seconds: 1));

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() async {
    await for (final _ in _timer) {
      if (!mounted) break;
      if (_resendSeconds > 0) setState(() => _resendSeconds--);
    }
  }

  @override
  void dispose() {
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        28,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepIndicator(current: 1, total: 3),
          const SizedBox(height: 20),

          Row(
            children: [
              GestureDetector(
                onTap: widget.onBack,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _kSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kBorder),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: _kText1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Verify OTP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _kText1,
                  letterSpacing: -.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              text: 'Enter the 6-digit code sent to ',
              style: const TextStyle(fontSize: 14, color: _kText2),
              children: [
                TextSpan(
                  text: widget.phone,
                  style: const TextStyle(
                    color: _kText1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // ── OTP boxes ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) {
              return SizedBox(
                width: 46,
                height: 54,
                child: TextField(
                  controller: widget.controllers[i],
                  focusNode: _nodes[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _kText1,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: _kSurface,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _kBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _kAccent, width: 2),
                    ),
                  ),
                  onChanged: (v) {
                    if (v.isNotEmpty && i < 5) {
                      _nodes[i + 1].requestFocus();
                    } else if (v.isEmpty && i > 0) {
                      _nodes[i - 1].requestFocus();
                    }
                    if (i == 5 && v.isNotEmpty) {
                      // auto-proceed
                      widget.onNext();
                    }
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 28),

          // ── resend ──
          Center(
            child: _resendSeconds > 0
                ? RichText(
                    text: TextSpan(
                      text: 'Resend code in ',
                      style: const TextStyle(fontSize: 13, color: _kText2),
                      children: [
                        TextSpan(
                          text: '${_resendSeconds}s',
                          style: const TextStyle(
                            color: _kAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: () => setState(() => _resendSeconds = 30),
                    child: const Text(
                      'Resend OTP',
                      style: TextStyle(
                        color: _kGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 32),

          _PrimaryButton(label: 'Verify & Continue', onTap: widget.onNext),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STEP 3 — PROFILE
// ─────────────────────────────────────────────

class _ProfileStep extends StatelessWidget {
  final TextEditingController firstCtrl;
  final TextEditingController lastCtrl;
  final String? avatarPath;
  final VoidCallback onPickAvatar;
  final VoidCallback onBack;
  final VoidCallback onDone;

  const _ProfileStep({
    super.key,
    required this.firstCtrl,
    required this.lastCtrl,
    required this.avatarPath,
    required this.onPickAvatar,
    required this.onBack,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarPath != null;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        28,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepIndicator(current: 2, total: 3),
          const SizedBox(height: 20),

          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _kSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kBorder),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: _kText1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Your Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _kText1,
                  letterSpacing: -.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.only(left: 48),
            child: Text(
              'Add your name and photo',
              style: TextStyle(fontSize: 14, color: _kText2),
            ),
          ),
          const SizedBox(height: 32),

          // ── avatar picker ──
          Center(
            child: GestureDetector(
              onTap: onPickAvatar,
              child: Stack(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kSurface,
                      border: Border.all(color: _kBorder, width: 2),
                    ),
                    child: hasAvatar
                        ? ClipOval(
                            child: Container(
                              color: _kGreen.withOpacity(.2),
                              child: const Icon(
                                Icons.person_rounded,
                                size: 48,
                                color: _kGreen,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.person_rounded,
                            size: 48,
                            color: _kText2,
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: _kAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
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

          if (hasAvatar) ...[
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Photo selected ✓',
                style: TextStyle(
                  fontSize: 12,
                  color: _kGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          const SizedBox(height: 28),

          _Label('First Name'),
          const SizedBox(height: 8),
          _InputField(
            controller: firstCtrl,
            hint: 'Enter first name',
            prefix: const Icon(Icons.badge_outlined, size: 18, color: _kText2),
          ),
          const SizedBox(height: 16),

          _Label('Last Name'),
          const SizedBox(height: 8),
          _InputField(
            controller: lastCtrl,
            hint: 'Enter last name',
            prefix: const Icon(Icons.badge_outlined, size: 18, color: _kText2),
          ),
          const SizedBox(height: 32),

          _PrimaryButton(label: 'Complete Registration', onTap: onDone),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'By continuing you agree to our Terms & Privacy Policy',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: _kText2),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// COUNTRY PICKER
// ─────────────────────────────────────────────

class _CountryPicker extends StatefulWidget {
  final _Country selected;
  final ValueChanged<_Country> onSelect;

  const _CountryPicker({required this.selected, required this.onSelect});

  @override
  State<_CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends State<_CountryPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _countries
        .where(
          (c) =>
              c.name.toLowerCase().contains(_query.toLowerCase()) ||
              c.dial.contains(_query),
        )
        .toList();

    return SizedBox(
      height: MediaQuery.of(context).size.height * .65,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _kBorder,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select Country',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _kText1,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _InputField(
              hint: 'Search country...',
              prefix: const Icon(
                Icons.search_rounded,
                size: 18,
                color: _kText2,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: _kBorder),
              itemBuilder: (_, i) {
                final c = filtered[i];
                final selected = c.name == widget.selected.name;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  leading: Text(c.flag, style: const TextStyle(fontSize: 26)),
                  title: Text(
                    c.name,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                      color: _kText1,
                    ),
                  ),
                  trailing: Text(
                    c.dial,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _kText2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => widget.onSelect(c),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  tileColor: selected
                      ? _kGreen.withOpacity(.06)
                      : Colors.transparent,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i == current;
        final done = i < current;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              decoration: BoxDecoration(
                color: done
                    ? _kGreen
                    : active
                    ? _kAccent
                    : _kBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: _kText1,
    ),
  );
}

class _InputField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final ValueChanged<String>? onChanged;

  const _InputField({
    this.controller,
    required this.hint,
    this.keyboardType,
    this.prefix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: _kText1,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: _kText2),
          prefixIcon: prefix != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: prefix,
                )
              : null,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: loading ? _kAccent.withOpacity(.7) : _kAccent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _kAccent.withOpacity(.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SkeletonBox(
                  width: 82,
                  height: 12,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  baseColor: Colors.white54,
                  highlightColor: Colors.white,
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .2,
                  ),
                ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final Color? borderColor;
  final Widget icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
    this.textColor = Colors.white,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Social icons ──────────────────────────────

class _FacebookIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 22,
    height: 22,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
    child: const Center(
      child: Text(
        'f',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: Color(0xFF1877F2),
        ),
      ),
    ),
  );
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 20,
    height: 20,
    child: CustomPaint(painter: _GooglePainter()),
  );
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

    final sweeps = [1.57, 1.57, 1.0, 1.14];
    final starts = [-.79, .79, 2.36, 3.36];

    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .22;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r * .7),
        starts[i],
        sweeps[i],
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
