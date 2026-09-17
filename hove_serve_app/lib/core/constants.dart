/// App-wide constants.
///
/// NOTE (for Rabbi / whoever runs the backend locally):
/// `10.0.2.2` is the special alias the Android *emulator* uses to reach
/// `localhost` on the host machine. Change this depending on where you're
/// running the app:
///   - Android emulator  -> http://10.0.2.2:8000
///   - iOS simulator     -> http://127.0.0.1:8000
///   - Chrome / web      -> http://127.0.0.1:8000
///   - Physical phone    -> http://<your-pc-lan-ip>:8000
class AppConstants {
  AppConstants._();

  static const String apiBaseUrl = "http://10.0.2.2:8000";

  static const Duration apiTimeout = Duration(seconds: 15);
  static const Duration otpResendCooldown = Duration(seconds: 45);
  static const int otpLength = 6; // backend expects a 6-digit numeric OTP
  static const String bdPhoneCountryCode = "+880";

  static const String secureStorageTokenKey = "auth_access_token";
  static const String secureStorageClaimsKey = "auth_claims";
}
