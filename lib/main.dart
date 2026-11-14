import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/router/router.dart';
import 'package:localhub/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const LocalHubApp());
}

/// Aplicação: tema, português e router.
class LocalHubApp extends StatelessWidget {
  const LocalHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LocalHub',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: router,
      locale: const Locale('pt', 'PT'),
      supportedLocales: const [Locale('pt', 'PT')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}
