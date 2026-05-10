import 'package:flutter/material.dart';

import '../../../core/widgets/mediscan_scaffold.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/responsive_center.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const records = [
      ('Prescription', 'Uploaded today', 'AI extracted 3 medicines'),
      ('Blood report', '12 Apr 2026', 'HbA1c improved by 0.4%'),
      ('Consultation note', '02 Apr 2026', 'Follow-up after 14 days'),
      ('Vaccination certificate', '14 Feb 2026', 'PDF available'),
    ];

    return MediScanScaffold(
      selectedIndex: 4,
      child: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Records',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text('Securely stored. Only you can access them.'),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PremiumCard(
              color: const Color(0xFFE0F7F3),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, size: 34),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Private vault for prescriptions, lab reports, invoices, and doctor notes.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ...records.map(
              (record) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PremiumCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.$1,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(record.$2),
                            Text(record.$3),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
