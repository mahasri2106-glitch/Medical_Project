import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../cart/presentation/cart_controller.dart';

class Order {
  const Order({
    required this.id,
    required this.total,
    required this.address,
    required this.status,
    required this.items,
    this.userName,
  });

  final String id;
  final double total;
  final String address;
  final String status;
  final List<Map<String, dynamic>> items;
  final String? userName;

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return Order(
      id: (json['id'] ?? '').toString(),
      total: (json['total'] as num? ?? 0).toDouble(),
      address: (json['address'] ?? '').toString(),
      status: (json['status'] ?? 'placed').toString(),
      items: rawItems is List
          ? rawItems
              .map((item) => (item as Map).cast<String, dynamic>())
              .toList()
          : const [],
      userName: (json['user_name'] ?? json['userName'])?.toString(),
    );
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(apiClientProvider));
});

final adminOrdersProvider = FutureProvider<List<Order>>((ref) async {
  return ref.watch(orderRepositoryProvider).adminOrders();
});

class OrderRepository {
  OrderRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<void> createOrder(
    double total,
    String address,
    List<CartLine> lines,
  ) async {
    await _apiClient.postJson(
      '/orders',
      data: {
        'total': total,
        'address': address,
        'items': lines
            .map(
              (line) => {
                'id': line.medicine.id,
                'name': line.medicine.name,
                'quantity': line.quantity,
                'price': line.medicine.price,
              },
            )
            .toList(),
      },
    );
  }

  Future<List<Order>> adminOrders() async {
    final json = await _apiClient.getJson('/admin/orders');
    final data = json['data'];
    if (data is! List) return const [];
    return data
        .map((item) => Order.fromJson((item as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _apiClient
        .patchJson('/admin/orders/$orderId/status', data: {'status': status});
  }
}
