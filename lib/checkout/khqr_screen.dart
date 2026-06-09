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

  const KhqrScreen({
    super.key,
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
  Timer?  _pollTimer;
  bool    _polling = false;

  // ── Countdown  (15 min = 900 s) ────────────
  static const _totalSeconds = 900;
  int     _remaining = _totalSeconds;
  Timer?  _countdownTimer;

  // ── State ──────────────────────────────────
  _KhqrState _state = _KhqrState.waiting;

  // ── Pulse animation ────────────────────────
  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

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
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const OrderSuccessScreen()));
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
              _KhqrCard(
                qrUrl:  widget.qrUrl,
                amount: widget.amount,
                colors: c,
              ),
              const SizedBox(height: 14),
              _StatusCard(
                state:     _state,
                timeLabel: _timeLabel,
                remaining: _remaining,
                total:     _totalSeconds,
                pulseAnim: _pulseAnim,
                colors:    c,
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
                borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: c.text1),
          ),
        ),
      ),
      title: Text('KHQR Payment',
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w700, color: c.text1)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: c.border),
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness:
            Theme.of(context).brightness == Brightness.dark
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
  final String   qrUrl;
  final String   amount;
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
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              color: _khqrRed,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  _KhqrMark(),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('KHQR',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5)),
                      Text('National Bank of Cambodia',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500)),
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
                Text('Mart Shop',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: c.text1)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('USD ',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: c.text2)),
                    Text(amount,
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: c.text1,
                            letterSpacing: -0.5)),
                  ],
                ),
              ],
            ),
          ),

          // ── Dashed divider ──────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 12),
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
            padding:
                const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.border)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded,
                          size: 12, color: Color(0xFF16A34A)),
                      SizedBox(width: 4),
                      Text('Secure payment',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF15803D))),
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
  final _KhqrState      state;
  final String          timeLabel;
  final int             remaining;
  final int             total;
  final Animation<double> pulseAnim;
  final AppColors       colors;

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
                colors: c),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon() {
    switch (state) {
      case _KhqrState.success:
        return Container(
          width: 52, height: 52,
          decoration: const BoxDecoration(
              color: Color(0xFF16A34A), shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded,
              size: 28, color: Colors.white),
        );
      case _KhqrState.expired:
        return Container(
          width: 52, height: 52,
          decoration: const BoxDecoration(
              color: Color(0xFFDC2626), shape: BoxShape.circle),
          child: const Icon(Icons.timer_off_rounded,
              size: 26, color: Colors.white),
        );
      case _KhqrState.waiting:
        return ScaleTransition(
          scale: pulseAnim,
          child: Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: colors.accentLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.qr_code_2_rounded,
                size: 26, color: colors.accent),
          ),
        );
    }
  }

  Widget _buildTitle(AppColors c) {
    final (text, color) = switch (state) {
      _KhqrState.success => ('Payment successful!', const Color(0xFF15803D)),
      _KhqrState.expired => ('QR code expired',    const Color(0xFFDC2626)),
      _KhqrState.waiting => ('Waiting for payment', c.text1),
    };
    return Text(text,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w800, color: color));
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
    return Text(text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: color, height: 1.5));
  }
}

// ─────────────────────────────────────────────
// COUNTDOWN BAR
// ─────────────────────────────────────────────

class _CountdownBar extends StatelessWidget {
  final int       remaining;
  final int       total;
  final String    label;
  final AppColors colors;

  const _CountdownBar({
    required this.remaining,
    required this.total,
    required this.label,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c        = colors;
    final progress = remaining / total;
    final isLow    = remaining < 60;

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
            Icon(Icons.timer_outlined,
                size: 13,
                color: isLow ? const Color(0xFFDC2626) : c.text3),
            const SizedBox(width: 4),
            Text('Expires in $label',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isLow ? const Color(0xFFDC2626) : c.text3)),
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
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
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
            final v      = ((_ctrl.value - offset) % 1.0);
            final scale  = v < 0.5
                ? Curves.easeOut.transform(v * 2)
                : Curves.easeIn.transform((1 - v) * 2);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.scale(
                scale: 0.5 + scale * 0.5,
                child: Opacity(
                  opacity: 0.3 + scale * 0.7,
                  child: Container(
                    width: 7, height: 7,
                    decoration: BoxDecoration(
                        color: widget.color, shape: BoxShape.circle),
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
  final AppColors    colors;
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
          child: Text('Cancel payment',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: c.text1)),
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
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

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
      child: Icon(Icons.qr_code_2_rounded,
          size: 96, color: colors.text3),
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
    const gapW  = 5.0;
    final paint = Paint()..color = color..strokeWidth = 1.5;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashW, 0), paint);
      x += dashW + gapW;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}