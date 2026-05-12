import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../medicine/data/demo_catalog.dart';
import '../../medicine/data/medicine.dart';

class CartLine {
  const CartLine({required this.medicine, required this.quantity});

  final Medicine medicine;
  final int quantity;

  double get total => medicine.price * quantity;

  CartLine copyWith({int? quantity}) {
    return CartLine(medicine: medicine, quantity: quantity ?? this.quantity);
  }
}

class CartController extends StateNotifier<List<CartLine>> {
  CartController() : super(const []);

  void add(Medicine medicine) {
    final index = state.indexWhere((line) => line.medicine.id == medicine.id);
    if (index == -1) {
      state = [...state, CartLine(medicine: medicine, quantity: 1)];
      return;
    }
    state = [
      for (final line in state)
        if (line.medicine.id == medicine.id)
          line.copyWith(quantity: line.quantity + 1)
        else
          line,
    ];
  }

  void decrement(String medicineId) {
    state = [
      for (final line in state)
        if (line.medicine.id == medicineId && line.quantity > 1)
          line.copyWith(quantity: line.quantity - 1)
        else if (line.medicine.id != medicineId)
          line,
    ];
  }

  void remove(String medicineId) {
    state = state.where((line) => line.medicine.id != medicineId).toList();
  }

  void saveForLater(String medicineId) => remove(medicineId);

  void addByName(String name) {
    final medicine = demoMedicines.firstWhere(
      (item) => item.name.toLowerCase().contains(name.toLowerCase()),
      orElse: () => demoMedicines.first,
    );
    add(medicine);
  }

  void clear() {
    state = const [];
  }
}

final cartControllerProvider =
    StateNotifierProvider<CartController, List<CartLine>>(
  (ref) => CartController(),
);

final cartTotalProvider = Provider<double>((ref) {
  return ref
      .watch(cartControllerProvider)
      .fold<double>(0, (total, line) => total + line.total);
});
