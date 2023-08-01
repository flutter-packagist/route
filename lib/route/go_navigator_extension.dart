part of 'go_navigator.dart';

NavigatorState? get navigator => GoNavigation(Go).key.currentState;

extension ExtensionBottomSheet on GoInterface {
  Future<T?> bottomSheet<T>(
    Widget bottomSheet, {
    Color? backgroundColor,
    double? elevation,
    bool persistent = true,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color? barrierColor,
    bool? ignoreSafeArea,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    RouteSettings? settings,
    Duration? enterBottomSheetDuration,
    Duration? exitBottomSheetDuration,
  }) {
    return Navigator.of(overlayContext!, rootNavigator: useRootNavigator)
        .push(GetModalBottomSheetRoute<T>(
      builder: (_) => bottomSheet,
      isPersistent: persistent,
      // theme: Theme.of(key.currentContext, shadowThemeOnly: true),
      theme: Theme.of(key.currentContext!),
      isScrollControlled: isScrollControlled,

      barrierLabel: MaterialLocalizations.of(key.currentContext!)
          .modalBarrierDismissLabel,

      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation,
      shape: shape,
      removeTop: ignoreSafeArea ?? true,
      clipBehavior: clipBehavior,
      isDismissible: isDismissible,
      modalBarrierColor: barrierColor,
      settings: settings,
      enableDrag: enableDrag,
      enterBottomSheetDuration:
          enterBottomSheetDuration ?? const Duration(milliseconds: 250),
      exitBottomSheetDuration:
          exitBottomSheetDuration ?? const Duration(milliseconds: 200),
    ));
  }
}

