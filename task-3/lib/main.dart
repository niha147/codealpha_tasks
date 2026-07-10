import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/settings_provider.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/activities/activities_screen.dart';
import 'features/analytics/analytics_screen.dart';
import 'features/insights/insights_screen.dart';
import 'features/profile/profile_screen.dart';
import 'core/utils/notification_service.dart';
import 'features/dashboard/widgets/goal_celebration_overlay.dart';

import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await NotificationService().init();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exceptionAsString()}');
  };

  runZonedGuarded(
    () {
      runApp(const ProviderScope(child: FitTrackApp()));
    },
    (error, stackTrace) {
      debugPrint('Uncaught Error: $error');
      debugPrint('Stack Trace: $stackTrace');
    },
  );
}

class FitTrackApp extends ConsumerWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    ThemeMode mode;
    switch (settings.themeMode) {
      case 'light':
        mode = ThemeMode.light;
        break;
      case 'dark':
        mode = ThemeMode.dark;
        break;
      default:
        mode = ThemeMode.system;
    }

    ThemeData lightTheme = settings.highContrast
        ? AppTheme.highContrastLightTheme
        : AppTheme.lightTheme;
    ThemeData darkTheme = settings.highContrast
        ? AppTheme.highContrastDarkTheme
        : AppTheme.darkTheme;

    return MaterialApp(
      title: 'FitTrack',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: mode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.largeText ? 1.3 : 1.0),
          ),
          child: child!,
        );
      },
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Request notification permission for Android 13+
    await Permission.notification.request();
  }

  final List<Widget> _screens = const [
    DashboardScreen(),
    ActivitiesScreen(),
    AnalyticsScreen(),
    InsightsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return GoalCelebrationOverlay(
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.directions_run_outlined),
              selectedIcon: Icon(Icons.directions_run),
              label: 'Activities',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Analytics',
            ),
            NavigationDestination(
              icon: Icon(Icons.lightbulb_outline),
              selectedIcon: Icon(Icons.lightbulb),
              label: 'Insights',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
