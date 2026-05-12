import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/premium_card.dart';
import '../../auth/data/auth_repository.dart';
import '../../doctors/data/appointment_repository.dart';
import '../../orders/data/order_repository.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider);
    final appointmentsAsync = ref.watch(adminAppointmentsProvider);

    // Calculate stats
    final pendingOrders =
        ordersAsync.value?.where((o) => o.status == 'placed').length ?? 0;
    final pendingAppts =
        appointmentsAsync.value?.where((a) => a.status == 'pending').length ??
            0;
    final totalRevenue = ordersAsync.value?.fold<double>(
            0, (sum, o) => sum + (o.status == 'approved' ? o.total : 0)) ??
        0;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go('/auth');
              },
              tooltip: 'Logout',
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Performance Overview',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  title: 'Pending Orders',
                  value: pendingOrders.toString(),
                  icon: Icons.shopping_bag,
                  color: Colors.orange,
                ),
                _StatCard(
                  title: 'Appointments',
                  value: pendingAppts.toString(),
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                ),
                _StatCard(
                  title: 'Total Revenue',
                  value: '₹${totalRevenue.toStringAsFixed(0)}',
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                ),
                const _StatCard(
                  title: 'Active Users',
                  value: '124',
                  icon: Icons.people,
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 32),
            const TabBar(
              labelColor: Color(0xFF009B8E),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF009B8E),
              tabs: [
                Tab(text: 'Orders Management'),
                Tab(text: 'Appointments Management'),
              ],
            ),
            SizedBox(
              height: 500, // Fixed height for TabBarView in ListView
              child: TabBarView(
                children: [
                  _OrdersList(),
                  _AppointmentsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return ordersAsync.when(
      data: (orders) => orders.isEmpty
          ? const Center(child: Text('No orders found'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return PremiumCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order #${order.id.split('_').last}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          _StatusChip(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Customer: ${order.userName ?? 'Unknown User'}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Total: ₹${order.total.toStringAsFixed(2)}'),
                      Text('Address: ${order.address}'),
                      const Divider(),
                      ...order.items.map((item) =>
                          Text('• ${item['name']} x ${item['quantity']}')),
                      if (order.status == 'placed') ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red),
                                onPressed: () => ref
                                    .read(orderRepositoryProvider)
                                    .updateOrderStatus(order.id, 'rejected')
                                    .then((_) =>
                                        ref.invalidate(adminOrdersProvider)),
                                child: const Text('Reject'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                    backgroundColor: Colors.green),
                                onPressed: () => ref
                                    .read(orderRepositoryProvider)
                                    .updateOrderStatus(order.id, 'approved')
                                    .then((_) =>
                                        ref.invalidate(adminOrdersProvider)),
                                child: const Text('Approve'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading orders: $e')),
    );
  }
}

class _AppointmentsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(adminAppointmentsProvider);

    return appointmentsAsync.when(
      data: (appointments) => appointments.isEmpty
          ? const Center(child: Text('No appointments found'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appt = appointments[index];
                return PremiumCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Doctor: ${appt.doctorName}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          _StatusChip(status: appt.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Customer: ${appt.userName ?? 'Unknown User'}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Specialty: ${appt.specialty}'),
                      Text('Fee: ₹${appt.fee}'),
                      const Divider(),
                      if (appt.status == 'pending') ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red),
                                onPressed: () => ref
                                    .read(appointmentRepositoryProvider)
                                    .updateAppointmentStatus(
                                        appt.id, 'cancelled')
                                    .then((_) => ref
                                        .invalidate(adminAppointmentsProvider)),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                    backgroundColor: Colors.blue),
                                onPressed: () => ref
                                    .read(appointmentRepositoryProvider)
                                    .updateAppointmentStatus(
                                        appt.id, 'confirmed')
                                    .then((_) => ref
                                        .invalidate(adminAppointmentsProvider)),
                                child: const Text('Confirm'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading appointments: $e')),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'approved':
      case 'confirmed':
        color = Colors.green;
        break;
      case 'rejected':
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
