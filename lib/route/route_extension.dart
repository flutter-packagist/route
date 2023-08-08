import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:log_wrapper/log/log.dart';

import 'go_navigator.dart';
import 'route_transition.dart';

/// GoRouter扩展
/// 1. 添加路由参数传递
/// 2. 添加路由切换动画
GoRoute goRoute({
  required String path,
  String? name,
  Widget? child,
  List<RouteBase>? routes,
  PageTransitionType transitionType = PageTransitionType.disabled,
}) {
  GoRouterWidgetBuilder? widgetBuilder;
  GoRouterPageBuilder? pageBuilder;
  if (child != null) {
    if (transitionType == PageTransitionType.disabled) {
      widgetBuilder = (BuildContext context, GoRouterState state) {
        routeArguments(state);
        return child;
      };
    } else {
      pageBuilder = (BuildContext context, GoRouterState state) {
        routeArguments(state);
        return routeTransition(transitionType, state, child);
      };
    }
  }
  List<RouteBase>? routeList = const <RouteBase>[];
  if (routes != null && routes.isNotEmpty) routeList = routes;
  return GoRoute(
    name: name,
    path: path,
    builder: widgetBuilder,
    pageBuilder: pageBuilder,
    routes: routeList,
  );
}

/// 使用GO路由进行参数传递
void routeArguments(GoRouterState state) {
  if (state.matchedLocation == Go.currentRoute) return;
  Map<String, dynamic> args = <String, dynamic>{};
  if (state.pathParameters.isNotEmpty) args.addAll(state.pathParameters);
  if (state.uri.queryParameters.isNotEmpty) {
    args.addAll(state.uri.queryParameters);
  }
  if (state.extra != null &&
      state.extra is Map<String, dynamic> &&
      (state.extra as Map<String, dynamic>).isNotEmpty) {
    args.addAll(state.extra as Map<String, dynamic>);
  }
  Go.routing.args = args;
  if (args.isEmpty) return;
  logV("PREVIOUS ROUTE: ${Go.currentRoute}, arguments: $args");
}

/// 路由切换动画
Page routeTransition(
  PageTransitionType transitionType,
  GoRouterState state,
  Widget child,
) {
  switch (transitionType) {
    case PageTransitionType.disabled:
    case PageTransitionType.none:
      return NoTransitionPage(
        key: state.pageKey,
        name: state.path,
        child: child,
      );
    case PageTransitionType.fade:
      return FadeTransitionPage(
        key: state.pageKey,
        name: state.path,
        child: child,
      );
    case PageTransitionType.scale:
      return ScaleTransitionPage(
        key: state.pageKey,
        child: child,
      );
    case PageTransitionType.rotate:
      return RotateTransitionPage(
        key: state.pageKey,
        name: state.path,
        child: child,
      );
    case PageTransitionType.size:
      return SizeTransitionPage(
        key: state.pageKey,
        name: state.path,
        child: child,
      );
    case PageTransitionType.right:
      return RightToLeftTransitionPage(
        key: state.pageKey,
        name: state.path,
        child: child,
      );
    case PageTransitionType.left:
      return LeftToRightTransitionPage(
        key: state.pageKey,
        name: state.path,
        child: child,
      );
    case PageTransitionType.top:
      return TopToBottomTransitionPage(
        key: state.pageKey,
        name: state.path,
        child: child,
      );
    case PageTransitionType.bottom:
      return BottomToTopTransitionPage(
        key: state.pageKey,
        name: state.path,
        child: child,
      );
    case PageTransitionType.leftFade:
      return LeftToRightWithFadeTransitionPage(
        key: state.pageKey,
        name: state.path,
        child: child,
      );
    case PageTransitionType.rightFade:
      return RightToLeftWithFadeTransitionPage(
        key: state.pageKey,
        name: state.path,
        child: child,
      );
  }
}

/// StatefulShellRoute 简写
StatefulShellRoute statefulShellRoute({
  required ShellNavigationContainerBuilder navigatorContainerBuilder,
  required List<StatefulShellBranch> branches,
}) {
  return StatefulShellRoute(
    builder: (BuildContext context, GoRouterState state,
        StatefulNavigationShell navigationShell) {
      return navigationShell;
    },
    navigatorContainerBuilder: navigatorContainerBuilder,
    branches: branches,
  );
}
