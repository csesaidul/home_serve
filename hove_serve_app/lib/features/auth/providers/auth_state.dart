enum AuthStatus {
  idle,
  submitting,
  registerSuccessAwaitingOtp,
  otpVerified,
  authenticated,
  error,
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.idle,
    this.pendingPhone,
    this.mockOtp,
    this.errorMessage,
    this.claims,
  });

  final AuthStatus status;

  /// Phone number carried between Register -> OTP Verify -> Login.
  final String? pendingPhone;

  /// Only present because there's no SMS gateway in the MVP yet — the
  /// backend returns the OTP directly in the register response so QA can
  /// test the flow. Remove once Rabbi wires up real SMS.
  final String? mockOtp;

  final String? errorMessage;
  final Map<String, dynamic>? claims;

  bool get isSubmitting => status == AuthStatus.submitting;

  AuthState copyWith({
    AuthStatus? status,
    String? pendingPhone,
    String? mockOtp,
    String? errorMessage,
    Map<String, dynamic>? claims,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      pendingPhone: pendingPhone ?? this.pendingPhone,
      mockOtp: mockOtp ?? this.mockOtp,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      claims: claims ?? this.claims,
    );
  }
}