extension ExtensionDialog on GoInterface {
  /// Show a dialog.
  /// You can pass a [transitionDuration] and/or [transitionCurve],
  /// overriding the defaults when the dialog shows up and closes.
  /// When the dialog closes, uses those animations in reverse.
  Future<T?> dialog<T>(
    Widget widget, {
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useSafeArea = true,
    GlobalKey<NavigatorState>? navigatorKey,
    Object? arguments,
    Duration? transitionDuration,
    Curve? transitionCurve,
    String? name,
    RouteSettings? routeSettings,
  }) {
    assert(debugCheckHasMaterialLocalizations(context!));

    //  final theme = Theme.of(context, shadowThemeOnly: true);
    final theme = Theme.of(context!);
    return generalDialog<T>(
      pageBuilder: (buildContext, animation, secondaryAnimation) {
        final pageChild = widget;
        Widget dialog = Builder(builder: (context) {
          return Theme(data: theme, child: pageChild);
        });
        if (useSafeArea) {
          dialog = SafeArea(child: dialog);
        }
        return dialog;
      },
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context!).modalBarrierDismissLabel,
      barrierColor: barrierColor ?? Colors.black54,
      transitionDuration: transitionDuration ?? defaultDialogTransitionDuration,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: transitionCurve ?? defaultDialogTransitionCurve,
          ),
          child: child,
        );
      },
      navigatorKey: navigatorKey,
      routeSettings:
          routeSettings ?? RouteSettings(arguments: arguments, name: name),
    );
  }

  /// Api from showGeneralDialog with no context
  Future<T?> generalDialog<T>({
    required RoutePageBuilder pageBuilder,
    bool barrierDismissible = false,
    String? barrierLabel,
    Color barrierColor = const Color(0x80000000),
    Duration transitionDuration = const Duration(milliseconds: 200),
    RouteTransitionsBuilder? transitionBuilder,
    GlobalKey<NavigatorState>? navigatorKey,
    RouteSettings? routeSettings,
  }) {
    assert(!barrierDismissible || barrierLabel != null);
    final nav = navigatorKey?.currentState ??
        Navigator.of(overlayContext!,
            rootNavigator:
                true); //overlay context will always return the root navigator
    return nav.push<T>(
      GetDialogRoute<T>(
        pageBuilder: pageBuilder,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        barrierColor: barrierColor,
        transitionDuration: transitionDuration,
        transitionBuilder: transitionBuilder,
        settings: routeSettings,
      ),
    );
  }

  /// Custom UI Dialog.
  Future<T?> defaultDialog<T>({
    String title = "Alert",
    EdgeInsetsGeometry? titlePadding,
    TextStyle? titleStyle,
    Widget? content,
    EdgeInsetsGeometry? contentPadding,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    VoidCallback? onCustom,
    Color? cancelTextColor,
    Color? confirmTextColor,
    String? textConfirm,
    String? textCancel,
    String? textCustom,
    Widget? confirm,
    Widget? cancel,
    Widget? custom,
    Color? backgroundColor,
    bool barrierDismissible = true,
    Color? buttonColor,
    String middleText = "Dialog made in 3 lines of code",
    TextStyle? middleTextStyle,
    double radius = 20.0,
    //   ThemeData themeData,
    List<Widget>? actions,

    // onWillPop Scope
    WillPopCallback? onWillPop,

    // the navigator used to push the dialog
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    var leanCancel = onCancel != null || textCancel != null;
    var leanConfirm = onConfirm != null || textConfirm != null;
    actions ??= [];

    if (cancel != null) {
      actions.add(cancel);
    } else {
      if (leanCancel) {
        actions.add(TextButton(
          style: TextButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: buttonColor ?? theme.colorScheme.secondary,
                    width: 2,
                    style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(100)),
          ),
          onPressed: () {
            onCancel?.call();
            pop();
          },
          child: Text(
            textCancel ?? "Cancel",
            style: TextStyle(
                color: cancelTextColor ?? theme.colorScheme.secondary),
          ),
        ));
      }
    }
    if (confirm != null) {
      actions.add(confirm);
    } else {
      if (leanConfirm) {
        actions.add(TextButton(
          style: TextButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: buttonColor ?? theme.colorScheme.secondary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)),
          ),
          child: Text(
            textConfirm ?? "Ok",
            style: TextStyle(
                color: confirmTextColor ?? theme.colorScheme.background),
          ),
          onPressed: () {
            onConfirm?.call();
          },
        ));
      }
    }

    Widget baseAlertDialog = AlertDialog(
      titlePadding: titlePadding ?? const EdgeInsets.all(8),
      contentPadding: contentPadding ?? const EdgeInsets.all(8),

      backgroundColor: backgroundColor ?? theme.dialogBackgroundColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius))),
      title: Text(title, textAlign: TextAlign.center, style: titleStyle),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          content ??
              Text(middleText,
                  textAlign: TextAlign.center, style: middleTextStyle),
          const SizedBox(height: 16),
          ButtonTheme(
            minWidth: 78.0,
            height: 34.0,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: actions,
            ),
          )
        ],
      ),
      // actions: actions, // ?? <Widget>[cancelButton, confirmButton],
      buttonPadding: EdgeInsets.zero,
    );

    return dialog<T>(
      onWillPop != null
          ? WillPopScope(
              onWillPop: onWillPop,
              child: baseAlertDialog,
            )
          : baseAlertDialog,
      barrierDismissible: barrierDismissible,
      navigatorKey: navigatorKey,
    );
  }
}

