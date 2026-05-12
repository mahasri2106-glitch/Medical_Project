class PrescriptionMedicine {
  const PrescriptionMedicine({
    required this.name,
    this.dosage,
    this.frequency,
    this.timings,
    this.duration,
    this.genericAlternative,
    this.warning,
  });

  final String name;
  final String? dosage;
  final String? frequency;
  final String? timings;
  final String? duration;
  final String? genericAlternative;
  final String? warning;

  factory PrescriptionMedicine.fromJson(Map<String, dynamic> json) {
    return PrescriptionMedicine(
      name: (json['name'] ?? '').toString(),
      dosage: json['dosage']?.toString(),
      frequency: json['frequency']?.toString(),
      timings: json['timings']?.toString(),
      duration: json['duration']?.toString(),
      genericAlternative: json['genericAlternative']?.toString(),
      warning: json['warning']?.toString(),
    );
  }
}

class PrescriptionAnalysis {
  const PrescriptionAnalysis({
    required this.summary,
    required this.medicines,
    required this.interactions,
    required this.reminders,
  });

  final String summary;
  final List<PrescriptionMedicine> medicines;
  final List<String> interactions;
  final List<String> reminders;

  factory PrescriptionAnalysis.fromJson(Map<String, dynamic> json) {
    final medicines = json['medicines'];
    return PrescriptionAnalysis(
      summary:
          (json['summary'] ?? 'Prescription analysis complete.').toString(),
      medicines: medicines is List
          ? medicines
              .map((item) => PrescriptionMedicine.fromJson(
                  (item as Map).cast<String, dynamic>()))
              .toList()
          : const [],
      interactions: _stringList(json['interactions']),
      reminders: _stringList(json['reminders']),
    );
  }

  static List<String> _stringList(Object? value) {
    if (value is List) return value.map((item) => item.toString()).toList();
    return const [];
  }
}
