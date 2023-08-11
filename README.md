# Route Manager

- [Example](https://github.com/flutter-packagist/example/)

## Usage

### Define routes constants

```dart
abstract class Routes {
  static const main = Paths.main;
  static const transition = Paths.transition;
  static const transitionNone = "${Paths.transition}/${Paths.none}";
  static const transitionFade = "${Paths.transition}/${Paths.fade}";
  static const notFound = Paths.notFound;
}

abstract class Paths {
  static const main = '/main';
  static const transition = '/transition';
  static const none = 'none';
  static const fade = 'fade';
  static const notFound = '/404';
}
```

### Configure routing

``` dart
class AppPages {
  AppPages._();

  static final GoRouter router = GoRouter(
    navigatorKey: Go.key,
    observers: <NavigatorObserver>[
      GoNavigatorObserver(Go.routing),
    ],
    initialLocation: Paths.main,
    routes: <RouteBase>[
      goRoute(path: Paths.main, child: const MainPage()),
      goRoute(path: Paths.transition, child: const TransitionPage(), routes: [
        goRoute(
          path: Paths.none,
          child: const TransitionNextPage(),
          transitionType: PageTransitionType.none,
        ),
        goRoute(
          path: Paths.fade,
          child: const TransitionNextPage(),
          transitionType: PageTransitionType.fade,
        ),
      ]),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      logV("redirect: ${state.matchedLocation}");
      // no need to redirect at all
      return null;
    },
    onException: (context, GoRouterState state, GoRouter router) {
      router.go(Routes.notFound, extra: {"uri": state.uri.toString()});
    },
  );
}
```

`Go.key` should be initialized in `GoRouter` as `navigatorKey` property. Most of function
of `GoRouter` is based on it.<br>
`GoNavigatorObserver(Go.routing),` should be initialized in `GoRouter` as `observers` property. It
is used to observe the route changes.<br>
`initialLocation` property is the first route to be displayed.<br>
`routes` is the list of routes to be used in the app.<br>
`redirect` is the function to decide if a route should be redirected to another route.<br>
`onException` is the function to be called when an exception is thrown.<br>

### How to navigate

``` dart
Go.go(Routes.transitionNone);

Go.push(Routes.transitionNone);

Go.to(Routes.transitionNone);
```

`Go.go` is used to navigate to a route. It will push the current route to stack and change browser
url on web site.<br>
`Go.push` is used to navigate to a route. It will push the current route to stack but not change
browser url on web site.<br>
`Go.to` is wrapper of `Go.push` and `Go.go`, it will call `Go.go` on web site and call `Go.push` on
others.<br>

## Embedded pages on Web

Synchronize browser Url when switching embedded pages.

### TabBar and TabBarView

Define a stateful shell route for tab bar.

``` dart
static final GoRouter router = GoRouter(
  initialLocation: Paths.main,
  routes: <RouteBase>[
    goRoute(path: Paths.main, child: const MainPage()),
    
    // define a stateful shell route for tab bar
    statefulShellRoute(
      navigatorContainerBuilder: (context, navigationShell, children) =>
          TabNavigatorWeb(navigationShell, children),
      branches: <StatefulShellBranch>[
        StatefulShellBranch(routes: <GoRoute>[
          goRoute(path: Paths.tab1, child: const DetailPage("Tab1")),
        ]),
        StatefulShellBranch(routes: <GoRoute>[
          goRoute(path: Paths.tab2, child: const DetailPage("Tab2")),
        ]),
      ],
    ),
  ],
);
```

`TabNavigatorWeb`: display tab bar and tab view. When switching tab bar (tab view), it will change
browser url. And when browser url is changed, it will switch tab bar (tab view). TabBar and TabView
will switch synchronously.

``` dart
class TabNavigatorWeb extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  const TabNavigatorWeb(
    this.navigationShell,
    this.children, {
    super.key,
  });

  @override
  State<TabNavigatorWeb> createState() => _TabNavigatorWebState();
}

class _TabNavigatorWebState extends State<TabNavigatorWeb>
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
  void didUpdateWidget(covariant TabNavigatorWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentIndex = widget.navigationShell.currentIndex;
    _tabController.index = _currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TabNavigatorWeb'),
      ),
      body: Column(children: [
        TabBar(
          controller: _tabController,
          onTap: (int index) {
            widget.navigationShell.goBranch(index);
          },
          tabs: const [
            Tab(text: 'Tab1'),
            Tab(text: 'Tab2'),
          ],
          labelColor: Colors.black,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.children,
          ),
        ),
      ]),
    );
  }
}
```

### BottomNavigationBar and PageView

Define a stateful shell route for BottomNavigationBar.

``` dart
static final GoRouter router = GoRouter(
  initialLocation: Paths.main,
  routes: <RouteBase>[
    goRoute(path: Paths.main, child: const MainPage()),
    
    // define a stateful shell route for BottomNavigationBar
    statefulShellRoute(
      navigatorContainerBuilder: (context, navigationShell, children) =>
          PageNavigatorWeb(navigationShell, children),
      branches: <StatefulShellBranch>[
        StatefulShellBranch(routes: <GoRoute>[
          goRoute(path: Paths.page1, child: const DetailPage("Page1")),
        ]),
        StatefulShellBranch(routes: <GoRoute>[
          goRoute(path: Paths.page2, child: const DetailPage("Page2")),
        ]),
      ],
    ),
  ],
);
```

`PageNavigatorWeb`: display BottomNavigationBar and PageView. When switching BottomNavigationBar (
PageView), it will change browser url. And when browser url is changed, it will switch
BottomNavigationBar (PageView). PageView and BottomNavigationBar will switch synchronously.

``` dart
class PageNavigatorWeb extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  const PageNavigatorWeb(
    this.navigationShell,
    this.children, {
    super.key,
  });

  @override
  State<PageNavigatorWeb> createState() => _PageNavigatorWebState();
}

class _PageNavigatorWebState extends State<PageNavigatorWeb> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    initPageController();
  }

  @override
  void didUpdateWidget(covariant PageNavigatorWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    initPageController();
  }

  void initPageController() {
    _pageController = PageController(
      initialPage: widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NavigationBar'),
      ),
      body: PageView(
        controller: _pageController,
        children: widget.children,
        onPageChanged: (int index) {
          widget.navigationShell.goBranch(index);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Section A'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Section B'),
        ],
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (int index) {
          widget.navigationShell.goBranch(index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 200),
            curve: Curves.linear,
          );
        },
      ),
    );
  }
}
```

### indexedStack

Define a stateful shell route for indexedStack.

``` dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      StackNavigatorWeb(navigationShell),
  branches: <StatefulShellBranch>[
    StatefulShellBranch(routes: <GoRoute>[
      goRoute(path: Paths.stack1, child: const DetailPage("Stack1")),
    ]),
    StatefulShellBranch(routes: <GoRoute>[
      goRoute(path: Paths.stack2, child: const DetailPage("Stack2")),
    ]),
  ],
),
```

`StackNavigatorWeb`: Switching BottomNavigationBar to change the index of IndexedStack and browser
url.

``` dart
class StackNavigatorWeb extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const StackNavigatorWeb(
    this.navigationShell, {
    super.key,
  });

  @override
  State<StackNavigatorWeb> createState() => _StackNavigatorWebState();
}

class _StackNavigatorWebState extends State<StackNavigatorWeb> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IndexedStack'),
      ),
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Section A'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Section B'),
        ],
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (int index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
```

### ShellRoute

Define a ShellRoute for embedded navigation.

``` dart
static final GoRouter router = GoRouter(
  initialLocation: Paths.main,
  routes: <RouteBase>[
    goRoute(path: Paths.main, child: const MainPage()),
    
    ShellRoute(
      builder: (context, state, child) => ShellNavigatorWeb(child),
      routes: <RouteBase>[
        goRoute(
          path: Paths.shell1,
          child: const DetailPage("Shell1"),
          transitionType: PageTransitionType.fade,
        ),
        goRoute(
          path: Paths.shell2,
          child: const DetailPage("Shell2"),
          transitionType: PageTransitionType.fade,
        ),
      ],
    ),
  ],
);
```

`ShellNavigatorWeb`: route switch by browser url and BottomNavigationBar.

``` dart
class ShellNavigatorWeb extends StatelessWidget {
  final Widget child;

  const ShellNavigatorWeb(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShellRoute'),
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'A Screen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'B Screen',
          ),
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(Routes.shell1)) {
      return 0;
    }
    if (location.startsWith(Routes.shell1)) {
      return 1;
    }
    return 0;
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Go.go(Routes.shell1);
        break;
      case 1:
        Go.go(Routes.shell2);
        break;
    }
  }
}
```

## Parameter passing

### Setting parameters

``` dart
static const argumentsPath = 'path/:title/:url';

Go.to(
  argumentsPath, 
  params: {'title': '标题', 'url': '链接'},
  queryParams: {'title': '标题', 'url': '链接'},
  pathParams: {'title': '标题', 'url': '链接'},
);
```

On Web, `queryParams` and `pathParams` will change the browser url. `params` will not change the
browser url, just pass the parameters to the next page.<br>
`queryParams`: the url will become `path?title=标题&url=链接`.<br>
`pathParams`: the url will become `path/标题/链接`.<br>
On Other platforms, suggested to use `params`.<br>

### Getting parameters

``` dart
model.title = Go.arguments['title'] ?? "null";
model.url = Go.arguments['url'] ?? "null";
```

## NavigatorObserver

### Custom NavigatorObserver

``` dart
class DialogObserver extends NavigatorObserver {
  /// Creates a [DialogObserver].

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is GetDialogRoute) {
      showToast("弹窗展示", position: ToastPosition.top);
      logD('弹窗展示');
      return;
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is GetDialogRoute) {
      showToast("弹窗关闭", position: ToastPosition.top);
      logD('弹窗关闭');
      return;
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      logD('didRemove: ${route.str}, previousRoute= ${previousRoute?.str}');

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      logD('didReplace: new= ${newRoute?.str}, old= ${oldRoute?.str}');

  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) =>
      logD('didStartUserGesture: ${route.str}, '
          'previousRoute= ${previousRoute?.str}');

  @override
  void didStopUserGesture() => logD('didStopUserGesture');
}

extension on Route<dynamic> {
  String get str => 'route(${settings.name}: ${settings.arguments})';
}
```

### Setting NavigatorObserver

``` dart
GoRouter(
  ...
  
  observers: [
    GoNavigatorObserver(),
    DialogObserver(),
  ],
  
  ...
);
```

## Route redirect

``` dart
GoRouter(
  ...
  
  redirect: (BuildContext context, GoRouterState state) {
    logV("redirect: ${state.matchedLocation}");
    if (isNotLogin) {
      return Routes.login;
    }
  
    // no need to redirect at all
    return null;
  },
  
  ...
);
```

## Route exception: not found

``` dart
GoRouter(
  ...
  
  onException: (context, GoRouterState state, GoRouter router) {
    router.go(Routes.notFound, extra: {"uri": state.uri.toString()});
  },
  
  ...
);
```

## Navigation Animation

``` dart
enum PageTransitionType {
  // 禁用动画
  disabled,
  // 无动画
  none,
  // 渐变透明
  fade,
  // 缩放动画
  scale,
  // 旋转
  rotate,
  // 从中间往上下延伸
  size,
  // 从右到左
  right,
  // 从左到右
  left,
  // 从上到下
  top,
  // 从下到上
  bottom,
  // 从右到左，加渐变透明
  rightFade,
  // 从左到右，加渐变透明
  leftFade,
}
```

Define a route with animation by `transitionType` property.

``` dart
goRoute(
  path: Paths.none,
  child: const TransitionNextPage(),
  transitionType: PageTransitionType.none,
),
```



