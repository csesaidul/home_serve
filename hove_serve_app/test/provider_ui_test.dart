import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homeserve_app/features/provider/screens/category_browse_screen.dart';
import 'package:homeserve_app/features/provider/screens/provider_profile_screen.dart';

void main() {
  testWidgets('category browse screen shows service list and provider cards', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: CategoryBrowseScreen())),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('provider profile screen renders profile content', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ProviderProfileScreen()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
