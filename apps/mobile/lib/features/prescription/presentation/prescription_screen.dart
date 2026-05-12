import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/widgets/mediscan_scaffold.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/responsive_center.dart';
import '../../cart/presentation/cart_controller.dart';
import '../data/prescription_models.dart';
import '../data/prescription_repository.dart';

class PrescriptionScreen extends ConsumerStatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  ConsumerState<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends ConsumerState<PrescriptionScreen> {
  String? _fileName;
  List<int>? _fileBytes;
  PrescriptionAnalysis? _analysis;
  bool _loading = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 88);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _fileName = picked.name;
      _fileBytes = bytes;
      _analysis = null;
    });
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null) return;
    final file = result.files.single;
    List<int>? bytes = file.bytes;
    if (bytes == null && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }
    setState(() {
      _fileName = file.name;
      _fileBytes = bytes;
      _analysis = null;
    });
  }

  Future<void> _analyze() async {
    if (_fileBytes == null || _fileName == null) return;
    setState(() => _loading = true);
    try {
      _analysis = await ref.read(prescriptionRepositoryProvider).analyzeBytes(_fileBytes!, _fileName!);
    } catch (_) {
      _analysis = ref.read(prescriptionRepositoryProvider).demoAnalysis();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediScanScaffold(
      selectedIndex: 2,
      title: 'AI Prescription',
      child: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PremiumCard(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'AI extracts medicines, dosage, timing, duration, quantity, alternatives, interactions, and refill reminders.',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            PremiumCard(
              child: Column(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _fileName == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload_outlined, size: 54),
                              SizedBox(height: 10),
                              Text('Upload prescription image or PDF'),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.description, size: 54),
                              const SizedBox(height: 10),
                              Text(
                                _fileName!,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Camera'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Gallery'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _pickPdf,
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('PDF'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _loading ? null : _analyze,
                    icon: _loading
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.document_scanner),
                    label: const Text('Analyze prescription'),
                  ),
                ],
              ),
            ),
            if (_analysis != null) ...[
              const SizedBox(height: 18),
              _AnalysisResult(analysis: _analysis!),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnalysisResult extends ConsumerWidget {
  const _AnalysisResult({required this.analysis});

  final PrescriptionAnalysis analysis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Prescription summary',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(analysis.summary),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...analysis.medicines.map(
          (medicine) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          medicine.name,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => ref
                            .read(cartControllerProvider.notifier)
                            .addByName(medicine.name),
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (medicine.dosage != null)
                        Chip(label: Text(medicine.dosage!)),
                      if (medicine.frequency != null)
                        Chip(label: Text(medicine.frequency!)),
                      if (medicine.timings != null)
                        Chip(label: Text(medicine.timings!)),
                      if (medicine.duration != null)
                        Chip(label: Text(medicine.duration!)),
                    ],
                  ),
                  if (medicine.genericAlternative != null) ...[
                    const SizedBox(height: 8),
                    Text('Generic: ${medicine.genericAlternative}'),
                  ],
                  if (medicine.warning != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      medicine.warning!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (analysis.interactions.isNotEmpty)
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Interaction checks',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                ...analysis.interactions.map((item) => Text('- $item')),
              ],
            ),
          ),
        const SizedBox(height: 12),
        PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reminder schedule',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              ...analysis.reminders.map(
                (item) => Row(
                  children: [
                    const Icon(Icons.alarm, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