extension ExtensionSnackBar on GoInterface {
  SnackbarController rawSnackBar({
    String? title,
    String? message,
    Widget? titleText,
    Widget? messageText,
    Widget? icon,
    bool instantInit = true,
    bool shouldIconPulse = true,
    double? maxWidth,
    EdgeInsets margin = const EdgeInsets.all(0.0),
    EdgeInsets padding = const EdgeInsets.all(16),
    double borderRadius = 0.0,
    Color? borderColor,
    double borderWidth = 1.0,
    Color backgroundColor = const Color(0xFF303030),
    Color? leftBarIndicatorColor,
    List<BoxShadow>? boxShadows,
    Gradient? backgroundGradient,
    Widget? mainButton,
    OnTap? onTap,
    Duration? duration = const Duration(seconds: 3),
    bool isDismissible = true,
    DismissDirection? dismissDirection,
    bool showProgressIndicator = false,
    AnimationController? progressIndicatorController,
    Color? progressIndicatorBackgroundColor,
    Animation<Color>? progressIndicatorValueColor,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    SnackStyle snackStyle = SnackStyle.FLOATING,
    Curve forwardAnimationCurve = Curves.easeOutCirc,
    Curve reverseAnimationCurve = Curves.easeOutCirc,
    Duration animationDuration = const Duration(seconds: 1),
    SnackbarStatusCallback? snackBarStatus,
    double barBlur = 0.0,
    double overlayBlur = 0.0,
    Color? overlayColor,
    Form? userInputForm,
  }) {
    final getSnackBar = GetSnackBar(
      snackbarStatus: snackBarStatus,
      title: title,
      message: message,
      titleText: titleText,
      messageText: messageText,
      snackPosition: snackPosition,
      borderRadius: borderRadius,
      margin: margin,
      duration: duration,
      barBlur: barBlur,
      backgroundColor: backgroundColor,
      icon: icon,
      shouldIconPulse: shouldIconPulse,
      maxWidth: maxWidth,
      padding: padding,
      borderColor: borderColor,
      borderWidth: borderWidth,
      leftBarIndicatorColor: leftBarIndicatorColor,
      boxShadows: boxShadows,
      backgroundGradient: backgroundGradient,
      mainButton: mainButton,
      onTap: onTap,
      isDismissible: isDismissible,
      dismissDirection: dismissDirection,
      showProgressIndicator: showProgressIndicator,
      progressIndicatorController: progressIndicatorController,
      progressIndicatorBackgroundColor: progressIndicatorBackgroundColor,
      progressIndicatorValueColor: progressIndicatorValueColor,
      snackStyle: snackStyle,
      forwardAnimationCurve: forwardAnimationCurve,
      reverseAnimationCurve: reverseAnimationCurve,
      animationDuration: animationDuration,
      overlayBlur: overlayBlur,
      overlayColor: overlayColor,
      userInputForm: userInputForm,
    );

    final controller = SnackbarController(getSnackBar);

    if (instantInit) {
      controller.show();
    } else {
      ambiguate(SchedulerBinding.instance)?.addPostFrameCallback((_) {
        controller.show();
      });
    }
    return controller;
  }

  SnackbarController showSnackBar(GetSnackBar snackbar) {
    final controller = SnackbarController(snackbar);
    controller.show();
    return controller;
  }

