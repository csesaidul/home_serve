import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/otp_boxes.dart';

class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({super.key, required this.localPhone});

  /// Local digits only (no +880), e.g. "1712345678".
  final String localPhone;

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  String _code = "";
  Timer? _timer;
  int _secondsLeft = AppConstants.otpResendCooldown.inSeconds;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  void _startCooldown() {
    _secondsLeft = AppConstants.otpResendCooldown.inSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_code.length != AppConstants.otpLength) return;
    final ok = await ref.read(authProvider.notifier).verifyOtp(_code);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ফোন ভেরিফাই হয়ে গেছে। এখন লগইন করো।")),
      );
      context.go('/login', extra: widget.localPhone);
    }
  }

  void _resend() {
    // NOTE for Rabbi: the backend doesn't have a dedicated resend-OTP
    // endpoint yet — /auth/register only issues a fresh mock OTP for a
    // *new* registration and will 409 on an already-registered phone.
    // Wire this up to a real /auth/resend-otp once it exists; for now this
    // just restarts the local cooldown timer.
    _startCooldown();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Resend চালু নেই — backend-এ এই endpoint এখনো নেই")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final fullPhone = PhoneField.fullPhone(widget.localPhone);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton.filledTonal(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Verify Your Phone",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "We sent a one-time verification code via SMS to your mobile number.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_android_outlined, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "PHONE NUMBER",
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            fullPhone,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text("Change"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (authState.errorMessage != null)
                ErrorBanner(
                  message: authState.errorMessage!,
                  onDismiss: () => ref.read(authProvider.notifier).clearError(),
                ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      "ENTER ${AppConstants.otpLength}-DIGIT CODE",
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    OtpBoxes(
                      length: AppConstants.otpLength,
                      initialValue: authState.mockOtp,
                      onChanged: (code) => setState(() => _code = code),
                      onCompleted: (_) => _verify(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _secondsLeft > 0
                              ? "Resend code in 00:${_secondsLeft.toString().padLeft(2, '0')}"
                              : "You can resend the code now",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: "VERIFY & CONTINUE",
                loading: authState.isSubmitting,
                onPressed: _code.length == AppConstants.otpLength ? _verify : null,
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _secondsLeft == 0 ? _resend : null,
                  child: const Text(
                    "Didn't receive SMS? Resend via Voice Call",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
