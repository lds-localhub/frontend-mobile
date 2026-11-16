import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/api/session.dart';
import 'package:localhub/data/app_lifecycle.dart';
import 'package:localhub/router/router.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/widgets/ui/messages.dart';

Future<void> main() async {
  // Antes de qualquer plugin (armazenamento seguro, orientação)
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await initializeDateFormatting('pt_PT');
  await Session.instance.load();

  if (kReleaseMode) {
    ErrorWidget.builder = (details) => const Material(
      child: Center(child: Text('Ocorreu um erro inesperado.')),
    );
  }
  PlatformDispatcher.instance.onError = (error, stack) {
    FlutterError.reportError(
      FlutterErrorDetails(exception: error, stack: stack),
    );
    return true;
  };

  runApp(const ProviderScope(retry: retryReads, child: LocalHubApp()));
}

/// Novas tentativas das leituras: nunca nos 4xx; nos erros de rede e nos 5xx,
/// até 2 vezes.
Duration? retryReads(int retryCount, Object error) {
  if (error is ApiError && error.status < 500) {
    return null;
  }
  if (retryCount >= 2) {
    return null;
  }
  return Duration(milliseconds: 500 * (retryCount + 1));
}

/// Aplicação: tema, português, router e mensagens; avisa os providers quando a
/// aplicação volta ao primeiro plano.
class LocalHubApp extends ConsumerStatefulWidget {
  const LocalHubApp({super.key});

  @override
  ConsumerState<LocalHubApp> createState() => _LocalHubAppState();
}

class _LocalHubAppState extends ConsumerState<LocalHubApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: () => ref.read(appResumedProvider.notifier).resumed(),
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LocalHub',
      theme: appTheme,
      routerConfig: ref.watch(routerProvider),
      scaffoldMessengerKey: scaffoldMessengerKey,
      locale: const Locale('pt', 'PT'),
      supportedLocales: const [Locale('pt', 'PT')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}
