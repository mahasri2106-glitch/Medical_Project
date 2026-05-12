import 'package:flutter_riverpod/flutter_riverpod.dart';

final medicalImagesProvider = FutureProvider<List<String>>((ref) async {
  return const [
    'https://picsum.photos/seed/medbill-tablets/480/480',
    'https://picsum.photos/seed/medbill-capsules/480/480',
    'https://picsum.photos/seed/medbill-syrup/480/480',
    'https://picsum.photos/seed/medbill-pharmacy/480/480',
    'https://picsum.photos/seed/medbill-vitamins/480/480',
  ];
});
