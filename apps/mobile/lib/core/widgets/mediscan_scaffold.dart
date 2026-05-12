import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/presentation/cart_controller.dart';
import '../../features/auth/data/auth_repository.dart';

class MediScanScaffold extends ConsumerWidget {
  const MediScanScaffold({
    required this.child,
    required this.selectedIndex,
    this.title,
    this.actions,
    super.key,
  });

  final Widget child;
  final int selectedIndex;
  final String? title;
  final List<Widget>? actions;

  static const _routes = [
    '/',
    '/medicines',
    '/prescription',
    '/orders',
    '/profile',
  ];

  static const _navItems = [
    ('/medicines', 'Buy Medicines', null),
    ('/doctors', 'Find Doctors', null),
    ('/labs', 'Lab Tests', null),
    ('/circle', 'Circle Membership', null),
    ('/records', 'Health Records', null),
    ('/insurance', 'Buy Insurance', 'New'),
    ('/prescription', 'Prescription Reader', 'AI'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref
        .watch(cartControllerProvider)
        .fold<int>(0, (total, line) => total + line.quantity);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Material(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: .97),
          elevation: 0,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  child: Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => context.go('/'),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.medication,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'MedBill',
                                  style: TextStyle(
                                    color: Color(0xFF009B8E),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'Online Doctor & Medicines',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Deliver to Select Address',
                        onPressed: () => context.go('/profile'),
                        icon: const Icon(Icons.location_on_outlined),
                      ),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            tooltip: 'Cart',
                            onPressed: () => context.go('/cart'),
                            icon: const Icon(Icons.shopping_cart_outlined),
                          ),
                          if (cartCount > 0)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                width: 18,
                                height: 18,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$cartCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      IconButton(
                        tooltip: 'Profile',
                        onPressed: () => context.go('/profile'),
                        icon: const Icon(Icons.person_outline),
                      ),
                      if (ref.watch(authControllerProvider).value?.role ==
                          UserRole.admin)
                        IconButton(
                          tooltip: 'Admin Dashboard',
                          onPressed: () => context.go('/admin'),
                          icon: const Icon(Icons.admin_panel_settings_outlined,
                              color: Color(0xFF009B8E)),
                        ),
                      ...?actions,
                    ],
                  ),
                ),
                const Divider(height: 1),
                SizedBox(
                  height: 43,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: _navItems.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 4),
                    itemBuilder: (context, index) {
                      final item = _navItems[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => context.go(item.$1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Text(
                                item.$2,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (item.$3 != null) ...[
                                const SizedBox(width: 4),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      item.$3!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => context.go(_routes[index]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
