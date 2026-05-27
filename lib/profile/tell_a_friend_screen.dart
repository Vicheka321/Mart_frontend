import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'profile_screen.dart';

class TellAFriendScreen extends StatelessWidget {
  const TellAFriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        foregroundColor: c.text1,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Tell a Friend',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: c.text1,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share Mart with your friends and family. Let them enjoy the same great shopping experience!',
              style: TextStyle(fontSize: 14, color: c.text2, height: 1.5),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.border),
              ),
              child: Column(
                children: [
                  Text(
                    'Your Referral Code',
                    style: TextStyle(fontSize: 13, color: c.text2),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: c.accentBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'MART2024',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: c.text1,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Builder(
                    builder: (ctx) => GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          const ClipboardData(text: 'MART2024'),
                        );
                        HapticFeedback.mediumImpact();
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: const Text('Referral code copied!'),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Tap to copy',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: c.accent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Share via',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: c.text1,
              ),
            ),
            const SizedBox(height: 10),
            _ShareOption(
              icon: Icons.message_rounded,
              iconBg: const Color(0xFF10B981),
              title: 'SMS',
              subtitle: 'Send via text message',
            ),
            const SizedBox(height: 10),
            _ShareOption(
              icon: Icons.facebook_rounded,
              iconBg: const Color(0xFF0084FF),
              title: 'Messenger',
              subtitle: 'Share on Messenger',
            ),
            const SizedBox(height: 10),
            _ShareOption(
              icon: Icons.telegram,
              iconBg: const Color(0xFF0088CC),
              title: 'Telegram',
              subtitle: 'Share on Telegram',
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  const _ShareOption({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final c = context;
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 22, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: c.text1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: c.text2)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
