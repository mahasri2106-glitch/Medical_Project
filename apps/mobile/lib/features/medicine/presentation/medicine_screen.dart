import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/mediscan_scaffold.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/responsive_center.dart';
import '../../../core/widgets/section_header.dart';
import '../../cart/presentation/cart_controller.dart';
import '../data/demo_catalog.dart';
import '../data/medicine_repository.dart';
import '../data/medicine_image_service.dart';
import '../../auth/data/auth_repository.dart';

class MedicineScreen extends ConsumerWidget {
  const MedicineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicinesState = ref.watch(medicinesProvider);
    final medicines = medicinesState.value ?? demoMedicines;
    final medicalImages = ref.watch(medicalImagesProvider).value ?? [];
    final selectedCategory = ref.watch(medicineCategoryProvider);
    final width = MediaQuery.sizeOf(context).width;
    final columns = width > 980 ? 4 : (width > 640 ? 3 : 2);

    return MediScanScaffold(
      selectedIndex: 1,
      child: ResponsiveCenter(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedCategory == null
                                  ? 'Medicines'
                                  : 'Medicines - $selectedCategory',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text('${medicines.length} products'),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Profile',
                        onPressed: () => context.go('/profile'),
                        icon: const Icon(Icons.person_outline),
                      ),
                      if (ref.watch(authControllerProvider).value?.role == UserRole.admin)
                        IconButton(
                          tooltip: 'Admin Dashboard',
                          onPressed: () => context.go('/admin'),
                          icon: const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFF009B8E)),
                        ),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/prescription'),
                        icon: const Icon(Icons.description_outlined),
                        label: const Text('Upload'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    onChanged: (value) => ref
                        .read(medicineSearchQueryProvider.notifier)
                        .state = value,
                    decoration: const InputDecoration(
                      hintText: 'Search medicines, brands, composition',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: Icon(Icons.mic_none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('All'),
                            selected: selectedCategory == null,
                            onSelected: (_) => ref
                                .read(medicineCategoryProvider.notifier)
                                .state = null,
                          ),
                        ),
                        ...medicineCategories.map(
                          (category) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: selectedCategory == category,
                              onSelected: (selected) => ref
                                  .read(
                                    medicineCategoryProvider.notifier,
                                  )
                                  .state = selected ? category : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SectionHeader(title: 'Recommended for you'),
                  if (medicinesState.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(),
                    ),
                  if (!medicinesState.isLoading && medicines.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No medicines found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text('Try a different category or search term'),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: medicines.length,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 330,
                      ),
                      itemBuilder: (context, index) {
                        final medicine = medicines[index];
                        return PremiumCard(
                          padding: const EdgeInsets.all(12),
                          onTap: () => context.go('/medicines/${medicine.id}'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.network(
                                    medicalImages.isNotEmpty 
                                      ? medicalImages[index % medicalImages.length] 
                                      : medicine.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.medication_liquid, size: 44),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            Text(
                              medicine.brand,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              medicine.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              medicine.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            if (medicine.prescriptionRequired) ...[
                              const SizedBox(height: 4),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  child: Text(
                                    'Rx required',
                                    style: TextStyle(
                                      color: Color(0xFF92400E),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        'Rs. ${medicine.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Rs. ${medicine.mrp.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: medicine.inStock
                                    ? () => ref
                                        .read(
                                          cartControllerProvider.notifier,
                                        )
                                        .add(medicine)
                                    : null,
                                child: const Text('Add'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
