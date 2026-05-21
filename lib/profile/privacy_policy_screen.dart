import 'package:flutter/material.dart';
import 'profile_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
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
            'Last updated: January 2024',
            style: TextStyle(fontSize: 12, color: c.text2),
          ),
          const SizedBox(height: 20),
          _Section(
            title: 'Information We Collect',
            content:
                'We collect information you provide directly, such as your name, email, phone number, and delivery address. We also collect usage data to improve our services.',
          ),
          _Section(
            title: 'How We Use Your Information',
            content:
                'We use your information to process orders, provide customer support, send notifications about your orders, and improve our app experience.',
          ),
          _Section(
            title: 'Data Sharing',
            content:
                'We do not sell your personal information. We may share data with delivery partners to fulfill your orders and with payment processors to complete transactions.',
          ),
          _Section(
            title: 'Data Security',
            content:
                'We implement industry-standard security measures to protect your personal information. However, no method of transmission over the internet is 100% secure.',
          ),
          _Section(
            title: 'Your Rights',
            content:
                'You have the right to access, update, or delete your personal information at any time through your account settings or by contacting our support team.',
          ),
          _Section(
            title: 'Cookies',
            content:
                'We use cookies and similar technologies to enhance your experience, analyze usage patterns, and deliver personalized content.',
          ),
          _Section(
            title: 'Contact Us',
            content:
                'If you have questions about this Privacy Policy, please contact us at support@martapp.com or call (+855) 23 216 380.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;
  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final c = context;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
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
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(fontSize: 14, color: c.text2, height: 1.6),
          ),
        ],
      ),
    );
  }
}
