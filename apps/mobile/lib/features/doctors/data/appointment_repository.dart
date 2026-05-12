import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class Appointment {
  const Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.fee,
    required this.status,
    this.userName,
  });

  final String id;
  final String doctorName;
  final String specialty;
  final double fee;
  final String status;
  final String? userName;

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: (json['id'] ?? '').toString(),
      doctorName: (json['doctor_name'] ?? json['doctorName'] ?? '').toString(),
      specialty: (json['specialty'] ?? '').toString(),
      fee: (json['fee'] as num? ?? 0).toDouble(),
      status: (json['status'] ?? 'pending').toString(),
      userName: (json['user_name'] ?? json['userName'])?.toString(),
    );
  }
}

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepository(ref.watch(apiClientProvider));
});

final adminAppointmentsProvider =
    FutureProvider<List<Appointment>>((ref) async {
  return ref.watch(appointmentRepositoryProvider).adminAppointments();
});

class AppointmentRepository {
  AppointmentRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<void> createAppointment(
    String doctorName,
    String specialty,
    double fee,
  ) async {
    await _apiClient.postJson(
      '/appointments',
      data: {
        'doctor_name': doctorName,
        'specialty': specialty,
        'fee': fee,
      },
    );
  }

  Future<List<Appointment>> adminAppointments() async {
    final json = await _apiClient.getJson('/admin/appointments');
    final data = json['data'];
    if (data is! List) return const [];
    return data
        .map((item) =>
            Appointment.fromJson((item as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
    await _apiClient.patchJson(
      '/admin/appointments/$appointmentId/status',
      data: {'status': status},
    );
  }
}
