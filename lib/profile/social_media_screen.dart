import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'profile_screen.dart';

class SocialMediaScreen extends StatelessWidget {
  const SocialMediaScreen({super.key});

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
          'Social Media',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: c.text1,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text(
            'Follow us on social media to stay updated with the latest news, promotions, and more.',
            style: TextStyle(fontSize: 14, color: c.text2, height: 1.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Our Channels',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: c.text1,
            ),
          ),
          const SizedBox(height: 10),
          _SocialCard(
            icon: Icons.facebook_rounded,
            iconBg: const Color(0xFF1877F2),
            title: 'Facebook',
            subtitle: '@MartOfficial',
          ),
          const SizedBox(height: 10),
          _SocialCard(
            icon: Icons.camera_alt_outlined,
            iconBg: const Color(0xFFE4405F),
            title: 'Instagram',
            subtitle: '@mart_official',
          ),
          const SizedBox(height: 10),
          _SocialCard(
            icon: Icons.telegram,
            iconBg: const Color(0xFF0088CC),
            title: 'Telegram',
            subtitle: '@MartChannel',
          ),
          const SizedBox(height: 10),
          _SocialCard(
            icon: Icons.tiktok,
            iconBg: c.text1,
            title: 'TikTok',
            subtitle: '@mart_official',
          ),
          const SizedBox(height: 10),
          _SocialCard(
            icon: Icons.play_arrow_rounded,
            iconBg: const Color(0xFFFF0000),
            title: 'YouTube',
            subtitle: 'Mart Official',
          ),
        ],
      ),
    );
  }
}

class _SocialCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  const _SocialCard({
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
            const Spacer(),
            Icon(Icons.open_in_new_rounded, size: 18, color: c.text2),
          ],
        ),
      ),
    );
  }
}
