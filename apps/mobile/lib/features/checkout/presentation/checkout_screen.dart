import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/mediscan_scaffold.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/responsive_center.dart';
import '../../cart/presentation/cart_controller.dart';

import '../../profile/data/profile_repository.dart';
import '../../orders/data/order_repository.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  late final _phone = TextEditingController(text: ref.read(defaultPhoneProvider));
  late final _address = TextEditingController(text: ref.read(defaultAddressProvider));
  bool _loading = false;

  void _promptQuestionnaire() {
    // Save to providers before proceeding
    ref.read(defaultPhoneProvider.notifier).state = _phone.text;
    ref.read(defaultAddressProvider.notifier).state = _address.text;
    
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
      final total = ref.read(cartTotalProvider);
      final address = _address.text;
      
      await ref.read(orderRepositoryProvider).createOrder(total, address, items);
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Order Placed'),
            content: const Text('Your order has been placed successfully and is pending admin approval.'),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error placing order: $e')),
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
        child: ListenableBuilder(
          listenable: Listenable.merge([_phone, _address]),
          builder: (context, _) {
            final isFormValid = _phone.text.trim().isNotEmpty && _address.text.trim().isNotEmpty;
            
            return ListView(
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
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _address,
                        minLines: 3,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Full delivery address with pincode',
                          prefixIcon: Icon(Icons.location_on_outlined),
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
                          onPressed: _loading || items.isEmpty || !isFormValid ? null : _promptQuestionnaire,
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
            );
          },
        ),
      ),
    );
  }
}
