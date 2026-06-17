import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/theme/app_theme.dart';
import '../services/api_service.dart';
import 'OrderSuccessScreen.dart';

// ─────────────────────────────────────────────
// KHQR SCREEN
// ─────────────────────────────────────────────

class KhqrScreen extends StatefulWidget {
  final String qrUrl;
  final String amount;
  final String md5;
  final String orderId;

  const KhqrScreen({
    super.key,
    required this.orderId,
    required this.qrUrl,
    required this.amount,
    required this.md5,
  });

  @override
  State<KhqrScreen> createState() => _KhqrScreenState();
}

class _KhqrScreenState extends State<KhqrScreen>
    with SingleTickerProviderStateMixin {
  // ── Polling ────────────────────────────────
  Timer? _pollTimer;
  bool _polling = false;

  // ── Countdown  (15 min = 900 s) ────────────
  static const _totalSeconds = 900;
  int _remaining = _totalSeconds;
  Timer? _countdownTimer;

  // ── State ──────────────────────────────────
  _KhqrState _state = _KhqrState.waiting;

  // ── Pulse animation ────────────────────────
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _startPolling();
    _startCountdown();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Polling every 2 s ──────────────────────
  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _check());
  }

  Future<void> _check() async {
    if (_polling || _state != _KhqrState.waiting) return;
    _polling = true;
    try {
      final res = await ApiService().checkPayment(widget.md5);
      if (res['success'] == true && res['status'] == 'SUCCESS') {
        _pollTimer?.cancel();
        _countdownTimer?.cancel();
        if (mounted) {
          setState(() => _state = _KhqrState.success);
          await Future.delayed(const Duration(milliseconds: 1200));
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    OrderSuccessScreen(orderId: int.parse(widget.orderId)),
              ),
            );
          }
        }
      }
    } catch (_) {}
    _polling = false;
  }

  // ── Countdown ──────────────────────────────
  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining = (_remaining - 1).clamp(0, _totalSeconds);
        if (_remaining == 0) {
          _countdownTimer?.cancel();
          _pollTimer?.cancel();
          _state = _KhqrState.expired;
        }
      });
    });
  }

  String get _timeLabel {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ── Cancel ─────────────────────────────────
  void _cancel() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: _buildAppBar(c),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            children: [
              _KhqrCard(qrUrl: widget.qrUrl, amount: widget.amount, colors: c),
              const SizedBox(height: 14),
              _StatusCard(
                state: _state,
                timeLabel: _timeLabel,
                remaining: _remaining,
                total: _totalSeconds,
                pulseAnim: _pulseAnim,
                colors: c,
              ),
              const SizedBox(height: 14),
              if (_state != _KhqrState.success)
                _CancelButton(colors: c, onTap: _cancel),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppColors c) {
    return AppBar(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: _cancel,
          child: Container(
            decoration: BoxDecoration(
              color: c.surface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: c.text1,
            ),
          ),
        ),
      ),
      title: Text(
        'KHQR Payment',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: c.text1,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: c.border),
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.dark
            : Brightness.light,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STATE ENUM
// ─────────────────────────────────────────────

enum _KhqrState { waiting, success, expired }

// ─────────────────────────────────────────────
// KHQR CARD
// ─────────────────────────────────────────────

class _KhqrCard extends StatelessWidget {
  final String qrUrl;
  final String amount;
  final AppColors colors;

  const _KhqrCard({
    required this.qrUrl,
    required this.amount,
    required this.colors,
  });

  static const _khqrRed = Color(0xFFD41E27);

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Red header ──────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              color: _khqrRed,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  _KhqrMark(),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'KHQR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'National Bank of Cambodia',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Merchant + amount ───────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mart Shop',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: c.text1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'USD ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.text2,
                      ),
                    ),
                    Text(
                      amount,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: c.text1,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Dashed divider ──────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: _DashedLine(color: c.border),
          ),

          // ── QR code ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  qrUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, prog) {
                    if (prog == null) return child;
                    return _QrSkeleton(colors: c);
                  },
                  errorBuilder: (_, __, ___) => _QrFallback(colors: c),
                ),
              ),
            ),
          ),

          // ── Footer ──────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.border)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 12,
                        color: Color(0xFF16A34A),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Secure payment',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Powered by NBC',
                  style: TextStyle(fontSize: 10, color: c.text3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// KHQR MARK LOGO
// ─────────────────────────────────────────────

class _KhqrMark extends StatelessWidget {
  const _KhqrMark();

  static const _red = Color(0xFFD41E27);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
          children: [
            _sq(_red, 2),
            _sq(_red, 2),
            _sq(_red, 2),
            _sq(_red.withOpacity(0.3), 2),
          ],
        ),
      ),
    );
  }

  Widget _sq(Color color, double r) => Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(r),
    ),
  );
}

// ─────────────────────────────────────────────
// STATUS CARD
// ─────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final _KhqrState state;
  final String timeLabel;
  final int remaining;
  final int total;
  final Animation<double> pulseAnim;
  final AppColors colors;

  const _StatusCard({
    required this.state,
    required this.timeLabel,
    required this.remaining,
    required this.total,
    required this.pulseAnim,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: state == _KhqrState.success
            ? const Color(0xFFDCFCE7)
            : state == _KhqrState.expired
            ? const Color(0xFFFEE2E2)
            : c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: state == _KhqrState.success
              ? const Color(0xFF16A34A)
              : state == _KhqrState.expired
              ? const Color(0xFFDC2626)
              : c.border,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          _buildIcon(),
          const SizedBox(height: 12),
          _buildTitle(c),
          const SizedBox(height: 6),
          _buildSubtitle(c),
          if (state == _KhqrState.waiting) ...[
            const SizedBox(height: 12),
            _DotsLoader(color: c.accent),
            const SizedBox(height: 12),
            _CountdownBar(
              remaining: remaining,
              total: total,
              label: timeLabel,
              colors: c,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon() {
    switch (state) {
      case _KhqrState.success:
        return Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: Color(0xFF16A34A),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, size: 28, color: Colors.white),
        );
      case _KhqrState.expired:
        return Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: Color(0xFFDC2626),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.timer_off_rounded,
            size: 26,
            color: Colors.white,
          ),
        );
      case _KhqrState.waiting:
        return ScaleTransition(
          scale: pulseAnim,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.accentLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code_2_rounded,
              size: 26,
              color: colors.accent,
            ),
          ),
        );
    }
  }

  Widget _buildTitle(AppColors c) {
    final (text, color) = switch (state) {
      _KhqrState.success => ('Payment successful!', const Color(0xFF15803D)),
      _KhqrState.expired => ('QR code expired', const Color(0xFFDC2626)),
      _KhqrState.waiting => ('Waiting for payment', c.text1),
    };
    return Text(
      text,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
    );
  }

  Widget _buildSubtitle(AppColors c) {
    final (text, color) = switch (state) {
      _KhqrState.success => (
        'Payment received. Redirecting to your order…',
        const Color(0xFF15803D),
      ),
      _KhqrState.expired => (
        'This QR code has expired.\nPlease go back and try again.',
        const Color(0xFFDC2626),
      ),
      _KhqrState.waiting => (
        'Open any KHQR-compatible banking app\nand scan the code above to pay.',
        c.text2,
      ),
    };
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 13, color: color, height: 1.5),
    );
  }
}

