import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A row of single-digit boxes (like the OTP mockup). Calls [onChanged]
/// with the full code every time it changes, and [onCompleted] once all
/// boxes are filled.
///
/// [initialValue] pre-fills the boxes — used to auto-fill the backend's
/// mock OTP (see [AuthState.mockOtp]) since there's no real SMS gateway
/// in the MVP yet.
class OtpBoxes extends StatefulWidget {
  const OtpBoxes({
    super.key,
    required this.length,
    required this.onChanged,
    this.onCompleted,
    this.initialValue,
  });

  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final String? initialValue;

  @override
  State<OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<OtpBoxes> {
  late final List<TextEditingController> _controllers =
      List.generate(widget.length, (_) => TextEditingController());
  late final List<FocusNode> _nodes = List.generate(widget.length, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    if (initial != null && initial.isNotEmpty) {
      for (var i = 0; i < widget.length && i < initial.length; i++) {
        _controllers[i].text = initial[i];
      }
      // Notify the parent's onChanged only (not onCompleted) so the code
      // is reflected in state without auto-submitting the verify call.
      WidgetsBinding.instance.addPostFrameCallback((_) => _emit(notifyCompleted: false));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _emit({bool notifyCompleted = true}) {
    final code = _controllers.map((c) => c.text).join();
    widget.onChanged(code);
    if (notifyCompleted && code.length == widget.length) {
      widget.onCompleted?.call(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 52,
          child: TextField(
            controller: _controllers[index],
            focusNode: _nodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(counterText: ""),
            onChanged: (value) {
              if (value.isNotEmpty && index < widget.length - 1) {
                _nodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _nodes[index - 1].requestFocus();
              }
              _emit();
            },
          ),
        );
      }),
    );
  }
}
