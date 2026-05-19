import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'profile_screen.dart';

class RateAppScreen extends StatefulWidget {
  const RateAppScreen({super.key});

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  int _selectedRating = 0;
  final _feedbackCtrl = TextEditingController();
  bool _submitted = false;

  final List<String> _selectedTags = [];

  static const _feedbackTags = [
    'Easy to use',
    'Fast delivery',
    'Great prices',
    'Good selection',
    'Beautiful design',
    'Reliable service',
    'Needs improvement',
    'Slow loading',
  ];

  static const _emojiMap = {1: '😞', 2: '😕', 3: '😐', 4: '😊', 5: '🤩'};

  static const _labelMap = {
    1: 'Terrible',
    2: 'Poor',
    3: 'Okay',
    4: 'Good',
    5: 'Excellent!',
  };

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _feedbackCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context;
    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: c.bg,
            elevation: 0,
            leading: _backButton(c),
            title: Text(
              'Rate the App',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: c.text1,
                letterSpacing: -0.3,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: _submitted ? _buildThankYou(c) : _buildRatingForm(c),
            ),
          ),
        ],
      ),
    );
  }

  // ── Rating Form ─────────────────────────────────────────────
  Widget _buildRatingForm(BuildContext c) {
    return Column(
      children: [
        const SizedBox(height: 8),

        // ── Hero ──────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: c.isDark
                  ? [const Color(0xFF4A1D96), const Color(0xFF1E3A5F)]
                  : [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enjoying Mart?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your feedback helps us improve and serve you better',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // ── Star Rating ───────────────────────────────────────
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(c.isDark ? 0.25 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Tap a star to rate',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c.text2,
                ),
              ),
              const SizedBox(height: 16),

              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final starIndex = i + 1;
                  final isSelected = starIndex <= _selectedRating;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() => _selectedRating = starIndex);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFEF3C7)
                            : c.accentBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFF59E0B)
                              : c.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        isSelected
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 24,
                        color: isSelected ? const Color(0xFFF59E0B) : c.text2,
                      ),
                    ),
                  );
                }),
              ),

              // Emoji + Label
              if (_selectedRating > 0) ...[
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Column(
                    key: ValueKey(_selectedRating),
                    children: [
                      Text(
                        _emojiMap[_selectedRating] ?? '',
                        style: const TextStyle(fontSize: 36),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _labelMap[_selectedRating] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: c.text1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // ── Tags ──────────────────────────────────────────────
        if (_selectedRating > 0) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'What do you like most?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: c.text1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _feedbackTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      isSelected
                          ? _selectedTags.remove(tag)
                          : _selectedTags.add(tag);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF8B5CF6).withOpacity(0.1)
                          : c.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF8B5CF6) : c.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected ? const Color(0xFF8B5CF6) : c.text1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // ── Feedback Text ─────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(c.isDark ? 0.25 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Additional feedback (optional)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.text2,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _feedbackCtrl,
                  maxLines: 3,
                  style: TextStyle(fontSize: 14, color: c.text1),
                  decoration: InputDecoration(
                    hintText: 'Tell us more about your experience...',
                    hintStyle: TextStyle(color: c.text2, fontSize: 13),
                    filled: true,
                    fillColor: c.accentBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Submit Button ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                setState(() => _submitted = true);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Submit Rating',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ],
    );
  }

  // ── Thank You State ─────────────────────────────────────────
  Widget _buildThankYou(BuildContext c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 44,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Thank You! 🎉',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: c.text1,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your feedback means the world to us.\nWe\'re constantly working to make Mart better for you.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: c.text2, height: 1.5),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.border),
              ),
              child: Text(
                'Back to Profile',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: c.text1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backButton(BuildContext c) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border),
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: c.text1),
      ),
    );
  }
}