  SnackbarController snackbar(
    String title,
    String message, {
    Color? colorText,
    Duration? duration = const Duration(seconds: 3),

    /// with instantInit = false you can put snackbar on initState
    bool instantInit = true,
    SnackPosition? snackPosition,
    Widget? titleText,
    Widget? messageText,
    Widget? icon,
    bool? shouldIconPulse,
    double? maxWidth,
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
    Color? backgroundColor,
    Color? leftBarIndicatorColor,
    List<BoxShadow>? boxShadows,
    Gradient? backgroundGradient,
    TextButton? mainButton,
    OnTap? onTap,
    bool? isDismissible,
    bool? showProgressIndicator,
    DismissDirection? dismissDirection,
    AnimationController? progressIndicatorController,
    Color? progressIndicatorBackgroundColor,
    Animation<Color>? progressIndicatorValueColor,
    SnackStyle? snackStyle,
    Curve? forwardAnimationCurve,
    Curve? reverseAnimationCurve,
    Duration? animationDuration,
    double? barBlur,
    double? overlayBlur,
    SnackbarStatusCallback? snackBarStatus,
    Color? overlayColor,
    Form? userInputForm,
  }) {
    final getSnackBar = GetSnackBar(
        snackbarStatus: snackBarStatus,
        titleText: titleText ??
            Text(
              title,
              style: TextStyle(
                color: colorText ?? iconColor ?? Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
        messageText: messageText ??
            Text(
              message,
              style: TextStyle(
                color: colorText ?? iconColor ?? Colors.black,
                fontWeight: FontWeight.w300,
                fontSize: 14,
              ),
            ),
        snackPosition: snackPosition ?? SnackPosition.TOP,
        borderRadius: borderRadius ?? 15,
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 10),
        duration: duration,
        barBlur: barBlur ?? 7.0,
        backgroundColor: backgroundColor ?? Colors.grey.withOpacity(0.2),
        icon: icon,
        shouldIconPulse: shouldIconPulse ?? true,
        maxWidth: maxWidth,
        padding: padding ?? const EdgeInsets.all(16),
        borderColor: borderColor,
        borderWidth: borderWidth,
        leftBarIndicatorColor: leftBarIndicatorColor,
        boxShadows: boxShadows,
        backgroundGradient: backgroundGradient,
        mainButton: mainButton,
        onTap: onTap,
        isDismissible: isDismissible ?? true,
        dismissDirection: dismissDirection,
        showProgressIndicator: showProgressIndicator ?? false,
        progressIndicatorController: progressIndicatorController,
        progressIndicatorBackgroundColor: progressIndicatorBackgroundColor,
        progressIndicatorValueColor: progressIndicatorValueColor,
        snackStyle: snackStyle ?? SnackStyle.FLOATING,
        forwardAnimationCurve: forwardAnimationCurve ?? Curves.easeOutCirc,
        reverseAnimationCurve: reverseAnimationCurve ?? Curves.easeOutCirc,
        animationDuration: animationDuration ?? const Duration(seconds: 1),
        overlayBlur: overlayBlur ?? 0.0,
        overlayColor: overlayColor ?? Colors.transparent,
        userInputForm: userInputForm);

    final controller = SnackbarController(getSnackBar);

    if (instantInit) {
      controller.show();
    } else {
      //routing.isSnackBar = true;
      ambiguate(SchedulerBinding.instance)?.addPostFrameCallback((_) {
        controller.show();
      });
    }
    return controller;
  }
}

extension OverlayExt on GoInterface {
  Future<T> showOverlay<T>({
    required Future<T> Function() asyncFunction,
    Color opacityColor = Colors.black,
    Widget? loadingWidget,
    double opacity = .5,
  }) async {
    final navigatorState =
        Navigator.of(Go.overlayContext!, rootNavigator: false);
    final overlayState = navigatorState.overlay!;

    final overlayEntryOpacity = OverlayEntry(builder: (context) {
      return Opacity(
          opacity: opacity,
          child: Container(
            color: opacityColor,
          ));
    });
    final overlayEntryLoader = OverlayEntry(builder: (context) {
      return loadingWidget ??
          const Center(
              child: SizedBox(
            height: 90,
            width: 90,
            child: Text('Loading...'),
          ));
    });
    overlayState.insert(overlayEntryOpacity);
    overlayState.insert(overlayEntryLoader);

    T data;

    try {
      data = await asyncFunction();
    } on Exception catch (_) {
      overlayEntryLoader.remove();
      overlayEntryOpacity.remove();
      rethrow;
    }

    overlayEntryLoader.remove();
    overlayEntryOpacity.remove();
    return data;
  }
}

extension GoNavigation on GoInterface {
  static GoSetting goSetting = GoSetting();

  Routing get routing => goSetting.routing;

  GlobalKey<NavigatorState> get key => goSetting.key;

  /// give access to currentContext
  BuildContext? get context => key.currentContext;

  /// give access to current Overlay Context
  BuildContext? get overlayContext {
    BuildContext? overlay;
    key.currentState?.overlay?.context.visitChildElements((element) {
      overlay = element;
    });
    return overlay;
  }

