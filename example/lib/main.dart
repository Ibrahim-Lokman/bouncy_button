import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'state/warning_log.dart';

void main() {
  // Lets the Features tab show bouncy_button's debug warnings on screen.
  if (kDebugMode) {
    captureBouncyWarnings();
  }
  runApp(const BouncyDemoApp());
}
