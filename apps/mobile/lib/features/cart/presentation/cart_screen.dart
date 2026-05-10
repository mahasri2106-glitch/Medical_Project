import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/responsive_center.dart';
import 'cart_controller.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(cartControllerProvider);
    final subtotal = ref.watch(cartTotalProvider);
    final delivery = subtotal > 499 || subtotal == 0 ? 0 : 49;
    final tax = subtotal * .05;
    final total = subtotal + delivery + tax;

    return Scaffold(
      appBar: AppBar(title: const Text('Cart and checkout')),
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (lines.isEmpty)
              const PremiumCard(
                child: Column(
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 52),
                    SizedBox(height: 8),
                    Text('Your cart is empty'),
                  ],
                ),
              )
            else
              ...lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PremiumCard(
                    child: Row(
                      children: [
                        const Icon(Icons.medication, size: 36),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                line.medicine.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text('Rs. ${line.medicine.price}'),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Decrease',
                          onPressed: () => ref
                              .read(cartControllerProvider.notifier)
                              .decrement(line.medicine.id),
                          icon: const Icon(Icons.remove),
                        ),
                        Text('${line.quantity}'),
                        IconButton(
                          tooltip: 'Increase',
                          onPressed: () => ref
                              .read(cartControllerProvider.notifier)
                              .add(line.medicine),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order summary',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  _AmountRow(label: 'Subtotal', value: subtotal),
                  _AmountRow(label: 'Delivery', value: delivery.toDouble()),
                  _AmountRow(label: 'Taxes', value: tax),
                  const Divider(),
                  _AmountRow(label: 'Payable', value: total, strong: true),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: 'home',
                    decoration: const InputDecoration(
                      labelText: 'Delivery address',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'home',
                        child: Text('Home - Indiranagar, Bengaluru'),
                      ),
                      DropdownMenuItem(
                        value: 'office',
                        child: Text('Office - Manyata Tech Park'),
                      ),
                    ],
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed:
                        lines.isEmpty ? null : () => context.go('/checkout'),
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Proceed to checkout'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: lines.isEmpty ? null : () {},
                    icon: const Icon(Icons.payments),
                    label: const Text('Cash on delivery'),
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

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final double value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontWeight: strong ? FontWeight.w900 : null),
            ),
          ),
          Text(
            'Rs. ${value.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: strong ? FontWeight.w900 : null),
          ),
        ],
      ),
    );
  }
}