  /// give access to Theme.of(context)
  ThemeData get theme {
    var theme = ThemeData.fallback();
    if (context != null) {
      theme = Theme.of(context!);
    }
    return theme;
  }

  /// give access to Theme.of(context).iconTheme.color
  Color? get iconColor => theme.iconTheme.color;

  Duration get defaultDialogTransitionDuration =>
      const Duration(milliseconds: 300);

  Curve get defaultDialogTransitionCurve => Curves.easeOutQuad;

  GoRouter global() {
    if (context == null) {
      throw """You are trying to use contextless navigation!
      Please init Go.key first by using navigatorKey.""";
    }
    return GoRouter.of(context!);
  }

  /// give current arguments
  dynamic get arguments => routing.args;

  /// give name from current route
  String get currentRoute => routing.current;

  /// give name from previous route
  String get previousRoute => routing.previous;

  /// check if snackBar is open
  bool get isSnackBarOpen =>
      SnackbarController.isSnackbarBeingShown; //routing.isSnackBar;

  void closeAllSnackBars() {
    SnackbarController.cancelAllSnackbars();
  }

  Future<void> closeCurrentSnackBar() async {
    await SnackbarController.closeCurrentSnackbar();
  }

  /// check if dialog is open
  bool? get isDialogOpen => routing.isDialog;

  /// check if bottomSheet is open
  bool? get isBottomSheetOpen => routing.isBottomSheet;

  /// check a raw current route
  Route<dynamic>? get rawRoute => routing.route;

  /// Returns true if a SnackBar, Dialog or BottomSheet is currently OPEN
  bool get isOverlaysOpen =>
      (isSnackBarOpen || isDialogOpen! || isBottomSheetOpen!);

  /// Returns true if there is no SnackBar, Dialog or BottomSheet open
  bool get isOverlaysClosed =>
      (!isSnackBarOpen && !isDialogOpen! && !isBottomSheetOpen!);

  /// Get a location from route name and parameters.
  String namedLocation(
    String name, {
    Map<String, String> pathParams = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
  }) =>
      global().namedLocation(
        name,
        pathParameters: pathParams,
        queryParameters: queryParams,
      );

