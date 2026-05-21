import 'package:flutter/material.dart';
import 'profile_screen.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

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
          'About Us',
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
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c.border),
              ),
              child: Center(
                child: Text(
                  'M',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: c.accent,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Mart',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: c.text1,
              ),
            ),
          ),
          Center(
            child: Text(
              'Version 2.4.1',
              style: TextStyle(fontSize: 12, color: c.text2),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Our Story',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: c.text1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Mart is a leading e-commerce platform in Cambodia, dedicated to providing the best online shopping experience. We offer a wide range of products from groceries to electronics, delivered right to your doorstep.',
                  style: TextStyle(fontSize: 14, color: c.text2, height: 1.6),
                ),
                const SizedBox(height: 14),
                Text(
                  'Founded in 2022, we have grown to serve thousands of customers across Phnom Penh and beyond. Our mission is to make shopping convenient, affordable, and enjoyable for everyone.',
                  style: TextStyle(fontSize: 14, color: c.text2, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.location_on_outlined,
            title: 'Address',
            value: 'Phnom Penh, Cambodia',
          ),
          const SizedBox(height: 10),
          _InfoCard(
            icon: Icons.email_outlined,
            title: 'Email',
            value: 'support@martapp.com',
          ),
          const SizedBox(height: 10),
          _InfoCard(
            icon: Icons.phone_outlined,
            title: 'Phone',
            value: '(+855) 23 216 380',
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final c = context;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: c.text2),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: c.text2)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c.text1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
