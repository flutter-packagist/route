import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/bottomsheet/bottomsheet.dart';
import 'package:get/get_navigation/src/dialog/dialog_route.dart';
import 'package:get/get_navigation/src/router_report.dart';
import 'package:log_wrapper/log/log.dart';

/// The Navigator observer.
class GoNavigatorObserver extends NavigatorObserver {
  final Routing? routing;

  GoNavigatorObserver([this.routing]);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final newRoute = _RouteData.ofRoute(route);

    if (newRoute.isBottomSheet || newRoute.isDialog) {
      logV("OPEN ${newRoute.name}");
    } else if (newRoute.isPageRoute) {
      logV("GOING TO ROUTE ${newRoute.name}");
    }

    RouterReportManager.reportCurrentRoute(route);
    routing?.update((value) {
      // Only PageRoute is allowed to change current value
      if (route is PageRoute) {
        value.current = newRoute.name ?? '';
      }
      final previousRouteName = _extractRouteName(previousRoute);
      if (previousRouteName != null) {
        value.previous = previousRouteName;
      }

      value.route = route;
      value.isBack = false;
      value.removed = '';
      value.isBottomSheet =
          newRoute.isBottomSheet ? true : value.isBottomSheet ?? false;
      value.isDialog = newRoute.isDialog ? true : value.isDialog ?? false;
    });
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final currentRoute = _RouteData.ofRoute(route);
    final newRoute = _RouteData.ofRoute(previousRoute);

    if (currentRoute.isBottomSheet || currentRoute.isDialog) {
      logV("CLOSE ${currentRoute.name}");
    } else if (currentRoute.isPageRoute) {
      logV("CLOSE TO ROUTE ${currentRoute.name}");
    }

    if (previousRoute != null) {
      RouterReportManager.reportCurrentRoute(previousRoute);
    }

    // Here we use a 'inverse didPush set', meaning that we use
    // previous route instead of 'route' because this is
    // a 'inverse push'
    routing?.update((value) {
      // Only PageRoute is allowed to change current value
      if (previousRoute is PageRoute) {
        value.current = _extractRouteName(previousRoute) ?? '';
        value.previous = newRoute.name ?? '';
      } else if (value.previous.isNotEmpty) {
        value.current = value.previous;
      }

      value.route = previousRoute;
      value.isBack = true;
      value.removed = '';
      value.isBottomSheet = newRoute.isBottomSheet;
      value.isDialog = newRoute.isDialog;
    });
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    final routeName = _extractRouteName(route);
    final currentRoute = _RouteData.ofRoute(route);

    logV("REMOVING ROUTE $routeName");

    routing?.update((value) {
      value.route = previousRoute;
      value.isBack = false;
      value.removed = routeName ?? '';
      value.previous = routeName ?? '';
      value.isBottomSheet =
          currentRoute.isBottomSheet ? false : value.isBottomSheet;
      value.isDialog = currentRoute.isDialog ? false : value.isDialog;
    });

    if (route.settings is MaterialPage) {
      RouterReportManager.reportRouteWillDispose(route);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final newName = _extractRouteName(newRoute);
    final oldName = _extractRouteName(oldRoute);
    final currentRoute = _RouteData.ofRoute(oldRoute);

    logV("REPLACE ROUTE $oldName");
    logV("NEW ROUTE $newName");

    if (newRoute != null) {
      RouterReportManager.reportCurrentRoute(newRoute);
    }

    routing?.update((value) {
      // Only PageRoute is allowed to change current value
      if (newRoute is PageRoute) {
        value.current = newName ?? '';
      }

      value.route = newRoute;
      value.isBack = false;
      value.removed = '';
      value.previous = '$oldName';
      value.isBottomSheet =
          currentRoute.isBottomSheet ? false : value.isBottomSheet;
      value.isDialog = currentRoute.isDialog ? false : value.isDialog;
    });

    if (oldRoute?.settings is MaterialPage) {
      RouterReportManager.reportRouteWillDispose(oldRoute!);
    }
  }
}

class Routing {
  String current;
  String previous;
  dynamic args;
  String removed;
  Route<dynamic>? route;
  bool? isBack;
  bool? isBottomSheet;
  bool? isDialog;

  Routing({
    this.current = '',
    this.previous = '',
    this.args,
    this.removed = '',
    this.route,
    this.isBack,
    this.isBottomSheet,
    this.isDialog,
  });

  void update(void Function(Routing value) fn) {
    fn(this);
  }
}

/// This is basically a util for rules about 'what a route is'
class _RouteData {
  final bool isPageRoute;
  final bool isBottomSheet;
  final bool isDialog;
  final String? name;

  _RouteData({
    required this.name,
    required this.isPageRoute,
    required this.isBottomSheet,
    required this.isDialog,
  });

  factory _RouteData.ofRoute(Route? route) {
    return _RouteData(
      name: _extractRouteName(route),
      isPageRoute: route?.settings is MaterialPage,
      isDialog: route is GetDialogRoute,
      isBottomSheet: route is GetModalBottomSheetRoute,
    );
  }
}

/// Extracts the name of a route based on it's instance type
/// or null if not possible.
String? _extractRouteName(Route? route) {
  if (route?.settings.name != null) {
    if (route!.settings.name!.isEmpty) {
      return route.settings.toString();
    }
    return route.settings.name;
  }

  if (route?.settings is MaterialPage) {
    return route!.settings.name;
  }

  if (route is GetDialogRoute) {
    return 'DIALOG ${route.hashCode}';
  }

  if (route is GetModalBottomSheetRoute) {
    return 'BOTTOMSHEET ${route.hashCode}';
  }

  return route?.settings.toString();
}
