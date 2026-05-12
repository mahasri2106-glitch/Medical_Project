import 'package:flutter_riverpod/flutter_riverpod.dart';

final defaultPhoneProvider = StateProvider<String>((ref) => '9876543210');
final defaultAddressProvider = StateProvider<String>(
  (ref) => 'Home - Indiranagar, Bengaluru 560038',
);
