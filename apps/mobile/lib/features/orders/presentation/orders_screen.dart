import 'package:flutter/material.dart';

import '../../../core/widgets/mediscan_scaffold.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/responsive_center.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  void _showTrackingTimeline(BuildContext context, String orderId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Track Order $orderId',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _TimelineItem(
                      title: 'Order Placed',
                      subtitle: 'May 08, 2024 - 10:30 AM',
                      isCompleted: true,
                    ),
                    _TimelineItem(
                      title: 'Prescription Verified',
                      subtitle: 'May 08, 2024 - 02:15 PM',
                      isCompleted: true,
                    ),
                    _TimelineItem(
                      title: 'Packed & Ready',
                      subtitle: 'May 09, 2024 - 09:00 AM',
                      isCompleted: true,
                    ),
                    _TimelineItem(
                      title: 'Out for Delivery',
                      subtitle: 'May 10, 2024 - 08:30 AM',
                      isCompleted: orderId == 'MS-1048',
                      isCurrent: orderId == 'MS-1048',
                    ),
                    _TimelineItem(
                      title: 'Delivered',
                      subtitle: 'Awaiting arrival',
                      isCompleted: orderId == 'MS-1031',
                      isCurrent: orderId == 'MS-1031',
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const orders = [
      ('MS-1048', 'Out for delivery', .72, 'ETA 18 minutes'),
      ('MS-1031', 'Delivered', 1.0, 'Delivered on 08 May'),
      ('MS-1019', 'Pharmacist review', .34, 'Prescription verification'),
    ];

    return MediScanScaffold(
      selectedIndex: 3,
      child: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'My Orders',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            ...orders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondaryContainer,
                            child: const Icon(Icons.local_shipping),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.$1,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(order.$2),
                              ],
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: () => _showTrackingTimeline(context, order.$1),
                            child: const Text('Track'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      LinearProgressIndicator(value: order.$3),
                      const SizedBox(height: 8),
                      Text(order.$4),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.replay_outlined),
                        label: const Text('Reorder'),
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

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.isCurrent = false,
    this.isLast = false,
  });

  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = isCompleted
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outlineVariant;

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isCurrent ? Colors.white : color,
                  shape: BoxShape.circle,
                  border: isCurrent ? Border.all(color: color, width: 5) : null,
                ),
                child: isCompleted && !isCurrent
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: color,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.w900 : FontWeight.bold,
                    color: isCurrent ? Theme.of(context).colorScheme.primary : null,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
