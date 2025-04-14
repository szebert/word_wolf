import "package:flutter/material.dart";

import "../not_found/not_found_page.dart";
import "sticky_ad.dart";

/// A layout that keeps the ad banner persistent at the bottom of the screen
/// while allowing the content above to navigate independently.
class PersistentAdLayout extends StatefulWidget {
  const PersistentAdLayout({
    required this.child,
    super.key,
  });

  final Widget child;

  // Static navigator key to access the content navigator
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Helper method to get the content navigator from anywhere
  static NavigatorState? getContentNavigator(BuildContext context) {
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      return navigator;
    }

    // Fallback to the root navigator if not found
    return Navigator.of(context);
  }

  // Helper to navigate within the content area
  static Future<T?> navigateTo<T>(BuildContext context, Route<T> route) {
    final navigator = getContentNavigator(context);
    return navigator?.push(route) ?? Future.value(null);
  }

  @override
  State<PersistentAdLayout> createState() => _PersistentAdLayoutState();
}

class _PersistentAdLayoutState extends State<PersistentAdLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Main content area with Navigator
          Expanded(
            child: ClipRect(
              child: Navigator(
                key: PersistentAdLayout.navigatorKey,
                onGenerateRoute: (settings) {
                  if (settings.name == "/") {
                    return MaterialPageRoute(
                      builder: (_) => widget.child,
                      settings: settings,
                    );
                  }

                  // Use the route as is if it's a MaterialPageRoute or other route type
                  if (settings.name == null) {
                    final route = settings.arguments as Route?;
                    if (route != null) return route;
                  }

                  return MaterialPageRoute(
                    builder: (_) => NotFoundPage(routeName: settings.name),
                    settings: settings,
                  );
                },
              ),
            ),
          ),
          // Persistent ad area
          const StickyAd(),
        ],
      ),
    );
  }
}
