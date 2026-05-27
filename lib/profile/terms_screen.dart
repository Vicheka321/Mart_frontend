import 'package:flutter/material.dart';
import 'profile_screen.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          'Terms and Conditions',
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
            title: '1. Acceptance of Terms',
            content:
                'By accessing and using the Mart application, you agree to be bound by these Terms and Conditions. If you do not agree with any part of these terms, you may not use our services.',
          ),
          _Section(
            title: '2. User Account',
            content:
                'You are responsible for maintaining the confidentiality of your account credentials. You agree to notify us immediately of any unauthorized use of your account.',
          ),
          _Section(
            title: '3. Orders and Payments',
            content:
                'All orders are subject to availability. We reserve the right to refuse or cancel any order. Payment must be made at the time of purchase through our accepted payment methods.',
          ),
          _Section(
            title: '4. Delivery',
            content:
                'Delivery times are estimates and may vary. We are not responsible for delays caused by circumstances beyond our control. Risk of loss passes to you upon delivery.',
          ),
          _Section(
            title: '5. Returns and Refunds',
            content:
                'Items may be returned within 7 days of delivery if they are unused and in original packaging. Refunds will be processed within 5-7 business days after we receive the returned item.',
          ),
          _Section(
            title: '6. Privacy',
            content:
                'Your use of our services is also governed by our Privacy Policy. Please review our Privacy Policy to understand our practices.',
          ),
          _Section(
            title: '7. Limitation of Liability',
            content:
                'Mart shall not be liable for any indirect, incidental, or consequential damages arising from your use of our services.',
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