  Future<T?> to<T>(
    String location, {
    Map<String, dynamic> pathParams = const <String, dynamic>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) {
    if (GetPlatform.isWeb) {
      go(
        location,
        pathParams: pathParams,
        queryParams: queryParams,
        extra: extra,
      );
      return Future<T>.value(null);
    } else {
      return push<T>(
        location,
        pathParams: pathParams,
        queryParams: queryParams,
        extra: extra,
      );
    }
  }

  Future<T?> toNamed<T>(
    String name, {
    Map<String, String> pathParams = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) {
    if (GetPlatform.isWeb) {
      goNamed(
        name,
        pathParams: pathParams,
        queryParams: queryParams,
        extra: extra,
      );
      return Future<T>.value(null);
    } else {
      return pushNamed<T>(
        name,
        pathParams: pathParams,
        queryParams: queryParams,
        extra: extra,
      );
    }
  }

  /// Navigate to a location.
  void go(
    String location, {
    Map<String, dynamic> pathParams = const <String, dynamic>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) {
    pathParams.forEach((key, value) {
      if (location.contains(":$key")) {
        location = location.replaceAll(":$key", value.toString());
      }
    });
    queryParams.forEach((key, value) {
      location = "$location${location.contains("?") ? "&" : "?"}$key=$value";
    });
    global().go(location, extra: extra);
  }

  /// Navigate to a named route.
  void goNamed(
    String name, {
    Map<String, String> pathParams = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) =>
      global().goNamed(
        name,
        pathParameters: pathParams,
        queryParameters: queryParams,
        extra: extra,
      );

  /// Push a location onto the page stack.
  Future<T?> push<T>(
    String location, {
    Map<String, dynamic> pathParams = const <String, dynamic>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) {
    pathParams.forEach((key, value) {
      if (location.contains(":$key")) {
        location = location.replaceAll(":$key", value.toString());
      }
    });
    queryParams.forEach((key, value) {
      location = "$location${location.contains("?") ? "&" : "?"}$key=$value";
    });
    return global().push<T>(location, extra: extra);
  }

  /// Navigate to a named route onto the page stack.
  Future<T?> pushNamed<T>(
    String name, {
    Map<String, String> pathParams = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) =>
      global().pushNamed<T>(
        name,
        pathParameters: pathParams,
        queryParameters: queryParams,
        extra: extra,
      );

  /// Returns `true` if there is more than 1 page on the stack.
  bool canPop() => global().canPop();

  /// Pop the top page off the Navigator's page stack by calling
  /// [Navigator.pop].
  void pop<T extends Object?>([T? result]) => global().pop(result);

  /// Replaces the top-most page of the page stack with the given URL location
  /// w/ optional query parameters, e.g. `/family/f2/person/p1?color=blue`.
  ///
  /// See also:
  /// * [go] which navigates to the location.
  /// * [push] which pushes the location onto the page stack.
  void pushReplacement(String location, {Object? extra}) =>
      global().pushReplacement(location, extra: extra);

  /// Replaces the top-most page of the page stack with the named route w/
  /// optional parameters, e.g. `name='person', params={'fid': 'f2', 'pid':
  /// 'p1'}`.
  ///
  /// See also:
  /// * [goNamed] which navigates a named route.
  /// * [pushNamed] which pushes a named route onto the page stack.
  void pushReplacementNamed(
    String name, {
    Map<String, String> pathParams = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) =>
      global().pushReplacementNamed(
        name,
        pathParameters: pathParams,
        queryParameters: queryParams,
        extra: extra,
      );

  /// **Navigation.popUntil()** shortcut.<br><br>
  ///
  /// Pop the current page, snackbar, dialog or bottomSheet in the stack
  ///
  /// if your set [closeOverlays] to true, Get.back() will close the
  /// currently open snackbar/dialog/bottomSheet AND the current page
  ///
  /// [id] is for when you are using nested navigation,
  /// as explained in documentation
  ///
  /// It has the advantage of not needing context, so you can call
  /// from your business logic.
  void back<T>({
    T? result,
    bool closeOverlays = false,
    bool canPop = true,
    int? id,
  }) {
    if (isSnackBarOpen && !closeOverlays) {
      closeCurrentSnackBar();
      return;
    }

    if (closeOverlays && isOverlaysOpen) {
      if (isSnackBarOpen) {
        closeCurrentSnackBar();
      }
      navigator?.popUntil((route) {
        return (!isDialogOpen! && !isBottomSheetOpen!);
      });
    }

    try {
      if (canPop) {
        if (key.currentState?.canPop() == true) {
          pop<T>(result);
        }
      } else {
        pop<T>(result);
      }
    } catch (error) {
      if (routing.isDialog == true || routing.isBottomSheet == true) {
        Navigator.pop(key.currentContext!);
      }
    }
  }

  /// **Navigation.popUntil()** shortcut.<br><br>
  ///
  /// Calls pop several times in the stack until [predicate] returns true
  ///
  /// [id] is for when you are using nested navigation,
  /// as explained in documentation
  ///
  /// [predicate] can be used like this:
  /// `Get.until((route) => Get.currentRoute == '/home')`so when you get to home page,
  ///
  /// or also like this:
  /// `Get.until((route) => !Get.isDialogOpen())`, to make sure the
  /// dialog is closed
  void popUntil(RoutePredicate predicate, {int? id}) {
    // if (key.currentState.mounted) // add this if appear problems on future with route navigate
    // when widget don't mounted
    return key.currentState?.popUntil(predicate);
  }
}
