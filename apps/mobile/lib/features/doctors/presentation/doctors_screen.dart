import 'package:flutter/material.dart';

import '../../../core/widgets/mediscan_scaffold.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/responsive_center.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  String _filter = '';
  String _symptom = '';

  static const specialties = [
    'Cardiologist',
    'ENT',
    'Pediatrician',
    'Dermatologist',
    'Neurologist',
    'Orthopedic',
    'Dentist',
    'Gynecologist',
    'General Physician',
    'Psychiatrist',
  ];

  static const doctors = [
    ('Dr. Aditi Sharma', 'Cardiologist', 12, 4.8, 600, 'Bangalore'),
    ('Dr. Rohan Patel', 'ENT', 8, 4.6, 400, 'Mumbai'),
    ('Dr. Nisha Reddy', 'Pediatrician', 15, 4.9, 500, 'Hyderabad'),
    ('Dr. Vikram Singh', 'Dermatologist', 10, 4.7, 550, 'Delhi'),
    ('Dr. Meera Iyer', 'Neurologist', 18, 4.9, 800, 'Chennai'),
    ('Dr. Arjun Mehta', 'Orthopedic', 14, 4.7, 650, 'Pune'),
    ('Dr. Kavya Nair', 'Dentist', 9, 4.8, 350, 'Kochi'),
    ('Dr. Sanjay Rao', 'General Physician', 20, 4.8, 300, 'Bangalore'),
  ];

  String? get _suggestion {
    final text = _symptom.toLowerCase();
    if (text.contains('fever')) return 'General Physician';
    if (text.contains('headache')) return 'Neurologist';
    if (text.contains('rash')) return 'Dermatologist';
    if (text.contains('chest pain')) return 'Cardiologist';
    if (text.contains('tooth')) return 'Dentist';
    if (text.contains('child')) return 'Pediatrician';
    if (text.contains('ear')) return 'ENT';
    if (text.contains('joint')) return 'Orthopedic';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final list =
        doctors.where((doctor) => _filter.isEmpty || doctor.$2 == _filter);

    return MediScanScaffold(
      selectedIndex: 0,
      child: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Find Doctors',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text('Consult top specialists online or visit nearby'),
            const SizedBox(height: 18),
            PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tell us your symptom (we'll suggest a doctor)",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'e.g. fever, headache, chest pain, tooth ache',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() => _symptom = value),
                  ),
                  if (_suggestion != null) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => setState(() => _filter = _suggestion!),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F7F3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Suggested specialty: $_suggestion',
                          style: const TextStyle(
                            color: Color(0xFF009B8E),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _filter.isEmpty,
                    onTap: () => setState(() => _filter = ''),
                  ),
                  ...specialties.map(
                    (specialty) => _FilterChip(
                      label: specialty,
                      selected: _filter == specialty,
                      onTap: () => setState(() => _filter = specialty),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...list.map(
              (doctor) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PremiumCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFE0F7F3),
                            ),
                            child: const Icon(
                              Icons.medical_services_outlined,
                              color: Color(0xFF009B8E),
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor.$1,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text('${doctor.$2} - ${doctor.$3} yrs exp'),
                                Row(
                                  children: [
                                    const Text(
                                      '* ',
                                      style: TextStyle(
                                        color: Color(0xFFF59E0B),
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text('${doctor.$4}'),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.location_on, size: 14),
                                    Text(doctor.$6),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Rs. ${doctor.$5}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Consultation Questionnaire'),
                                  content: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Please describe your symptoms briefly:'),
                                      TextField(),
                                      SizedBox(height: 12),
                                      Text('Any ongoing medical conditions?'),
                                      TextField(),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        Navigator.pop(context); // close questionnaire
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Consultation Booked'),
                                            content: Text('Your consultation with ${doctor.$1} has been booked successfully.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: const Text('Confirm'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.video_call, size: 18),
                            label: const Text('Consult'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
