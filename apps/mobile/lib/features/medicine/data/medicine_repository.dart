import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'demo_catalog.dart';
import 'medicine.dart';

final medicineSearchQueryProvider = StateProvider<String>((ref) => '');
final medicineCategoryProvider = StateProvider<String?>((ref) => null);

final medicineRepositoryProvider = Provider<MedicineRepository>((ref) {
  return MedicineRepository(ref.watch(apiClientProvider));
});

final medicinesProvider = FutureProvider<List<Medicine>>((ref) async {
  final query = ref.watch(medicineSearchQueryProvider).trim();
  final category = ref.watch(medicineCategoryProvider);
  final repository = ref.watch(medicineRepositoryProvider);
  try {
    return await repository.fetchMedicines(query: query, category: category);
  } catch (_) {
    return repository.localMedicines(query: query, category: category);
  }
});

class MedicineRepository {
  MedicineRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Medicine>> fetchMedicines(
      {String? query, String? category}) async {
    final json = await _apiClient.getJson(
      '/medicines',
      query: {
        if (query != null && query.isNotEmpty) 'q': query,
        if (category != null && category.isNotEmpty) 'category': category,
      },
    );
    final data = json['data'];
    if (data is! List) return const [];
    return data
        .map((item) => Medicine.fromJson((item as Map).cast<String, dynamic>()))
        .toList();
  }

  List<Medicine> localMedicines({String? query, String? category}) {
    final normalizedQuery = query?.toLowerCase() ?? '';
    return demoMedicines.where((medicine) {
      final matchesCategory = category == null || medicine.category == category;
      final haystack =
          '${medicine.name} ${medicine.brand} ${medicine.composition} ${medicine.category}'
              .toLowerCase();
      final matchesQuery =
          normalizedQuery.isEmpty || haystack.contains(normalizedQuery);
      return matchesCategory && matchesQuery;
    }).toList();
  }
}
