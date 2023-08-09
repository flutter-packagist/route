import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/src/bottomsheet/bottomsheet.dart';
import 'package:get/get_navigation/src/dialog/dialog_route.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:go_router/go_router.dart';

import 'go_navigator_observer.dart';
import 'snackbar_controller.dart';

part 'go_navigator_extension.dart';

class GoSetting {
  final key = GlobalKey<NavigatorState>(debugLabel: 'Key Created by default');
  final routing = Routing();
}

abstract class GoInterface {}

class _GoImpl extends GoInterface {}

// ignore: non_constant_identifier_names
final Go = _GoImpl();
