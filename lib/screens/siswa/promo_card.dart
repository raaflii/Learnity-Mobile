import 'dart:async';
import 'package:flutter/material.dart';

class PromoCarousel extends StatefulWidget {
  const PromoCarousel({super.key});

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  late final PageController _controller;
  late final Timer _timer;

  final List<Widget> _originalCards = [
    _buildPromoCard('Join Backend Web Course', '30+ lessons'),
    _buildPromoCard('Join Flutter Mobile Course', '25+ lessons'),
    _buildPromoCard('Join UI/UX Design Course', '40+ lessons'),
  ];

  List<Widget> get _promoCards => [
    ..._originalCards,
    ..._originalCards,
    ..._originalCards,
  ];

  int get _initialPage => _originalCards.length;

  static Widget _buildPromoCard(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEBFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Icon Accent
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lightbulb_outline,
                color: Colors.blueAccent,
                size: 34,
              ),
            ),
            const SizedBox(height: 11),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: _initialPage,
      viewportFraction: 0.85,
    );

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_controller.hasClients) {
        int nextPage = _controller.page!.toInt() + 1;
        _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: PageView.builder(
        controller: _controller,
        itemCount: _promoCards.length,
        onPageChanged: (index) {
          // Infinite scroll trick
          if (index >= _promoCards.length - _originalCards.length) {
            _controller.jumpToPage(_initialPage);
          } else if (index <= _originalCards.length - 1) {
            _controller.jumpToPage(_initialPage);
          }
        },
        itemBuilder: (context, index) {
          return _promoCards[index % _promoCards.length];
        },
      ),
    );
  }
}
