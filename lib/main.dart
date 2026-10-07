import 'package:flutter/material.dart';

import 'app.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final NuriAppState state = await NuriAppState.bootstrap();
  runApp(NuriScope(state: state, child: const NuriApp()));
}
