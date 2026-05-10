import 'package:flutter/material.dart';

import '../../../core/widgets/mediscan_scaffold.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/responsive_center.dart';

class CircleScreen extends StatelessWidget {
  const CircleScreen({super.key});

  static const benefits = [
    'Up to 25% off on medicines',
    'Free unlimited delivery',
    '20% off on lab tests',
    'Free doctor consultations',
    'Exclusive Circle deals',
    'Priority customer support',
  ];

  @override
  Widget build(BuildContext context) {
    return MediScanScaffold(
      selectedIndex: 0,
      child: ResponsiveCenter(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PremiumCard(
              color: const Color(0xFFE11D48),
              padding: const EdgeInsets.all(28),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.favorite, color: Colors.white, size: 42),
                  SizedBox(height: 12),
                  Text(
                    'MedBill Circle',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Save more on every order with our annual membership.',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs. 399',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 6),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          '/ year',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PremiumCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Membership benefits',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 16),
                  ...benefits.map(
                    (benefit) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(benefit)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () {},
                    child: const Text('Become a Circle member'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
