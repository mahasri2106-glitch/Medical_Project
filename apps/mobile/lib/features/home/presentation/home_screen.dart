import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/mediscan_scaffold.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/responsive_center.dart';
import '../../medicine/data/demo_catalog.dart';
import '../data/home_content.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const specialties = [
    (Icons.favorite_border, 'Cardiologist'),
    (Icons.psychology_outlined, 'Neurologist'),
    (Icons.child_care_outlined, 'Pediatrician'),
    (Icons.visibility_outlined, 'Ophthalmologist'),
    (Icons.accessibility_new, 'Orthopedic'),
    (Icons.sentiment_satisfied_alt, 'Dentist'),
    (Icons.monitor_heart_outlined, 'General Physician'),
    (Icons.auto_awesome, 'Dermatologist'),
  ];

  static const categories = [
    'Personal Care',
    'Skin Care',
    'Oral Care',
    'Adult Diapers',
    'Sanitary Pads',
    'Sexual Wellness',
    'Mens Grooming',
    'Baby Care',
    'Vitamins',
    'Diabetes',
    'Heart Care',
  ];

  @override
  Widget build(BuildContext context) {
    return MediScanScaffold(
      selectedIndex: 0,
      child: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            const _HeroPanel(),
            const SizedBox(height: 18),
            _SearchBox(onTap: () => context.go('/medicines')),
            const SizedBox(height: 28),
            const _SectionTitle('Our services'),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 720 ? 7 : 3;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: healthcareServices.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    childAspectRatio: .86,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) =>
                      _ServiceCard(service: healthcareServices[index]),
                );
              },
            ),
            const SizedBox(height: 30),
            _SectionHeader(
              title: 'Consult by specialty',
              action: 'View all',
              onTap: () => context.go('/doctors'),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 720 ? 8 : 4;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: specialties.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    childAspectRatio: .9,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final item = specialties[index];
                    return PremiumCard(
                      padding: const EdgeInsets.all(10),
                      onTap: () => context.go('/doctors'),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.$1,
                            color: Theme.of(context).colorScheme.primary,
                            size: 30,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.$2,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 30),
            const _SectionTitle('Shop by category'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories
                  .map(
                    (category) => ActionChip(
                      label: Text(category),
                      onPressed: () => context.go('/medicines'),
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 30),
            const _PromoGrid(),
            const SizedBox(height: 30),
            const _SectionTitle('Featured medicines'),
            const SizedBox(height: 12),
            SizedBox(
              height: 218,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: demoMedicines.take(6).length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final medicine = demoMedicines[index];
                  return SizedBox(
                    width: 168,
                    child: PremiumCard(
                      padding: const EdgeInsets.all(12),
                      onTap: () => context.go('/medicines/${medicine.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.medication,
                                color: Theme.of(context).colorScheme.primary,
                                size: 42,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            medicine.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            medicine.brand,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Rs. ${medicine.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
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
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF009B8E), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                  SizedBox(width: 5),
                  Text(
                    'AI-powered prescription reader',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Your health, delivered.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Order medicines, consult doctors, book lab tests, and manage records - all in one MedBill app.',
            style: TextStyle(color: Colors.white, height: 1.35),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF009B8E),
                ),
                onPressed: () => context.go('/medicines'),
                child: const Text('Shop medicines'),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: .45),
                  ),
                ),
                onPressed: () => context.go('/prescription'),
                child: const Text('Upload prescription'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: onTap,
      decoration: const InputDecoration(
        hintText: 'Search Medicines',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final HealthcareService service;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(10),
      onTap: () => context.go(service.route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: service.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(service.icon, color: Colors.white, size: 25),
          ),
          const SizedBox(height: 8),
          Text(
            service.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _PromoGrid extends StatelessWidget {
  const _PromoGrid();

  @override
  Widget build(BuildContext context) {
    final promos = [
      (
        Icons.biotech_outlined,
        'Lab Tests at home',
        'Free sample collection from your address',
        'Book now ->',
        const Color(0xFFEFF6FF),
        const Color(0xFF2563EB),
        '/labs',
      ),
      (
        Icons.favorite_border,
        'MedBill Circle',
        'Save up to 25% on every order',
        'Join now ->',
        const Color(0xFFFCE7F3),
        const Color(0xFFDB2777),
        '/circle',
      ),
      (
        Icons.shield_outlined,
        'Health Insurance',
        'Compare and pick the right plan',
        'Explore ->',
        const Color(0xFFE0F2F1),
        const Color(0xFF0D9488),
        '/insurance',
      ),
    ];

    return Column(
      children: promos
          .map(
            (promo) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PremiumCard(
                color: promo.$5,
                onTap: () => context.go(promo.$7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(promo.$1, color: promo.$6, size: 34),
                    const SizedBox(height: 8),
                    Text(
                      promo.$2,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(promo.$3),
                    const SizedBox(height: 12),
                    Text(
                      promo.$4,
                      style: TextStyle(
                        color: promo.$6,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onTap,
  });

  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SectionTitle(title)),
        TextButton.icon(
          onPressed: onTap,
          label: Text(action),
          icon: const Icon(Icons.chevron_right),
          iconAlignment: IconAlignment.end,
        ),
      ],
    );
  }
}
