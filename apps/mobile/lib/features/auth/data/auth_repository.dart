import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';

enum UserRole { customer, admin }

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final role = (json['role'] ?? 'customer').toString().toLowerCase();
    return AppUser(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? 'MedBill user').toString(),
      email: (json['email'] ?? '').toString(),
      role: role == 'admin' ? UserRole.admin : UserRole.customer,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
      ref.watch(apiClientProvider), ref.watch(secureStorageProvider));
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AppUser?>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthRepository {
  AuthRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final SecureStorageService _storage;

  Future<AppUser> login(String email, String password) async {
    final json = await _apiClient.postJson(
      '/auth/login',
      data: {'email': email.trim(), 'password': password},
    );
    return _saveSession(json);
  }

  Future<AppUser> register(String name, String email, String password) async {
    final json = await _apiClient.postJson(
      '/auth/register',
      data: {'name': name.trim(), 'email': email.trim(), 'password': password},
    );
    return _saveSession(json);
  }

  Future<void> logout() => _storage.clear();

  Future<AppUser?> currentUser() async {
    final token = await _storage.readAccessToken();
    if (token == null) return null;
    try {
      final json = await _apiClient.getJson('/auth/me');
      return AppUser.fromJson((json['user'] as Map).cast<String, dynamic>());
    } catch (_) {
      await _storage.clear();
      return null;
    }
  }

  Future<AppUser> _saveSession(Map<String, dynamic> json) async {
    final token = json['accessToken']?.toString();
    if (token != null) {
      await _storage.saveSession(accessToken: token);
    }
    return AppUser.fromJson((json['user'] as Map).cast<String, dynamic>());
  }
}

class AuthController extends StateNotifier<AsyncValue<AppUser?>> {
  AuthController(this._repository) : super(const AsyncValue.data(null)) {
    _load();
  }

  final AuthRepository _repository;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.currentUser);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.login(email, password));
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _repository.register(name, email, password));
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}
