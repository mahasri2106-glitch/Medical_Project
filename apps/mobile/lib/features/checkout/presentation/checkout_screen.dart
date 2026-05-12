import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/mediscan_scaffold.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/responsive_center.dart';
import '../../cart/presentation/cart_controller.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _phone = TextEditingController();
  final _address = TextEditingController();
  bool _loading = false;

  void _promptQuestionnaire() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Health Questionnaire Required'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Please confirm the following before placing your order:'),
              SizedBox(height: 12),
              Text('1. Do you have any known severe allergies?'),
              TextField(decoration: InputDecoration(hintText: 'If yes, list them')),
              SizedBox(height: 12),
              Text('2. Are you currently on any other medication?'),
              TextField(decoration: InputDecoration(hintText: 'If yes, list them')),
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
                _placeOrder();
              },
              child: const Text('Confirm & Place Order'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final items = ref.read(cartControllerProvider);
    if (items.isEmpty) return;
    setState(() => _loading = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Order Placed'),
            content: const Text('Your order has been placed successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(cartControllerProvider.notifier).clear();
                  context.go('/');
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartControllerProvider);
    final total = ref.watch(cartTotalProvider);

    return MediScanScaffold(
      selectedIndex: 1,
      child: ResponsiveCenter(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Checkout',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            PremiumCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delivery address',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Phone number',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _address,
                    minLines: 3,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Full delivery address with pincode',
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Divider(),
                  Row(
                    children: [
                      Text('Items (${items.length})'),
                      const Spacer(),
                      Text('Rs. ${total.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const Spacer(),
                      Text(
                        'Rs. ${total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading || items.isEmpty ? null : _promptQuestionnaire,
                      child: Text(
                        _loading
                            ? 'Placing...'
                            : 'Place order (Cash on delivery)',
                      ),
                    ),
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