// ─────────────────────────────────────────────
// COUNTDOWN BAR
// ─────────────────────────────────────────────

class _CountdownBar extends StatelessWidget {
  final int remaining;
  final int total;
  final String label;
  final AppColors colors;

  const _CountdownBar({
    required this.remaining,
    required this.total,
    required this.label,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final progress = remaining / total;
    final isLow = remaining < 60;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: c.surface2,
              valueColor: AlwaysStoppedAnimation(
                isLow ? const Color(0xFFDC2626) : c.accent,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timer_outlined,
              size: 13,
              color: isLow ? const Color(0xFFDC2626) : c.text3,
            ),
            const SizedBox(width: 4),
            Text(
              'Expires in $label',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isLow ? const Color(0xFFDC2626) : c.text3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// DOTS LOADER
// ─────────────────────────────────────────────

class _DotsLoader extends StatefulWidget {
  final Color color;
  const _DotsLoader({required this.color});

  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final offset = (i / 3);
            final v = ((_ctrl.value - offset) % 1.0);
            final scale = v < 0.5
                ? Curves.easeOut.transform(v * 2)
                : Curves.easeIn.transform((1 - v) * 2);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.scale(
                scale: 0.5 + scale * 0.5,
                child: Opacity(
                  opacity: 0.3 + scale * 0.7,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// CANCEL BUTTON
// ─────────────────────────────────────────────

class _CancelButton extends StatelessWidget {
  final AppColors colors;
  final VoidCallback onTap;

  const _CancelButton({required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Center(
          child: Text(
            'Cancel payment',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: c.text1,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// QR SKELETON
// ─────────────────────────────────────────────

class _QrSkeleton extends StatefulWidget {
  final AppColors colors;
  const _QrSkeleton({required this.colors});

  @override
  State<_QrSkeleton> createState() => _QrSkeletonState();
}

class _QrSkeletonState extends State<_QrSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
        color: Color.lerp(
          widget.colors.surface2,
          widget.colors.border,
          _anim.value,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// QR FALLBACK
// ─────────────────────────────────────────────

class _QrFallback extends StatelessWidget {
  final AppColors colors;
  const _QrFallback({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.surface2,
      child: Icon(Icons.qr_code_2_rounded, size: 96, color: colors.text3),
    );
  }
}

// ─────────────────────────────────────────────
// DASHED LINE
// ─────────────────────────────────────────────

class _DashedLine extends StatelessWidget {
  final Color color;
  const _DashedLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedLinePainter(color: color),
      size: const Size(double.infinity, 1),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const dashW = 7.0;
    const gapW = 5.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashW, 0), paint);
      x += dashW + gapW;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}













// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import '../screens/theme/app_theme.dart';
// import '../services/api_service.dart';
// import 'OrderSuccessScreen.dart';

// // ─────────────────────────────────────────────
// // KHQR SCREEN
// // ─────────────────────────────────────────────

// class KhqrScreen extends StatefulWidget {
//   final String qrUrl;
//   final String amount;
//   final String md5;

//   const KhqrScreen({
//     super.key,
//     required this.qrUrl,
//     required this.amount,
//     required this.md5,
//   });

//   @override
//   State<KhqrScreen> createState() => _KhqrScreenState();
// }

// class _KhqrScreenState extends State<KhqrScreen>
//     with SingleTickerProviderStateMixin {
//   // ── Polling ────────────────────────────────
//   Timer?  _pollTimer;
//   bool    _polling = false;

//   // ── Countdown  (15 min = 900 s) ────────────
//   static const _totalSeconds = 900;
//   int     _remaining = _totalSeconds;
//   Timer?  _countdownTimer;

//   // ── State ──────────────────────────────────
//   _KhqrState _state = _KhqrState.waiting;

//   // ── Pulse animation ────────────────────────
//   late AnimationController _pulseCtrl;
//   late Animation<double>   _pulseAnim;

//   @override
//   void initState() {
//     super.initState();

//     _pulseCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 1600))
//       ..repeat(reverse: true);
//     _pulseAnim = Tween<double>(begin: 1.0, end: 1.12)
//         .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

//     _startPolling();
//     _startCountdown();
//   }

//   @override
//   void dispose() {
//     _pollTimer?.cancel();
//     _countdownTimer?.cancel();
//     _pulseCtrl.dispose();
//     super.dispose();
//   }

//   // ── Polling every 2 s ──────────────────────
//   void _startPolling() {
//     _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _check());
//   }

//   Future<void> _check() async {
//     if (_polling || _state != _KhqrState.waiting) return;
//     _polling = true;
//     try {
//       final res = await ApiService().checkPayment(widget.md5);
//       if (res['success'] == true && res['status'] == 'SUCCESS') {
//         _pollTimer?.cancel();
//         _countdownTimer?.cancel();
//         if (mounted) {
//           setState(() => _state = _KhqrState.success);
//           await Future.delayed(const Duration(milliseconds: 1200));
//           if (mounted) {
//             Navigator.pushReplacement(context,
//                 MaterialPageRoute(builder: (_) => const OrderSuccessScreen()));
//           }
//         }
//       }
//     } catch (_) {}
//     _polling = false;
//   }

//   // ── Countdown ──────────────────────────────
//   void _startCountdown() {
//     _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (!mounted) return;
//       setState(() {
//         _remaining = (_remaining - 1).clamp(0, _totalSeconds);
//         if (_remaining == 0) {
//           _countdownTimer?.cancel();
//           _pollTimer?.cancel();
//           _state = _KhqrState.expired;
//         }
//       });
//     });
//   }

//   String get _timeLabel {
//     final m = _remaining ~/ 60;
//     final s = _remaining % 60;
//     return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
//   }

//   // ── Cancel ─────────────────────────────────
//   void _cancel() {
//     _pollTimer?.cancel();
//     _countdownTimer?.cancel();
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = context.colors;
//     return Scaffold(
//       backgroundColor: c.background,
//       appBar: _buildAppBar(c),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
//           child: Column(
//             children: [
//               _KhqrCard(
//                 qrUrl:  widget.qrUrl,
//                 amount: widget.amount,
//                 colors: c,
//               ),
//               const SizedBox(height: 14),
//               _StatusCard(
//                 state:     _state,
//                 timeLabel: _timeLabel,
//                 remaining: _remaining,
//                 total:     _totalSeconds,
//                 pulseAnim: _pulseAnim,
//                 colors:    c,
//               ),
//               const SizedBox(height: 14),
//               if (_state != _KhqrState.success)
//                 _CancelButton(colors: c, onTap: _cancel),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar(AppColors c) {
//     return AppBar(
//       backgroundColor: c.surface,
//       surfaceTintColor: Colors.transparent,
//       elevation: 0,
//       leading: Padding(
//         padding: const EdgeInsets.all(8),
//         child: GestureDetector(
//           onTap: _cancel,
//           child: Container(
//             decoration: BoxDecoration(
//                 color: c.surface2,
//                 borderRadius: BorderRadius.circular(12)),
//             child: Icon(Icons.arrow_back_ios_new_rounded,
//                 size: 18, color: c.text1),
//           ),
//         ),
//       ),
//       title: Text('KHQR Payment',
//           style: TextStyle(
//               fontSize: 17, fontWeight: FontWeight.w700, color: c.text1)),
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(1),
//         child: Divider(height: 1, color: c.border),
//       ),
//       systemOverlayStyle: SystemUiOverlayStyle(
//         statusBarBrightness:
//             Theme.of(context).brightness == Brightness.dark
//                 ? Brightness.dark
//                 : Brightness.light,
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // STATE ENUM
// // ─────────────────────────────────────────────

// enum _KhqrState { waiting, success, expired }

// // ─────────────────────────────────────────────
// // KHQR CARD
// // ─────────────────────────────────────────────

// class _KhqrCard extends StatelessWidget {
//   final String   qrUrl;
//   final String   amount;
//   final AppColors colors;

//   const _KhqrCard({
//     required this.qrUrl,
//     required this.amount,
//     required this.colors,
//   });

//   static const _khqrRed = Color(0xFFD41E27);

//   @override
//   Widget build(BuildContext context) {
//     final c = colors;
//     return Container(
//       decoration: BoxDecoration(
//         color: c.surface,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 24,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // ── Red header ──────────────────────
//           ClipRRect(
//             borderRadius:
//                 const BorderRadius.vertical(top: Radius.circular(20)),
//             child: Container(
//               color: _khqrRed,
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//               child: Row(
//                 children: [
//                   _KhqrMark(),
//                   const SizedBox(width: 10),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: const [
//                       Text('KHQR',
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.w900,
//                               letterSpacing: 0.5)),
//                       Text('National Bank of Cambodia',
//                           style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 11,
//                               fontWeight: FontWeight.w500)),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // ── Merchant + amount ───────────────
//           Padding(
//             padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Mart Shop',
//                     style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w700,
//                         color: c.text1)),
//                 const SizedBox(height: 4),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.baseline,
//                   textBaseline: TextBaseline.alphabetic,
//                   children: [
//                     Text('USD ',
//                         style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: c.text2)),
//                     Text(amount,
//                         style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.w900,
//                             color: c.text1,
//                             letterSpacing: -0.5)),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // ── Dashed divider ──────────────────
//           Padding(
//             padding: const EdgeInsets.symmetric(
//                 horizontal: 18, vertical: 12),
//             child: _DashedLine(color: c.border),
//           ),

//           // ── QR code ──────────────────────────
//           Padding(
//             padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
//             child: AspectRatio(
//               aspectRatio: 1,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.network(
//                   qrUrl,
//                   fit: BoxFit.contain,
//                   loadingBuilder: (_, child, prog) {
//                     if (prog == null) return child;
//                     return _QrSkeleton(colors: c);
//                   },
//                   errorBuilder: (_, __, ___) => _QrFallback(colors: c),
//                 ),
//               ),
//             ),
//           ),

//           // ── Footer ──────────────────────────
//           Container(
//             padding:
//                 const EdgeInsets.fromLTRB(16, 10, 16, 14),
//             decoration: BoxDecoration(
//               border: Border(top: BorderSide(color: c.border)),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFDCFCE7),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.verified_rounded,
//                           size: 12, color: Color(0xFF16A34A)),
//                       SizedBox(width: 4),
//                       Text('Secure payment',
//                           style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w700,
//                               color: Color(0xFF15803D))),
//                     ],
//                   ),
//                 ),
//                 const Spacer(),
//                 Text(
//                   'Powered by NBC',
//                   style: TextStyle(fontSize: 10, color: c.text3),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // KHQR MARK LOGO
// // ─────────────────────────────────────────────

// class _KhqrMark extends StatelessWidget {
//   const _KhqrMark();

//   static const _red = Color(0xFFD41E27);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 34,
//       height: 34,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(7),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(5),
//         child: GridView.count(
//           crossAxisCount: 2,
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           mainAxisSpacing: 3,
//           crossAxisSpacing: 3,
//           children: [
//             _sq(_red, 2),
//             _sq(_red, 2),
//             _sq(_red, 2),
//             _sq(_red.withOpacity(0.3), 2),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _sq(Color color, double r) => Container(
//     decoration: BoxDecoration(
//       color: color,
//       borderRadius: BorderRadius.circular(r),
//     ),
//   );
// }

// // ─────────────────────────────────────────────
// // STATUS CARD
// // ─────────────────────────────────────────────

// class _StatusCard extends StatelessWidget {
//   final _KhqrState      state;
//   final String          timeLabel;
//   final int             remaining;
//   final int             total;
//   final Animation<double> pulseAnim;
//   final AppColors       colors;

//   const _StatusCard({
//     required this.state,
//     required this.timeLabel,
//     required this.remaining,
//     required this.total,
//     required this.pulseAnim,
//     required this.colors,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final c = colors;
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 400),
//       curve: Curves.easeOutCubic,
//       decoration: BoxDecoration(
//         color: state == _KhqrState.success
//             ? const Color(0xFFDCFCE7)
//             : state == _KhqrState.expired
//                 ? const Color(0xFFFEE2E2)
//                 : c.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: state == _KhqrState.success
//               ? const Color(0xFF16A34A)
//               : state == _KhqrState.expired
//                   ? const Color(0xFFDC2626)
//                   : c.border,
//           width: 1.5,
//         ),
//       ),
//       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//       child: Column(
//         children: [
//           _buildIcon(),
//           const SizedBox(height: 12),
//           _buildTitle(c),
//           const SizedBox(height: 6),
//           _buildSubtitle(c),
//           if (state == _KhqrState.waiting) ...[
//             const SizedBox(height: 12),
//             _DotsLoader(color: c.accent),
//             const SizedBox(height: 12),
//             _CountdownBar(
//                 remaining: remaining,
//                 total: total,
//                 label: timeLabel,
//                 colors: c),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildIcon() {
//     switch (state) {
//       case _KhqrState.success:
//         return Container(
//           width: 52, height: 52,
//           decoration: const BoxDecoration(
//               color: Color(0xFF16A34A), shape: BoxShape.circle),
//           child: const Icon(Icons.check_rounded,
//               size: 28, color: Colors.white),
//         );
//       case _KhqrState.expired:
//         return Container(
//           width: 52, height: 52,
//           decoration: const BoxDecoration(
//               color: Color(0xFFDC2626), shape: BoxShape.circle),
//           child: const Icon(Icons.timer_off_rounded,
//               size: 26, color: Colors.white),
//         );
//       case _KhqrState.waiting:
//         return ScaleTransition(
//           scale: pulseAnim,
//           child: Container(
//             width: 52, height: 52,
//             decoration: BoxDecoration(
//               color: colors.accentLight,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(Icons.qr_code_2_rounded,
//                 size: 26, color: colors.accent),
//           ),
//         );
//     }
//   }

//   Widget _buildTitle(AppColors c) {
//     final (text, color) = switch (state) {
//       _KhqrState.success => ('Payment successful!', const Color(0xFF15803D)),
//       _KhqrState.expired => ('QR code expired',    const Color(0xFFDC2626)),
//       _KhqrState.waiting => ('Waiting for payment', c.text1),
//     };
//     return Text(text,
//         style: TextStyle(
//             fontSize: 16, fontWeight: FontWeight.w800, color: color));
//   }

//   Widget _buildSubtitle(AppColors c) {
//     final (text, color) = switch (state) {
//       _KhqrState.success => (
//           'Payment received. Redirecting to your order…',
//           const Color(0xFF15803D),
//         ),
//       _KhqrState.expired => (
//           'This QR code has expired.\nPlease go back and try again.',
//           const Color(0xFFDC2626),
//         ),
//       _KhqrState.waiting => (
//           'Open any KHQR-compatible banking app\nand scan the code above to pay.',
//           c.text2,
//         ),
//     };
//     return Text(text,
//         textAlign: TextAlign.center,
//         style: TextStyle(fontSize: 13, color: color, height: 1.5));
//   }
// }

// // ─────────────────────────────────────────────
// // COUNTDOWN BAR
// // ─────────────────────────────────────────────

// class _CountdownBar extends StatelessWidget {
//   final int       remaining;
//   final int       total;
//   final String    label;
//   final AppColors colors;

//   const _CountdownBar({
//     required this.remaining,
//     required this.total,
//     required this.label,
//     required this.colors,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final c        = colors;
//     final progress = remaining / total;
//     final isLow    = remaining < 60;

//     return Column(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(4),
//           child: SizedBox(
//             height: 4,
//             child: LinearProgressIndicator(
//               value: progress,
//               backgroundColor: c.surface2,
//               valueColor: AlwaysStoppedAnimation(
//                 isLow ? const Color(0xFFDC2626) : c.accent,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.timer_outlined,
//                 size: 13,
//                 color: isLow ? const Color(0xFFDC2626) : c.text3),
//             const SizedBox(width: 4),
//             Text('Expires in $label',
//                 style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: isLow ? const Color(0xFFDC2626) : c.text3)),
//           ],
//         ),
//       ],
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // DOTS LOADER
// // ─────────────────────────────────────────────

// class _DotsLoader extends StatefulWidget {
//   final Color color;
//   const _DotsLoader({required this.color});

//   @override
//   State<_DotsLoader> createState() => _DotsLoaderState();
// }

// class _DotsLoaderState extends State<_DotsLoader>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 1200))
//       ..repeat();
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _ctrl,
//       builder: (_, __) {
//         return Row(
//           mainAxisSize: MainAxisSize.min,
//           children: List.generate(3, (i) {
//             final offset = (i / 3);
//             final v      = ((_ctrl.value - offset) % 1.0);
//             final scale  = v < 0.5
//                 ? Curves.easeOut.transform(v * 2)
//                 : Curves.easeIn.transform((1 - v) * 2);
//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 3),
//               child: Transform.scale(
//                 scale: 0.5 + scale * 0.5,
//                 child: Opacity(
//                   opacity: 0.3 + scale * 0.7,
//                   child: Container(
//                     width: 7, height: 7,
//                     decoration: BoxDecoration(
//                         color: widget.color, shape: BoxShape.circle),
//                   ),
//                 ),
//               ),
//             );
//           }),
//         );
//       },
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // CANCEL BUTTON
// // ─────────────────────────────────────────────

// class _CancelButton extends StatelessWidget {
//   final AppColors    colors;
//   final VoidCallback onTap;

//   const _CancelButton({required this.colors, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final c = colors;
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         height: 50,
//         decoration: BoxDecoration(
//           color: c.surface2,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: c.border),
//         ),
//         child: Center(
//           child: Text('Cancel payment',
//               style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w700,
//                   color: c.text1)),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // QR SKELETON
// // ─────────────────────────────────────────────

// class _QrSkeleton extends StatefulWidget {
//   final AppColors colors;
//   const _QrSkeleton({required this.colors});

//   @override
//   State<_QrSkeleton> createState() => _QrSkeletonState();
// }

// class _QrSkeletonState extends State<_QrSkeleton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double>   _anim;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 1200))
//       ..repeat(reverse: true);
//     _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
//   }

//   @override
//   void dispose() { _ctrl.dispose(); super.dispose(); }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _anim,
//       builder: (_, __) => Container(
//         color: Color.lerp(
//           widget.colors.surface2,
//           widget.colors.border,
//           _anim.value,
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // QR FALLBACK
// // ─────────────────────────────────────────────

// class _QrFallback extends StatelessWidget {
//   final AppColors colors;
//   const _QrFallback({required this.colors});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: colors.surface2,
//       child: Icon(Icons.qr_code_2_rounded,
//           size: 96, color: colors.text3),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // DASHED LINE
// // ─────────────────────────────────────────────

// class _DashedLine extends StatelessWidget {
//   final Color color;
//   const _DashedLine({required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: _DashedLinePainter(color: color),
//       size: const Size(double.infinity, 1),
//     );
//   }
// }

// class _DashedLinePainter extends CustomPainter {
//   final Color color;
//   const _DashedLinePainter({required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     const dashW = 7.0;
//     const gapW  = 5.0;
//     final paint = Paint()..color = color..strokeWidth = 1.5;
//     double x = 0;
//     while (x < size.width) {
//       canvas.drawLine(Offset(x, 0), Offset(x + dashW, 0), paint);
//       x += dashW + gapW;
//     }
//   }

//   @override
//   bool shouldRepaint(_DashedLinePainter old) => old.color != color;
// }




// import 'dart:async';
// import 'dart:math' as math;

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import '../screens/theme/app_theme.dart';
// import '../services/api_service.dart';
// import 'OrderSuccessScreen.dart';

// // ═══════════════════════════════════════════════════════════════
// // KHQR SCREEN  — Bakong-style
// // ═══════════════════════════════════════════════════════════════

// class KhqrScreen extends StatefulWidget {
//   final String qrUrl;
//   final String amount;
//   final String md5;
//   final String orderId;

//   const KhqrScreen({
//     super.key,
//     required this.orderId,
//     required this.qrUrl,
//     required this.amount,
//     required this.md5,
//   });

//   @override
//   State<KhqrScreen> createState() => _KhqrScreenState();
// }

// class _KhqrScreenState extends State<KhqrScreen> with TickerProviderStateMixin {
//   // ── polling ────────────────────────────────────────────────
//   Timer? _pollTimer;
//   bool _polling = false;

//   // ── countdown  (15 min) ───────────────────────────────────
//   static const _totalSeconds = 900;
//   int _remaining = _totalSeconds;
//   Timer? _countdownTimer;

//   // ── state ──────────────────────────────────────────────────
//   _KhqrState _state = _KhqrState.waiting;

//   // ── animations ─────────────────────────────────────────────
//   late final AnimationController _pulseCtrl; // ring pulse
//   late final AnimationController _scanCtrl; // scan line
//   late final AnimationController _successCtrl; // success pop

//   late final Animation<double> _pulseAnim;
//   late final Animation<double> _scanAnim;
//   late final Animation<double> _successScale;
//   late final Animation<double> _successFade;

//   @override
//   void initState() {
//     super.initState();

//     _pulseCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2000),
//     )..repeat(reverse: true);
//     _pulseAnim = Tween<double>(
//       begin: 0.88,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

//     _scanCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2200),
//     )..repeat();
//     _scanAnim = CurvedAnimation(parent: _scanCtrl, curve: Curves.easeInOut);

//     _successCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     _successScale = Tween<double>(
//       begin: 0.5,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _successCtrl, curve: Curves.easeOutBack));
//     _successFade = CurvedAnimation(parent: _successCtrl, curve: Curves.easeOut);

//     _startPolling();
//     _startCountdown();
//   }

//   @override
//   void dispose() {
//     _pollTimer?.cancel();
//     _countdownTimer?.cancel();
//     _pulseCtrl.dispose();
//     _scanCtrl.dispose();
//     _successCtrl.dispose();
//     super.dispose();
//   }

//   // ── polling every 2 s ─────────────────────────────────────
//   void _startPolling() {
//     _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _check());
//   }

//   Future<void> _check() async {
//     if (_polling || _state != _KhqrState.waiting) return;
//     _polling = true;
//     try {
//       final res = await ApiService().checkPayment(widget.md5);
//       if (res['success'] == true && res['status'] == 'SUCCESS') {
//         _pollTimer?.cancel();
//         _countdownTimer?.cancel();
//         if (mounted) {
//           setState(() => _state = _KhqrState.success);
//           _pulseCtrl.stop();
//           _scanCtrl.stop();
//           await _successCtrl.forward();
//           await Future.delayed(const Duration(milliseconds: 900));
//           if (mounted) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) =>
//                     OrderSuccessScreen(orderId: int.parse(widget.orderId)),
//               ),
//             );
//           }
//         }
//       }
//     } catch (_) {}
//     _polling = false;
//   }

//   // ── countdown ──────────────────────────────────────────────
//   void _startCountdown() {
//     _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (!mounted) return;
//       setState(() {
//         _remaining = (_remaining - 1).clamp(0, _totalSeconds);
//         if (_remaining == 0) {
//           _countdownTimer?.cancel();
//           _pollTimer?.cancel();
//           _state = _KhqrState.expired;
//           _pulseCtrl.stop();
//           _scanCtrl.stop();
//         }
//       });
//     });
//   }

//   String get _timeLabel {
//     final m = _remaining ~/ 60;
//     final s = _remaining % 60;
//     return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
//   }

//   void _cancel() {
//     _pollTimer?.cancel();
//     _countdownTimer?.cancel();
//     Navigator.pop(context);
//   }

//   // ── colors ─────────────────────────────────────────────────
//   static const _red = Color(0xFFD01E26); // Bakong / NBC red
//   static const _redDark = Color(0xFFAA1820);
//   static const _gold = Color(0xFFD4A017);

//   @override
//   Widget build(BuildContext context) {
//     final c = context.colors;
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: c.background,
//       body: Stack(
//         children: [
//           // ── decorative top arch ──────────────────────────
//           _TopArch(isDark: isDark),

//           SafeArea(
//             child: Column(
//               children: [
//                 // ── app bar ─────────────────────────────────
//                 _buildAppBar(c),

//                 Expanded(
//                   child: SingleChildScrollView(
//                     physics: const BouncingScrollPhysics(),
//                     padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
//                     child: Column(
//                       children: [
//                         const SizedBox(height: 8),

//                         // ── QR card ──────────────────────────
//                         _QrCard(
//                           qrUrl: widget.qrUrl,
//                           amount: widget.amount,
//                           timeLabel: _timeLabel,
//                           remaining: _remaining,
//                           total: _totalSeconds,
//                           state: _state,
//                           pulseAnim: _pulseAnim,
//                           scanAnim: _scanAnim,
//                           successScale: _successScale,
//                           successFade: _successFade,
//                           colors: c,
//                         ),

//                         const SizedBox(height: 16),

//                         // ── instruction steps ─────────────────
//                         if (_state == _KhqrState.waiting)
//                           _InstructionSteps(c: c),

//                         const SizedBox(height: 16),

//                         // ── bank logos row ────────────────────
//                         if (_state == _KhqrState.waiting) _BankLogosRow(c: c),

//                         const SizedBox(height: 20),

//                         // ── cancel / expired button ───────────
//                         if (_state != _KhqrState.success)
//                           _BottomButton(
//                             c: c,
//                             expired: _state == _KhqrState.expired,
//                             onTap: _cancel,
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppBar(AppColors c) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: _cancel,
//             child: Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.18),
//                 borderRadius: BorderRadius.circular(13),
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.3),
//                   width: 1,
//                 ),
//               ),
//               child: const Icon(
//                 Icons.arrow_back_ios_new_rounded,
//                 size: 15,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           const Spacer(),
//           const Text(
//             'KHQR Payment',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 17,
//               fontWeight: FontWeight.w800,
//               letterSpacing: -0.2,
//             ),
//           ),
//           const Spacer(),
//           const SizedBox(width: 40), // balance
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // TOP ARCH  (Bakong-style red gradient header)
// // ═══════════════════════════════════════════════════════════════

// class _TopArch extends StatelessWidget {
//   final bool isDark;
//   const _TopArch({required this.isDark});

//   static const _red = Color(0xFFD01E26);
//   static const _redDark = Color(0xFFAA1820);

//   @override
//   Widget build(BuildContext context) {
//     return ClipPath(
//       clipper: _ArchClipper(),
//       child: Container(
//         height: 230,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [_red, _redDark, Color(0xFF8B0000)],
//             stops: [0.0, 0.55, 1.0],
//           ),
//         ),
//         child: Stack(
//           children: [
//             // subtle pattern circles
//             Positioned(
//               top: -30,
//               right: -30,
//               child: Container(
//                 width: 160,
//                 height: 160,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.white.withOpacity(0.06),
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 40,
//               right: 60,
//               child: Container(
//                 width: 70,
//                 height: 70,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.white.withOpacity(0.04),
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 80,
//               left: -20,
//               child: Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.white.withOpacity(0.05),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ArchClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     path.lineTo(0, size.height - 50);
//     path.quadraticBezierTo(
//       size.width / 2,
//       size.height + 30,
//       size.width,
//       size.height - 50,
//     );
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(_) => false;
// }

// // ═══════════════════════════════════════════════════════════════
// // STATE ENUM
// // ═══════════════════════════════════════════════════════════════

// enum _KhqrState { waiting, success, expired }

// // ═══════════════════════════════════════════════════════════════
// // QR CARD
// // ═══════════════════════════════════════════════════════════════

// class _QrCard extends StatelessWidget {
//   final String qrUrl;
//   final String amount;
//   final String timeLabel;
//   final int remaining;
//   final int total;
//   final _KhqrState state;
//   final Animation<double> pulseAnim;
//   final Animation<double> scanAnim;
//   final Animation<double> successScale;
//   final Animation<double> successFade;
//   final AppColors colors;

//   const _QrCard({
//     required this.qrUrl,
//     required this.amount,
//     required this.timeLabel,
//     required this.remaining,
//     required this.total,
//     required this.state,
//     required this.pulseAnim,
//     required this.scanAnim,
//     required this.successScale,
//     required this.successFade,
//     required this.colors,
//   });

//   static const _red = Color(0xFFD01E26);
//   static const _gold = Color(0xFFD4A017);

//   @override
//   Widget build(BuildContext context) {
//     final c = colors;

//     return Container(
//       decoration: BoxDecoration(
//         color: c.cardBg,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.12),
//             blurRadius: 32,
//             offset: const Offset(0, 12),
//           ),
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // ── NBC / KHQR header ──────────────────────────
//           _cardHeader(c),

//           // ── merchant + amount ──────────────────────────
//           _merchantAmount(c),

//           // ── divider ────────────────────────────────────
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: _DashedLine(color: c.border),
//           ),
//           const SizedBox(height: 16),

//           // ── QR area ────────────────────────────────────
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: _QrArea(
//               qrUrl: qrUrl,
//               state: state,
//               scanAnim: scanAnim,
//               pulseAnim: pulseAnim,
//               successScale: successScale,
//               successFade: successFade,
//               colors: c,
//             ),
//           ),

//           const SizedBox(height: 16),

//           // ── countdown bar ──────────────────────────────
//           if (state == _KhqrState.waiting)
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
//               child: _CountdownBar(
//                 remaining: remaining,
//                 total: total,
//                 label: timeLabel,
//                 colors: c,
//               ),
//             ),

//           if (state == _KhqrState.expired)
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
//               child: _ExpiredBadge(c: c),
//             ),

//           if (state == _KhqrState.success)
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
//               child: _SuccessBanner(c: c),
//             ),

//           const SizedBox(height: 16),

//           // ── card footer ────────────────────────────────
//           _cardFooter(c),
//         ],
//       ),
//     );
//   }

//   Widget _cardHeader(AppColors c) {
//     return ClipRRect(
//       borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//       child: Container(
//         color: _red,
//         padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
//         child: Row(
//           children: [
//             // NBC QR mark
//             _NbcMark(),
//             const SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 Text(
//                   'KHQR',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 22,
//                     fontWeight: FontWeight.w900,
//                     letterSpacing: 1,
//                   ),
//                 ),
//                 Text(
//                   'National Bank of Cambodia',
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 11,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//             const Spacer(),
//             // "Secure" badge
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.18),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.3),
//                   width: 1,
//                 ),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: const [
//                   Icon(Icons.lock_rounded, size: 10, color: Colors.white),
//                   SizedBox(width: 4),
//                   Text(
//                     'SECURE',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 9,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 0.6,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _merchantAmount(AppColors c) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // merchant icon
//           Container(
//             width: 44,
//             height: 44,
//             decoration: BoxDecoration(
//               color: _red.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(13),
//             ),
//             child: const Icon(Icons.storefront_rounded, color: _red, size: 22),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Mart Shop',
//                   style: TextStyle(
//                     color: c.text2,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.baseline,
//                   textBaseline: TextBaseline.alphabetic,
//                   children: [
//                     Text(
//                       '\$ ',
//                       style: TextStyle(
//                         color: c.text3,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     Text(
//                       amount,
//                       style: TextStyle(
//                         color: c.text1,
//                         fontSize: 32,
//                         fontWeight: FontWeight.w900,
//                         letterSpacing: -1,
//                       ),
//                     ),
//                     Text(
//                       '  USD',
//                       style: TextStyle(
//                         color: c.text3,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           // gold seal
//           _GoldSeal(),
//         ],
//       ),
//     );
//   }

//   Widget _cardFooter(AppColors c) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
//       decoration: BoxDecoration(
//         color: c.surface2,
//         borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
//         border: Border(top: BorderSide(color: c.border, width: 0.5)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.verified_rounded, size: 14, color: _red),
//           const SizedBox(width: 6),
//           Text(
//             'Powered by National Bank of Cambodia',
//             style: TextStyle(
//               color: c.text3,
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const Spacer(),
//           _DotsLoader(color: _red),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // QR AREA  (scan line overlay + state overlays)
// // ═══════════════════════════════════════════════════════════════

// class _QrArea extends StatelessWidget {
//   final String qrUrl;
//   final _KhqrState state;
//   final Animation<double> scanAnim;
//   final Animation<double> pulseAnim;
//   final Animation<double> successScale;
//   final Animation<double> successFade;
//   final AppColors colors;

//   const _QrArea({
//     required this.qrUrl,
//     required this.state,
//     required this.scanAnim,
//     required this.pulseAnim,
//     required this.successScale,
//     required this.successFade,
//     required this.colors,
//   });

//   static const _red = Color(0xFFD01E26);

//   @override
//   Widget build(BuildContext context) {
//     final c = colors;

//     return AspectRatio(
//       aspectRatio: 1,
//       child: Stack(
//         children: [
//           // ── QR image ──────────────────────────────────
//           ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: AnimatedOpacity(
//               opacity: state == _KhqrState.waiting ? 1.0 : 0.25,
//               duration: const Duration(milliseconds: 400),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   border: Border.all(color: c.border, width: 1),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 padding: const EdgeInsets.all(10),
//                 child: Image.network(
//                   qrUrl,
//                   fit: BoxFit.contain,
//                   loadingBuilder: (_, child, prog) =>
//                       prog == null ? child : _QrSkeleton(colors: c),
//                   errorBuilder: (_, __, ___) => _QrFallback(colors: c),
//                 ),
//               ),
//             ),
//           ),

//           // ── corner markers ─────────────────────────────
//           if (state == _KhqrState.waiting) ..._corners(),

//           // ── animated scan line ─────────────────────────
//           if (state == _KhqrState.waiting)
//             AnimatedBuilder(
//               animation: scanAnim,
//               builder: (_, __) {
//                 return Positioned(
//                   top: scanAnim.value * 280,
//                   left: 12,
//                   right: 12,
//                   child: Opacity(
//                     opacity: 0.7,
//                     child: Container(
//                       height: 2.5,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             Colors.transparent,
//                             _red.withOpacity(0.8),
//                             _red,
//                             _red.withOpacity(0.8),
//                             Colors.transparent,
//                           ],
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: _red.withOpacity(0.5),
//                             blurRadius: 6,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),

//           // ── expired overlay ───────────────────────────
//           if (state == _KhqrState.expired)
//             Positioned.fill(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: Container(
//                   color: Colors.black.withOpacity(0.6),
//                   alignment: Alignment.center,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 60,
//                         height: 60,
//                         decoration: BoxDecoration(
//                           color: Colors.red.shade700,
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.timer_off_rounded,
//                           color: Colors.white,
//                           size: 30,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       const Text(
//                         'QR EXPIRED',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w900,
//                           letterSpacing: 1,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//           // ── success overlay ───────────────────────────
//           if (state == _KhqrState.success)
//             Positioned.fill(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: FadeTransition(
//                   opacity: successFade,
//                   child: Container(
//                     color: const Color(0xFF15803D).withOpacity(0.88),
//                     alignment: Alignment.center,
//                     child: ScaleTransition(
//                       scale: successScale,
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Container(
//                             width: 72,
//                             height: 72,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.green.withOpacity(0.4),
//                                   blurRadius: 20,
//                                 ),
//                               ],
//                             ),
//                             child: const Icon(
//                               Icons.check_rounded,
//                               color: Color(0xFF15803D),
//                               size: 40,
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           const Text(
//                             'PAYMENT SUCCESS',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 13,
//                               fontWeight: FontWeight.w900,
//                               letterSpacing: 1,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   List<Widget> _corners() {
//     const size = 24.0;
//     const thick = 3.0;
//     const r = 6.0;
//     const pad = 8.0;

//     Widget corner(AlignmentGeometry alignment, double rx, double ry) {
//       return Positioned.fill(
//         child: Align(
//           alignment: alignment,
//           child: CustomPaint(
//             size: const Size(size, size),
//             painter: _CornerPainter(
//               rotateX: rx,
//               rotateY: ry,
//               thickness: thick,
//               radius: r,
//             ),
//           ),
//         ),
//       );
//     }

//     return [
//       corner(Alignment.topLeft, 0, 0),
//       corner(Alignment.topRight, 0, 1),
//       corner(Alignment.bottomLeft, 1, 0),
//       corner(Alignment.bottomRight, 1, 1),
//     ];
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // CORNER PAINTER
// // ═══════════════════════════════════════════════════════════════

// class _CornerPainter extends CustomPainter {
//   final double rotateX;
//   final double rotateY;
//   final double thickness;
//   final double radius;

//   const _CornerPainter({
//     required this.rotateX,
//     required this.rotateY,
//     required this.thickness,
//     required this.radius,
//   });

//   static const _red = Color(0xFFD01E26);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = _red
//       ..strokeWidth = thickness
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;

//     canvas.save();
//     canvas.translate(size.width / 2, size.height / 2);
//     canvas.scale(rotateX == 1 ? -1 : 1, rotateY == 1 ? -1 : 1);
//     canvas.translate(-size.width / 2, -size.height / 2);

//     final path = Path()
//       ..moveTo(0, size.height * 0.55)
//       ..lineTo(0, radius)
//       ..arcToPoint(
//         Offset(radius, 0),
//         radius: Radius.circular(radius),
//         clockwise: false,
//       )
//       ..lineTo(size.width * 0.55, 0);

//     canvas.drawPath(path, paint);
//     canvas.restore();
//   }

//   @override
//   bool shouldRepaint(_) => false;
// }

// // ═══════════════════════════════════════════════════════════════
// // NBC MARK LOGO
// // ═══════════════════════════════════════════════════════════════

// class _NbcMark extends StatelessWidget {
//   const _NbcMark();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 40,
//       height: 40,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.15),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: CustomPaint(painter: _NbcPainter()),
//     );
//   }
// }

// class _NbcPainter extends CustomPainter {
//   static const _red = Color(0xFFD01E26);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final p = Paint()..style = PaintingStyle.fill;
//     final w = size.width;
//     final h = size.height;
//     final pad = w * 0.18;
//     final inner = w - pad * 2;
//     final cell = inner / 2;
//     final gap = cell * 0.15;
//     final cellW = (inner - gap) / 2;

//     // top-left
//     p.color = _red;
//     _roundRect(canvas, p, Offset(pad, pad), cellW, cellW, 3);
//     // top-right
//     p.color = _red;
//     _roundRect(canvas, p, Offset(pad + cellW + gap, pad), cellW, cellW, 3);
//     // bottom-left
//     p.color = _red;
//     _roundRect(canvas, p, Offset(pad, pad + cellW + gap), cellW, cellW, 3);
//     // bottom-right (lighter)
//     p.color = _red.withOpacity(0.3);
//     _roundRect(
//       canvas,
//       p,
//       Offset(pad + cellW + gap, pad + cellW + gap),
//       cellW,
//       cellW,
//       3,
//     );
//   }

//   void _roundRect(Canvas c, Paint p, Offset o, double w, double h, double r) {
//     c.drawRRect(
//       RRect.fromRectAndRadius(
//         Rect.fromLTWH(o.dx, o.dy, w, h),
//         Radius.circular(r),
//       ),
//       p,
//     );
//   }

//   @override
//   bool shouldRepaint(_) => false;
// }

// // ═══════════════════════════════════════════════════════════════
// // GOLD SEAL
// // ═══════════════════════════════════════════════════════════════

// class _GoldSeal extends StatelessWidget {
//   const _GoldSeal();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 52,
//       height: 52,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: const RadialGradient(
//           colors: [Color(0xFFFFD966), Color(0xFFD4A017)],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFFD4A017).withOpacity(0.4),
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: const Icon(Icons.verified_rounded, color: Colors.white, size: 26),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // COUNTDOWN BAR
// // ═══════════════════════════════════════════════════════════════

// class _CountdownBar extends StatelessWidget {
//   final int remaining;
//   final int total;
//   final String label;
//   final AppColors colors;

//   const _CountdownBar({
//     required this.remaining,
//     required this.total,
//     required this.label,
//     required this.colors,
//   });

//   static const _red = Color(0xFFD01E26);

//   @override
//   Widget build(BuildContext context) {
//     final c = colors;
//     final progress = remaining / total;
//     final isLow = remaining < 120;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: isLow ? Colors.red.shade50.withOpacity(0.5) : c.surface2,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isLow ? Colors.red.shade200 : c.border,
//           width: 1,
//         ),
//       ),
//       child: Column(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(4),
//             child: SizedBox(
//               height: 5,
//               child: LinearProgressIndicator(
//                 value: progress,
//                 backgroundColor: c.border,
//                 valueColor: AlwaysStoppedAnimation(
//                   isLow ? Colors.red.shade600 : _red,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.timer_outlined,
//                 size: 14,
//                 color: isLow ? Colors.red.shade600 : c.text3,
//               ),
//               const SizedBox(width: 5),
//               Text(
//                 'QR expires in  ',
//                 style: TextStyle(
//                   color: isLow ? Colors.red.shade600 : c.text3,
//                   fontSize: 12.5,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: isLow ? Colors.red.shade700 : c.text1,
//                   fontSize: 13,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // EXPIRED BADGE
// // ═══════════════════════════════════════════════════════════════

// class _ExpiredBadge extends StatelessWidget {
//   final AppColors c;
//   const _ExpiredBadge({required this.c});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.red.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.red.shade200, width: 1),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.timer_off_rounded, size: 16, color: Colors.red.shade700),
//           const SizedBox(width: 8),
//           Text(
//             'This QR code has expired',
//             style: TextStyle(
//               color: Colors.red.shade700,
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // SUCCESS BANNER
// // ═══════════════════════════════════════════════════════════════

// class _SuccessBanner extends StatelessWidget {
//   final AppColors c;
//   const _SuccessBanner({required this.c});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: const Color(0xFFDCFCE7),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFF86EFAC), width: 1),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: const [
//           Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF15803D)),
//           SizedBox(width: 8),
//           Text(
//             'Payment received! Redirecting…',
//             style: TextStyle(
//               color: Color(0xFF15803D),
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // INSTRUCTION STEPS
// // ═══════════════════════════════════════════════════════════════

// class _InstructionSteps extends StatelessWidget {
//   final AppColors c;
//   const _InstructionSteps({required this.c});

//   static const _steps = [
//     (Icons.phone_android_rounded, 'Open your banking app'),
//     (Icons.qr_code_scanner_rounded, 'Tap Scan / KHQR'),
//     (Icons.center_focus_strong_rounded, 'Scan the QR code'),
//     (Icons.check_circle_outline_rounded, 'Confirm payment'),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
//       decoration: BoxDecoration(
//         color: c.surface,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: c.border, width: 0.5),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'HOW TO PAY',
//             style: TextStyle(
//               color: c.text3,
//               fontSize: 10.5,
//               fontWeight: FontWeight.w800,
//               letterSpacing: 0.8,
//             ),
//           ),
//           const SizedBox(height: 12),
//           ...List.generate(_steps.length, (i) {
//             final (icon, label) = _steps[i];
//             final isLast = i == _steps.length - 1;
//             return Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Column(
//                   children: [
//                     Container(
//                       width: 32,
//                       height: 32,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFD01E26).withOpacity(0.1),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         icon,
//                         size: 15,
//                         color: const Color(0xFFD01E26),
//                       ),
//                     ),
//                     if (!isLast)
//                       Container(width: 1.5, height: 22, color: c.border),
//                   ],
//                 ),
//                 const SizedBox(width: 12),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 7),
//                   child: Text(
//                     label,
//                     style: TextStyle(
//                       color: c.text1,
//                       fontSize: 13.5,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // BANK LOGOS ROW
// // ═══════════════════════════════════════════════════════════════

// class _BankLogosRow extends StatelessWidget {
//   final AppColors c;
//   const _BankLogosRow({required this.c});

//   static const _banks = ['ABA', 'ACLEDA', 'Wing', 'Chip Mong', 'Canadia'];

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'ACCEPTED BY ALL KHQR BANKS',
//           style: TextStyle(
//             color: c.text3,
//             fontSize: 10,
//             fontWeight: FontWeight.w700,
//             letterSpacing: 0.6,
//           ),
//         ),
//         const SizedBox(height: 10),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: _banks.map((name) {
//             return Container(
//               margin: const EdgeInsets.only(right: 8),
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               decoration: BoxDecoration(
//                 color: c.surface,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: c.border, width: 0.5),
//               ),
//               child: Text(
//                 name,
//                 style: TextStyle(
//                   color: c.text2,
//                   fontSize: 10,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // BOTTOM BUTTON
// // ═══════════════════════════════════════════════════════════════

// class _BottomButton extends StatefulWidget {
//   final AppColors c;
//   final bool expired;
//   final VoidCallback onTap;

//   const _BottomButton({
//     required this.c,
//     required this.expired,
//     required this.onTap,
//   });

//   @override
//   State<_BottomButton> createState() => _BottomButtonState();
// }

// class _BottomButtonState extends State<_BottomButton>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl;
//   late final Animation<double> _scale;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 80),
//       reverseDuration: const Duration(milliseconds: 160),
//     );
//     _scale = Tween(
//       begin: 1.0,
//       end: 0.97,
//     ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = widget.c;
//     return GestureDetector(
//       onTapDown: (_) {
//         _ctrl.forward();
//         HapticFeedback.lightImpact();
//       },
//       onTapUp: (_) => _ctrl.reverse(),
//       onTapCancel: () => _ctrl.reverse(),
//       onTap: widget.onTap,
//       child: ScaleTransition(
//         scale: _scale,
//         child: Container(
//           width: double.infinity,
//           height: 54,
//           decoration: BoxDecoration(
//             color: widget.expired ? const Color(0xFFD01E26) : c.surface2,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: widget.expired ? const Color(0xFFD01E26) : c.border,
//               width: 1,
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 widget.expired ? Icons.refresh_rounded : Icons.close_rounded,
//                 size: 18,
//                 color: widget.expired ? Colors.white : c.text2,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 widget.expired ? 'Try Again' : 'Cancel Payment',
//                 style: TextStyle(
//                   color: widget.expired ? Colors.white : c.text1,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // DOTS LOADER
// // ═══════════════════════════════════════════════════════════════

// class _DotsLoader extends StatefulWidget {
//   final Color color;
//   const _DotsLoader({required this.color});

//   @override
//   State<_DotsLoader> createState() => _DotsLoaderState();
// }

// class _DotsLoaderState extends State<_DotsLoader>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     )..repeat();
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _ctrl,
//       builder: (_, __) {
//         return Row(
//           mainAxisSize: MainAxisSize.min,
//           children: List.generate(3, (i) {
//             final offset = i / 3;
//             final v = ((_ctrl.value - offset) % 1.0);
//             final scale = v < 0.5
//                 ? Curves.easeOut.transform(v * 2)
//                 : Curves.easeIn.transform((1 - v) * 2);
//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 2),
//               child: Transform.scale(
//                 scale: 0.5 + scale * 0.5,
//                 child: Opacity(
//                   opacity: 0.3 + scale * 0.7,
//                   child: Container(
//                     width: 5,
//                     height: 5,
//                     decoration: BoxDecoration(
//                       color: widget.color,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }),
//         );
//       },
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // QR SKELETON
// // ═══════════════════════════════════════════════════════════════

// class _QrSkeleton extends StatefulWidget {
//   final AppColors colors;
//   const _QrSkeleton({required this.colors});

//   @override
//   State<_QrSkeleton> createState() => _QrSkeletonState();
// }

// class _QrSkeletonState extends State<_QrSkeleton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double> _anim;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     )..repeat(reverse: true);
//     _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _anim,
//       builder: (_, __) => Container(
//         color: Color.lerp(
//           widget.colors.surface2,
//           widget.colors.border,
//           _anim.value,
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // QR FALLBACK
// // ═══════════════════════════════════════════════════════════════

// class _QrFallback extends StatelessWidget {
//   final AppColors colors;
//   const _QrFallback({required this.colors});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: colors.surface2,
//       child: Icon(Icons.qr_code_2_rounded, size: 96, color: colors.text3),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // DASHED LINE
// // ═══════════════════════════════════════════════════════════════

// class _DashedLine extends StatelessWidget {
//   final Color color;
//   const _DashedLine({required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: _DashedLinePainter(color: color),
//       size: const Size(double.infinity, 1),
//     );
//   }
// }

// class _DashedLinePainter extends CustomPainter {
//   final Color color;
//   const _DashedLinePainter({required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     const dashW = 6.0;
//     const gapW = 4.0;
//     final paint = Paint()
//       ..color = color
//       ..strokeWidth = 1.5;
//     double x = 0;
//     while (x < size.width) {
//       canvas.drawLine(Offset(x, 0), Offset(x + dashW, 0), paint);
//       x += dashW + gapW;
//     }
//   }

//   @override
//   bool shouldRepaint(_DashedLinePainter old) => old.color != color;
// }
