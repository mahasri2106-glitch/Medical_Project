import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/responsive_center.dart';
import '../../cart/presentation/cart_controller.dart';
import '../data/demo_catalog.dart';

class MedicineDetailScreen extends ConsumerWidget {
  const MedicineDetailScreen({required this.medicineId, super.key});

  final String medicineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicine = demoMedicines.firstWhere(
      (item) => item.id == medicineId,
      orElse: () => demoMedicines.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine details'),
        actions: [
          IconButton(
            tooltip: 'Wishlist',
            onPressed: () {},
            icon: const Icon(Icons.favorite_border),
          ),
          IconButton(
            tooltip: 'Cart',
            onPressed: () => context.go('/cart'),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PremiumCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.medication, size: 86),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    medicine.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  Text(medicine.composition),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text(medicine.category)),
                      Chip(label: Text(medicine.inStock ? 'In stock' : 'Out')),
                      if (medicine.prescriptionRequired)
                        const Chip(label: Text('Prescription required')),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Rs. ${medicine.price.toStringAsFixed(0)}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: medicine.inStock
                            ? () => ref
                                .read(cartControllerProvider.notifier)
                                .add(medicine)
                            : null,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _InfoSection(title: 'Uses', items: medicine.uses),
            _InfoSection(title: 'Side effects', items: medicine.sideEffects),
            PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Safety advice',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(medicine.safetyAdvice),
                  const SizedBox(height: 12),
                  Text('Manufacturer: ${medicine.manufacturer}'),
                  const Text('Expiry: Check pack before use'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer reviews',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18),
                      const SizedBox(width: 4),
                      Text('${medicine.rating} from verified buyers'),
                    ],
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

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
