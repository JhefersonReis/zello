import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello/l10n/app_localizations.dart';
import 'package:zello/src/app/providers/providers.dart';
import 'package:zello/src/app/router/routes.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF248f3d)), useMaterial3: true),
      routerConfig: Routes.router,
    );
  }
}
