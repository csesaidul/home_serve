import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../data/auth_repository.dart';
import 'auth_state.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final secureStorageProvider =
    Provider<SecureStorageService>((ref) => SecureStorageService());

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(secureStorageProvider),
  ),
);

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository, this._storage) : super(const AuthState());

  final AuthRepository _repository;
  final SecureStorageService _storage;

  void clearError() => state = state.copyWith(clearError: true);

  /// D2-T4 step 1: Register screen -> POST /auth/register
  Future<bool> register({
    required String name,
    required String phone,
    required String? gender,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.submitting, clearError: true);
    try {
      final mockOtp = await _repository.register(
        phone: phone,
        name: name,
        gender: gender,
        password: password,
      );
      state = state.copyWith(
        status: AuthStatus.registerSuccessAwaitingOtp,
        pendingPhone: phone,
        mockOtp: mockOtp,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      return false;
    }
  }

  /// D2-T4 step 2: OTP Verify screen -> POST /auth/verify-otp
  Future<bool> verifyOtp(String otpCode) async {
    final phone = state.pendingPhone;
    if (phone == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: "ফোন নম্বর পাওয়া যায়নি, রেজিস্ট্রেশন থেকে আবার শুরু করো।",
      );
      return false;
    }
    state = state.copyWith(status: AuthStatus.submitting, clearError: true);
    try {
      await _repository.verifyOtp(phone: phone, otpCode: otpCode);
      state = state.copyWith(status: AuthStatus.otpVerified);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      return false;
    }
  }

  /// D2-T4 step 3: Login screen -> POST /auth/login, persist JWT.
  Future<bool> login({required String phone, required String password}) async {
    state = state.copyWith(status: AuthStatus.submitting, clearError: true);
    try {
      final result = await _repository.login(phone: phone, password: password);
      await _storage.saveSession(token: result.accessToken, claims: result.claims);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        claims: result.claims,
        pendingPhone: phone,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearSession();
    state = const AuthState();
  }
}
