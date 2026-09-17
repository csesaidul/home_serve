import '../../../core/network/api_client.dart';

/// Result of a successful login — matches the backend's response shape:
/// `{ access_token, token_type, claims: { user_id, client_verified,
/// provider_verified, is_admin } }`.
class LoginResult {
  LoginResult({required this.accessToken, required this.claims});

  final String accessToken;
  final Map<String, dynamic> claims;

  factory LoginResult.fromJson(Map<String, dynamic> json) => LoginResult(
        accessToken: json["access_token"] as String,
        claims: Map<String, dynamic>.from(json["claims"] as Map),
      );
}

/// Talks to the `/auth/*` endpoints exposed by `app/routes/auth.py`.
class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  /// POST /auth/register
  /// Returns the mock OTP the backend generated (backend logs it too —
  /// there's no SMS gateway yet in the MVP, see `services/auth.py`).
  Future<String> register({
    required String phone,
    required String name,
    required String? gender,
    required String password,
  }) async {
    final json = await _client.post("/auth/register", {
      "phone": phone,
      "name": name,
      "gender": gender,
      "password": password,
    });
    return json["mock_otp"] as String;
  }

  /// POST /auth/verify-otp
  Future<void> verifyOtp({required String phone, required String otpCode}) async {
    await _client.post("/auth/verify-otp", {
      "phone": phone,
      "otp_code": otpCode,
    });
  }

  /// POST /auth/login
  Future<LoginResult> login({
    required String phone,
    required String password,
  }) async {
    final json = await _client.post("/auth/login", {
      "phone": phone,
      "password": password,
    });
    return LoginResult.fromJson(json);
  }
}
