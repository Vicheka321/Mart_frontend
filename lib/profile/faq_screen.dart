import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'profile_screen.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _faqs = [
    {
      'q': 'How do I place an order?',
      'a':
          'Browse products, add items to your cart, then proceed to checkout. Select your delivery address and payment method to complete.',
    },
    {
      'q': 'How can I track my order?',
      'a':
          'Go to Orders tab and tap on your order to see real-time tracking and estimated delivery time.',
    },
    {
      'q': 'What payment methods are accepted?',
      'a': 'We accept Visa, Mastercard, ABA Pay, Wing, and Cash on Delivery.',
    },
    {
      'q': 'How do I return an item?',
      'a':
          'Contact our support within 7 days of delivery. Items must be unused and in original packaging.',
    },
    {
      'q': 'How do I change my delivery address?',
      'a':
          'Go to Profile → Addresses to add or edit your delivery addresses. You can also change during checkout.',
    },
    {
      'q': 'Is there a delivery fee?',
      'a':
          'Delivery is free for orders above \$25. For smaller orders, a flat fee of \$2 applies.',
    },
  ];

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
          'FAQs',
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
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 14, color: c.text2, height: 1.5),
          ),
          const SizedBox(height: 20),
          ..._faqs.map(
            (faq) => _FaqItem(question: faq['q']!, answer: faq['a']!),
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = context;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _expanded = !_expanded);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.text1,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: c.text2,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  widget.answer,
                  style: TextStyle(fontSize: 13, color: c.text2, height: 1.5),
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}
