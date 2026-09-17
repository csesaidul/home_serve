import 'package:flutter/material.dart';

/// D1-T5 asked for "a placeholder page for each screen" — this is that
/// placeholder, reused for /home, /booking, /admin etc. until their real
/// UIs are built in later tasks (D3-T5/T6, D4-T5...).
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          "$title — coming soon",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
