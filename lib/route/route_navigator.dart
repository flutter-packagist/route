import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract class PageInterface {
  Widget build(BuildContext context, TabController tabController);
}

class RouteNavigator extends StatefulWidget implements PageInterface {
  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  const RouteNavigator(
    this.navigationShell,
    this.children, {
    super.key,
  });

  @override
  State<RouteNavigator> createState() => _RouteNavigatorState();

  @override
  Widget build(BuildContext context, TabController tabController) {
    throw UnimplementedError();
  }
}

class _RouteNavigatorState extends State<RouteNavigator>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
      length: widget.children.length,
      vsync: this,
      initialIndex: widget.navigationShell.currentIndex);
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController.addListener(() {
      if (_currentIndex == _tabController.index) return;
      widget.navigationShell.goBranch(_tabController.index);
    });
  }

  @override
  void didUpdateWidget(covariant RouteNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentIndex = widget.navigationShell.currentIndex;
    _tabController.index = _currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return widget.build(context, _tabController);
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
