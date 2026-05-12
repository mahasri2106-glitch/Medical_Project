import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'prescription_models.dart';

final prescriptionRepositoryProvider = Provider<PrescriptionRepository>((ref) {
  return PrescriptionRepository(ref.watch(apiClientProvider));
});

class PrescriptionRepository {
  PrescriptionRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<PrescriptionAnalysis> analyzeBytes(
      List<int> bytes, String fileName) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    final json =
        await _apiClient.postFormData('/prescriptions/analyze', formData);
    return PrescriptionAnalysis.fromJson(json);
  }

  PrescriptionAnalysis demoAnalysis() {
    return const PrescriptionAnalysis(
      summary:
          'AI found two common medicines and prepared a refill-friendly schedule.',
      medicines: [
        PrescriptionMedicine(
          name: 'Paracetamol 500mg',
          dosage: '500mg',
          frequency: 'Twice daily',
          timings: 'After food',
          duration: '3 days',
          genericAlternative: 'Acetaminophen',
        ),
        PrescriptionMedicine(
          name: 'Azithromycin 500mg',
          dosage: '500mg',
          frequency: 'Once daily',
          timings: 'After dinner',
          duration: '5 days',
          warning: 'Prescription required. Confirm with a doctor before use.',
        ),
      ],
      interactions: [
        'Confirm prescription medicines with a licensed pharmacist.'
      ],
      reminders: ['Morning after breakfast', 'Night after dinner'],
    );
  }
}
