import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomer/app.dart';

void main() {
  testWidgets('App starts and shows bottom navigation with 5 items',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);

    final destinations = tester.widgetList<NavigationDestination>(
      find.byType(NavigationDestination),
    );
    expect(destinations.length, 5);
  });

  testWidgets('NavigationBar shows Timer, Tasks, Garden, Stats, and Settings labels',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    final navBar = find.byType(NavigationBar);
    expect(
      find.descendant(of: navBar, matching: find.text('Timer')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navBar, matching: find.text('Tasks')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navBar, matching: find.text('Garden')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navBar, matching: find.text('Stats')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navBar, matching: find.text('Settings')),
      findsOneWidget,
    );
  });

  testWidgets('Timer screen is shown by default', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));

    // Let StreamProviders emit and settle
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('25:00'), findsOneWidget);
  });
}
