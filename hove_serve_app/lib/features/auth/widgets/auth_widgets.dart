import 'package:flutter/material.dart';

import '../../../core/constants.dart';

/// The house-with-tools logo + "HomeServe" wordmark shown at the top of the
/// Login/Register screens — uses the actual app icon asset (Sajib's design,
/// assets/images/app_icon.png) instead of a placeholder icon.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Image.asset(
          'assets/images/app_icon.png',
          width: 96,
          height: 96,
        ),
        const SizedBox(height: 12),
        Text(
          "HomeServe",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
        ),
      ],
    );
  }
}

/// Bangladesh phone number field with a fixed "+880" prefix.
/// Exposes the full E.164-ish string (e.g. "+8801712345678") via
/// [controller.text] being just the local part — read it with [fullPhone].
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.controller,
    this.label = "PHONE NUMBER",
  });

  final TextEditingController controller;
  final String label;

  static String fullPhone(String localDigits) =>
      "${AppConstants.bdPhoneCountryCode}$localDigits";

  @override
  Widget build(BuildContext context) {
    return _LabeledField(
      label: label,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.phone,
        maxLength: 10,
        decoration: const InputDecoration(
          counterText: "",
          prefixIcon: Icon(Icons.call_outlined, size: 20),
          prefixText: "${AppConstants.bdPhoneCountryCode} ",
          hintText: "17 12345678",
        ),
        validator: (value) {
          final v = (value ?? "").trim();
          if (v.isEmpty) return "ফোন নম্বর দিতে হবে";
          if (!RegExp(r'^\d{9,10}$').hasMatch(v)) {
            return "সঠিক ফোন নম্বর দাও (যেমন: 1712345678)";
          }
          return null;
        },
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.label = "PASSWORD",
    this.hint,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return _LabeledField(
      label: widget.label,
      trailing: widget.hint,
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscure,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock_outline, size: 20),
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        validator: widget.validator ??
            (value) {
              if ((value ?? "").isEmpty) return "পাসওয়ার্ড দিতে হবে";
              if ((value ?? "").length < 8) return "কমপক্ষে ৮ ক্যারেক্টার";
              return null;
            },
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child, this.trailing});

  final String label;
  final Widget child;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: labelStyle),
            if (trailing != null) Text(trailing!, style: labelStyle),
          ],
        ),
        const SizedBox(height: 6),
        child,
        const SizedBox(height: 16),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon = Icons.arrow_forward,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, size: 18),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Shows [message] as a dismissible error banner (used for API errors).
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message, this.onDismiss});

  final String message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.onErrorContainer, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colors.onErrorContainer, fontSize: 13),
            ),
          ),
          if (onDismiss != null)
            InkWell(
              onTap: onDismiss,
              child: Icon(Icons.close, size: 16, color: colors.onErrorContainer),
            ),
        ],
      ),
    );
  }
}
