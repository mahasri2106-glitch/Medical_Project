import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/circle/presentation/circle_screen.dart';
import '../../features/doctors/presentation/doctors_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/insurance/presentation/insurance_screen.dart';
import '../../features/labs/presentation/lab_tests_screen.dart';
import '../../features/medicine/presentation/medicine_detail_screen.dart';
import '../../features/medicine/presentation/medicine_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/prescription/presentation/prescription_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/records/presentation/records_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(
        path: '/medicines',
        builder: (context, state) => const MedicineScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                MedicineDetailScreen(medicineId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/prescription',
        builder: (context, state) => const PrescriptionScreen(),
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/circle',
        builder: (context, state) => const CircleScreen(),
      ),
      GoRoute(
        path: '/doctors',
        builder: (context, state) => const DoctorsScreen(),
      ),
      GoRoute(
        path: '/labs',
        builder: (context, state) => const LabTestsScreen(),
      ),
      GoRoute(
        path: '/insurance',
        builder: (context, state) => const InsuranceScreen(),
      ),
      GoRoute(
        path: '/records',
        builder: (context, state) => const RecordsScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
