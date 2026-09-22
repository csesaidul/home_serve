import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants.dart';

/// Wraps [FlutterSecureStorage] so the rest of the app never talks to the
/// plugin directly. Stores the JWT + its decoded claims
/// (`user_id`, `client_verified`, `provider_verified`, `is_admin`).
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  Future<void> saveSession({
    required String token,
    required Map<String, dynamic> claims,
  }) async {
    await _storage.write(key: AppConstants.secureStorageTokenKey, value: token);
    await _storage.write(
      key: AppConstants.secureStorageClaimsKey,
      value: jsonEncode(claims),
    );
  }

  Future<String?> readToken() =>
      _storage.read(key: AppConstants.secureStorageTokenKey);

  Future<Map<String, dynamic>?> readClaims() async {
    final raw = await _storage.read(key: AppConstants.secureStorageClaimsKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clearSession() async {
    await _storage.delete(key: AppConstants.secureStorageTokenKey);
    await _storage.delete(key: AppConstants.secureStorageClaimsKey);
  }
}
