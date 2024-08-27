import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/bottomsheet/bottomsheet.dart';
import 'package:get/get_navigation/src/dialog/dialog_route.dart';
import 'package:get/get_navigation/src/router_report.dart';
import 'package:go_router/go_router.dart';
import 'package:log_wrapper/log/log.dart';
import 'package:route/route/go_navigator.dart';

/// The Navigator observer.
class GoNavigatorObserver extends NavigatorObserver {
  final Routing? routing;

  GoNavigatorObserver([this.routing]);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final newRoute = _RouteData.ofRoute(route);

    if (newRoute.isBottomSheet || newRoute.isDialog) {
      logV("OPEN ${newRoute.name} => args: ${routing?.args}");
    } else if (newRoute.isPageRoute) {
      logV("GOING TO ROUTE ${newRoute.name} => args: ${routing?.args}");
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

    if (routing != null) {
      Go.routingQueue.add(routing!.copyWith());
    }
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

    if (Go.routingQueue.isNotEmpty) {
      Go.routingQueue.removeLast();
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

      if (Go.routingQueue.isNotEmpty) {
        value.args = Go.routingQueue.last.args;
        value.previous = Go.routingQueue.last.previous;
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

    if (routing != null && Go.routingQueue.isNotEmpty) {
      Go.routingQueue.removeLast();
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

    if (routing != null && Go.routingQueue.isNotEmpty) {
      Go.routingQueue.removeLast();
      Go.routingQueue.add(routing!.copyWith());
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

  Routing copyWith({Routing? route}) {
    return Routing(
      current: route?.current ?? this.current,
      previous: route?.previous ?? this.previous,
      args: route?.args ?? this.args,
      removed: route?.removed ?? this.removed,
      route: route?.route ?? this.route,
      isBack: route?.isBack ?? this.isBack,
      isBottomSheet: route?.isBottomSheet ?? this.isBottomSheet,
      isDialog: route?.isDialog ?? this.isDialog,
    );
  }

  @override
  String toString() {
    return "[ Routing: current: $current, previous: $previous, args: $args, "
        "removed: $removed, route: $route, isBack: $isBack, "
        "isBottomSheet: $isBottomSheet, isDialog: $isDialog ]";
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
      isPageRoute: route?.settings is MaterialPage ||
          route?.settings is CustomTransitionPage,
      isDialog: route is GetDialogRoute,
      isBottomSheet: route is GetModalBottomSheetRoute,
    );
  }
}

/// Extracts the name of a route based on it's instance type
/// or null if not possible.
String? _extractRouteName(Route? route) {
  if (route?.settings is CustomTransitionPage) {
    return _parseRouteSettings(route?.settings);
  }

  if (route?.settings is MaterialPage) {
    return _parseRouteSettings(route?.settings);
  }

  if (route is GetDialogRoute) {
    return 'DIALOG ${route.hashCode}';
  }

  if (route is GetModalBottomSheetRoute) {
    return 'BOTTOMSHEET ${route.hashCode}';
  }

  return _parseRouteSettings(route?.settings);
}

String _parseRouteSettings(RouteSettings? routeSettings) {
  if (routeSettings?.name != null && routeSettings!.name!.isNotEmpty) {
    return routeSettings.name!;
  }
  return routeSettings?.toString() ?? '';
}
