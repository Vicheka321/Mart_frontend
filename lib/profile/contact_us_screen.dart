import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'profile_screen.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

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
          'Contact Center',
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
            "Welcome to Mart's Call Center page. Don't hesitate to contact us for any concerns or comments via below address",
            style: TextStyle(fontSize: 14, color: c.text2, height: 1.5),
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Contact Services'),
          const SizedBox(height: 10),
          _ContactCard(
            icon: Icons.phone_outlined,
            iconColor: c.text1,
            iconBg: Colors.transparent,
            title: 'Contact Services',
            subtitle: '(+855) 23 216 380',
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Chat with us'),
          const SizedBox(height: 10),
          _ContactCard(
            icon: Icons.facebook_rounded,
            iconColor: Colors.white,
            iconBg: const Color(0xFF0084FF),
            title: 'Messenger',
            subtitle: 'Connect with us on Messenger',
          ),
          const SizedBox(height: 10),
          _ContactCard(
            icon: Icons.telegram,
            iconColor: Colors.white,
            iconBg: const Color(0xFF0088CC),
            title: 'Telegram',
            subtitle: 'Connect with us on Telegram',
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: context.text1,
    ),
  );
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  const _ContactCard({
    required this.icon,
    required this.iconColor,
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
              child: Icon(icon, size: 22, color: iconColor),
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
