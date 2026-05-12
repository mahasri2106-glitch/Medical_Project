import 'package:flutter/material.dart';

import '../../../core/widgets/mediscan_scaffold.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/responsive_center.dart';

class LabTestsScreen extends StatefulWidget {
  const LabTestsScreen({super.key});

  @override
  State<LabTestsScreen> createState() => _LabTestsScreenState();
}

class _LabTestsScreenState extends State<LabTestsScreen> {
  String _search = '';
  String _category = '';

  static const tests = [
    ('Complete Blood Count (CBC)', 'Blood', 350, 500, false),
    ('Lipid Profile', 'Heart', 600, 900, true),
    ('Thyroid Profile (T3 T4 TSH)', 'Hormone', 500, 750, false),
    ('Diabetes - HbA1c', 'Diabetes', 400, 600, false),
    ('Vitamin D Total', 'Vitamin', 1200, 1800, false),
    ('Liver Function Test (LFT)', 'Liver', 700, 1000, true),
    ('Kidney Function Test', 'Kidney', 750, 1100, false),
    ('COVID-19 RT-PCR', 'Infection', 500, 800, false),
  ];

  static const categories = [
    'Blood',
    'Heart',
    'Hormone',
    'Diabetes',
    'Vitamin',
    'Liver',
    'Kidney',
    'Infection',
  ];

  @override
  Widget build(BuildContext context) {
    final list = tests.where((test) {
      final matchesCategory = _category.isEmpty || test.$2 == _category;
      final matchesSearch = _search.isEmpty ||
          test.$1.toLowerCase().contains(_search.toLowerCase());
      return matchesCategory && matchesSearch;
    });

    return MediScanScaffold(
      selectedIndex: 0,
      child: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Lab Tests',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text('Free home sample collection - Reports in 24 hrs'),
            const SizedBox(height: 18),
            PremiumCard(
              color: const Color(0xFFE0F7F3),
              child: const Row(
                children: [
                  Icon(Icons.home_outlined, color: Color(0xFF009B8E)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Collect sample from: Add your address at checkout',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search lab tests',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _search = value),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _category.isEmpty,
                    onTap: () => setState(() => _category = ''),
                  ),
                  ...categories.map(
                    (category) => _FilterChip(
                      label: category,
                      selected: _category == category,
                      onTap: () => setState(() => _category = category),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...list.map(
              (test) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PremiumCard(
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.biotech_outlined,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              test.$1,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${test.$2}${test.$5 ? ' - Fasting required' : ''}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Row(
                              children: [
                                Text(
                                  'Rs. ${test.$3}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Rs. ${test.$4}',
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Lab Booking Details'),
                              content: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                      'Any specific instructions for sample collector?'),
                                  TextField(),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Lab Test Booked'),
                                        content: Text(
                                            'Your lab test for ${test.$1} has been booked successfully.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: const Text('Confirm'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Book'),
                      ),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
