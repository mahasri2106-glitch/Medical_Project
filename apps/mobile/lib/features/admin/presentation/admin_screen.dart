import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/responsive_center.dart';
import '../../auth/data/auth_repository.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
              context.go('/auth');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            PremiumCard(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                children: [
                  const Icon(Icons.analytics, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Welcome, Admin',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Here is what is happening today.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: const [
                _StatCard(title: 'Total Orders', value: '142', icon: Icons.shopping_cart),
                _StatCard(title: 'Pending Lab Tests', value: '12', icon: Icons.biotech),
                _StatCard(title: 'Doctor Consults', value: '38', icon: Icons.medical_services),
                _StatCard(title: 'Revenue', value: 'Rs. 45k', icon: Icons.currency_rupee),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...List.generate(3, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text('User ${index + 1} placed an order'),
                subtitle: const Text('Just now'),
                trailing: const Icon(Icons.chevron_right),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.icon});
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          Text(title, style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
