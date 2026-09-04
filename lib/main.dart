import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'const.dart';
import 'providers/router_provider.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  FlutterNativeSplash.remove();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        fontFamily: 'Inter',
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: kAppColors.primaryColor,
        scaffoldBackgroundColor: kAppColors.cream,
        extensions: [kAppColors],
        colorScheme: ColorScheme.light(
          primary: kAppColors.primaryColor,
          secondary: kAppColors.secondaryColor,
          surface: kAppColors.surfaceBg,
          error: kAppColors.danger,
          onPrimary: kAppColors.paper,
          onSecondary: kAppColors.paper,
          onSurface: kAppColors.textPrimary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: kAppColors.paper,
          foregroundColor: kAppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: kAppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: kAppColors.paper,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: kAppColors.border),
          ),
        ),
        bottomAppBarTheme: BottomAppBarThemeData(
          color: kAppColors.paper,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: const CircularNotchedRectangle(),
        ),
        dividerTheme: DividerThemeData(color: kAppColors.border, thickness: 1),
        tabBarTheme: TabBarThemeData(
          labelColor: kAppColors.primaryColor,
          unselectedLabelColor: kAppColors.muted,
          indicatorColor: kAppColors.primaryColor,

          dividerColor: kAppColors.baltic,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kAppColors.primaryColor,
            foregroundColor: kAppColors.paper,
            elevation: 0,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kAppColors.primaryColor,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(color: kAppColors.primaryColor),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: kAppColors.primaryColor,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
