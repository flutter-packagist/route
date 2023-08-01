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
  PageTransitionType transitionType = PageTransitionType.right,
}) {
  GoRouterPageBuilder? pageBuilder;
  if (child != null) {
    pageBuilder = (BuildContext context, GoRouterState state) {
      passGoArguments(state);
      return transition(transitionType, state, child);
    };
  }
  List<RouteBase>? routeList = const <RouteBase>[];
  if (routes != null && routes.isNotEmpty) routeList = routes;
  return GoRoute(
    name: name,
    path: path,
    pageBuilder: pageBuilder,
    routes: routeList,
  );
}

/// 使用GO路由进行参数传递
void passGoArguments(GoRouterState state) {
  Map<String, dynamic> args = <String, dynamic>{};
  if (state.pathParameters.isNotEmpty) args.addAll(state.pathParameters);
  if (state.uri.queryParameters.isNotEmpty) {
    args.addAll(state.uri.queryParameters);
  }
  Go.routing.args = args;
  logV("current route: ${Go.currentRoute}, arguments: $args");
}

/// 路由切换动画
Page transition(
  PageTransitionType transitionType,
  GoRouterState state,
  Widget child,
) {
  switch (transitionType) {
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
  required Widget Function(
    StatefulNavigationShell navigationShell,
    List<Widget> children,
  )
      containerBuilder,
  required List<StatefulShellBranch> branches,
}) {
  return StatefulShellRoute(
    builder: (BuildContext context, GoRouterState state,
        StatefulNavigationShell navigationShell) {
      return navigationShell;
    },
    navigatorContainerBuilder: (BuildContext context,
        StatefulNavigationShell navigationShell, List<Widget> children) {
      return containerBuilder(navigationShell, children);
    },
    branches: branches,
  );
}
