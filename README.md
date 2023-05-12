## Route

### 简介
提供灵活的路由切换  
支持命名路由和创建路由  
提供路由切换拦截器、切换动画以及路由历史记录管理等  

### 引入
```
ad_route:
    git:
      https://github.com/flutter-packagist/route.git
```

### 初始化
```dart
return MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
        primarySwatch: Colors.blue,
    ),
    home: const MyHomePage(title: 'Flutter Demo Home Page'),
    navigatorObservers: [
        /// 路由管理初始化
        RouteManager()
        ..init(
            /// 首页名称，防止指定返回的时候 返回到最开始路由
            homeName: "MyApp",
            /// 路由生命周期回调
            options: [RouteOptions()],
        ),
    ],
);
```

### 使用
1. push
```dart
RouteManager().pushPage(RoutePage2(), arguments: {"id": 2}).then((value){
    print("接收下个页面回传的值: $value");
});
```

2. pop
```dart
pop(result: "ok");
```

### License
The MIT License (MIT). Please see [License File](LICENSE) for more information.


