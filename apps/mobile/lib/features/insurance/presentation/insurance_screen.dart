import 'package:flutter/material.dart';

import '../../../core/widgets/mediscan_scaffold.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/responsive_center.dart';

class InsuranceScreen extends StatelessWidget {
  const InsuranceScreen({super.key});

  static const plans = [
    (
      'Family Floater Health',
      'Rs. 10 Lakh',
      'Rs. 8500/yr',
      'Most popular',
      ['Cashless 10,000+ hospitals', 'Free annual health check'],
    ),
    (
      'Senior Citizen Care',
      'Rs. 5 Lakh',
      'Rs. 12000/yr',
      '60+ years',
      ['Pre-existing disease cover', 'Domiciliary treatment'],
    ),
    (
      'Critical Illness',
      'Rs. 25 Lakh',
      'Rs. 6200/yr',
      'Cancer & heart',
      ['Lump-sum on diagnosis', '36 critical illnesses'],
    ),
    (
      'Personal Accident',
      'Rs. 15 Lakh',
      'Rs. 2400/yr',
      'Best value',
      ['24x7 worldwide cover', 'Permanent disability cover'],
    ),
    (
      'Top-Up Health',
      'Rs. 50 Lakh',
      'Rs. 4900/yr',
      'Add-on',
      ['Low premium high cover', 'Includes maternity'],
    ),
    (
      'Diabetes Safe',
      'Rs. 7 Lakh',
      'Rs. 9800/yr',
      'For diabetics',
      ['Day-1 cover for diabetes', 'Wellness rewards'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MediScanScaffold(
      selectedIndex: 0,
      child: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 34,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buy Insurance',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text('Compare. Choose. Get insured in minutes.'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 760 ? 3 : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: plans.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    childAspectRatio: columns == 1 ? 1.25 : .9,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    return PremiumCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F7F3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Text(
                                plan.$4,
                                style: const TextStyle(
                                  color: Color(0xFF009B8E),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            plan.$1,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(child: _Metric('Cover', plan.$2)),
                                Expanded(child: _Metric('Premium', plan.$3)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...plan.$5.map(
                            (perk) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    size: 18,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text(perk)),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          FilledButton(
                            onPressed: () {},
                            child: const Text('Buy now'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    );
  }
}
