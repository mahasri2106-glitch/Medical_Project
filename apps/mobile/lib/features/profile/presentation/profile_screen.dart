import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/mediscan_app.dart';
import '../../../core/widgets/mediscan_scaffold.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/responsive_center.dart';
import '../../auth/data/auth_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final themeMode = ref.watch(themeModeProvider);

    return MediScanScaffold(
      selectedIndex: 4,
      child: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'My Profile',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            PremiumCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: const Icon(Icons.person, size: 34),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Guest user',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(user?.email ?? 'Login to sync records'),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go('/auth'),
                    child: Text(user == null ? 'Login' : 'Switch'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            PremiumCard(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Dark mode'),
                    value: themeMode == ThemeMode.dark,
                    onChanged: (value) => ref
                        .read(themeModeProvider.notifier)
                        .state = value ? ThemeMode.dark : ThemeMode.light,
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text('Addresses'),
                    subtitle: const Text('Home, office, and saved locations'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Medicine reminders'),
                    subtitle: const Text('Refill and dosage reminders'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.translate_outlined),
                    title: const Text('Language'),
                    subtitle: const Text('English, Hindi, Tamil ready'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            PremiumCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.admin_panel_settings_outlined),
                    title: const Text('Admin dashboard'),
                    subtitle: const Text('Analytics, inventory, orders'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.verified_user_outlined),
                    title: const Text('Pharmacist panel'),
                    subtitle: const Text('Prescription verification queue'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (user != null)
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(authControllerProvider.notifier).logout();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
          ],
        ),
      ),
    );
  }
}
