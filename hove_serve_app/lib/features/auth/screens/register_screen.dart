import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

enum _Gender { male, female, other }

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  _Gender _gender = _Gender.male;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final localPhone = _phoneController.text.trim();
    final ok = await ref.read(authProvider.notifier).register(
          name: _nameController.text.trim(),
          phone: PhoneField.fullPhone(localPhone),
          gender: _gender.name,
          password: _passwordController.text,
        );

    if (ok && mounted) {
      // No real SMS gateway in the MVP yet — surface the backend's mock
      // OTP so QA/dev can actually complete the flow. Remove once Rabbi
      // wires up a real SMS provider.
      final mockOtp = ref.read(authProvider).mockOtp;
      if (mockOtp != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("DEV: Mock OTP = $mockOtp")),
        );
      }
      context.push('/otp-verify', extra: localPhone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BrandHeader(),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Create Account",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Every account starts as a Client",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      if (authState.errorMessage != null)
                        ErrorBanner(
                          message: authState.errorMessage!,
                          onDismiss: () => ref.read(authProvider.notifier).clearError(),
                        ),
                      _LabeledField(
                        label: "FULL NAME",
                        child: TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.badge_outlined, size: 20),
                            hintText: "e.g. John Doe",
                          ),
                          validator: (v) =>
                              (v ?? "").trim().isEmpty ? "নাম দিতে হবে" : null,
                        ),
                      ),
                      PhoneField(controller: _phoneController),
                      _LabeledField(
                        label: "GENDER IDENTITY",
                        child: Row(
                          children: _Gender.values.map((g) {
                            final selected = _gender == g;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: g != _Gender.values.last ? 8 : 0,
                                ),
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: selected
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                    foregroundColor: selected
                                        ? Theme.of(context).colorScheme.onPrimary
                                        : Theme.of(context).colorScheme.onSurface,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: () => setState(() => _gender = g),
                                  child: Text(_genderLabel(g)),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      PasswordField(
                        controller: _passwordController,
                        hint: "MIN 8 CHARS",
                      ),
                      PasswordField(
                        controller: _confirmController,
                        label: "CONFIRM PASSWORD",
                        validator: (v) {
                          if ((v ?? "").isEmpty) return "পাসওয়ার্ড আবার দিতে হবে";
                          if (v != _passwordController.text) return "পাসওয়ার্ড মিলছে না";
                          return null;
                        },
                      ),
                      PrimaryButton(
                        label: "Register & Verify Phone",
                        loading: authState.isSubmitting,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        "Log in",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _genderLabel(_Gender g) => switch (g) {
        _Gender.male => "Male",
        _Gender.female => "Female",
        _Gender.other => "Other",
      };
}

/// Local copy of the label+field layout used in [auth_widgets.dart] (kept
/// private here since Full Name doesn't fit PhoneField/PasswordField).
class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 6),
        child,
        const SizedBox(height: 16),
      ],
    );
  }
}
