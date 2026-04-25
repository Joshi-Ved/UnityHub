import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:unityhub_mobile/core/responsive/layout_builder.dart';
import 'package:unityhub_mobile/features/map/map_screen.dart';
import 'package:unityhub_mobile/features/wallet/wallet_screen.dart';
import 'package:unityhub_mobile/features/auth/auth_screen.dart';
import 'package:unityhub_mobile/features/auth/splash_screen.dart';
import 'package:unityhub_mobile/features/tasks/task_list_screen.dart';
import 'package:unityhub_mobile/features/tasks/verification_modal.dart';
import 'package:unityhub_mobile/features/profile/volunteer_profile_screen.dart';

import 'package:unityhub_mobile/features/dashboard/analytics_dashboard_screen.dart';
import 'package:unityhub_mobile/features/dashboard/volunteer_directory_screen.dart';
import 'package:unityhub_mobile/features/task_management/task_management_screen.dart';
import 'package:unityhub_mobile/features/esg_reports/esg_report_generator_screen.dart';

// Dummy Auth State
enum UserRole { none, volunteer, ngo, sponsor }

final authProvider = StateProvider<UserRole>((ref) => UserRole.none);

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuthRoute = location.startsWith('/auth');

      if (location == '/') {
        if (authState == UserRole.none) return null;
        if (authState == UserRole.volunteer) return '/volunteer/map';
        if (authState == UserRole.ngo) return '/ngo/dashboard';
        return '/sponsor/dashboard';
      }

      if (authState == UserRole.none) {
        if (isAuthRoute || location == '/') return null;
        if (location.startsWith('/ngo') || location.startsWith('/sponsor')) {
          return '/auth/ngo';
        }
        return '/auth/volunteer';
      }

      if (isAuthRoute) {
        if (authState == UserRole.volunteer) return '/volunteer/map';
        if (authState == UserRole.ngo) return '/ngo/dashboard';
        return '/sponsor/dashboard';
      }

      if (authState == UserRole.volunteer && location.startsWith('/ngo')) {
        return '/volunteer/map';
      }
      if (authState == UserRole.ngo && location.startsWith('/volunteer')) {
        return '/ngo/dashboard';
      }
      if (authState == UserRole.sponsor && location.startsWith('/volunteer')) {
        return '/sponsor/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/volunteer',
        builder: (context, state) => const AuthScreen(role: UserRole.volunteer),
      ),
      GoRoute(
        path: '/auth/ngo',
        builder: (context, state) => const AuthScreen(role: UserRole.ngo),
      ),

      GoRoute(
        path: '/volunteer/map',
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'volunteer',
          currentLocation: state.matchedLocation,
          child: const MapScreen(),
        ),
      ),
      GoRoute(
        path: '/volunteer/tasks',
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'volunteer',
          currentLocation: state.matchedLocation,
          child: const TaskListScreen(),
        ),
      ),
      GoRoute(
        path: '/volunteer/verify/:id',
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'volunteer',
          currentLocation: state.matchedLocation,
          child: const VerificationModal(),
        ),
      ),
      GoRoute(
        path: '/volunteer/wallet',
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'volunteer',
          currentLocation: state.matchedLocation,
          child: const WalletScreen(),
        ),
      ),
      GoRoute(
        path: '/volunteer/profile',
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'volunteer',
          currentLocation: state.matchedLocation,
          child: const VolunteerProfileScreen(),
        ),
      ),

      GoRoute(
        path: '/ngo/dashboard',
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'ngo',
          currentLocation: state.matchedLocation,
          child: const AnalyticsDashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/ngo/tasks',
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'ngo',
          currentLocation: state.matchedLocation,
          child: const TaskManagementScreen(),
        ),
      ),
      GoRoute(
        path: '/ngo/volunteers',
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'ngo',
          currentLocation: state.matchedLocation,
          child: const VolunteerDirectoryScreen(),
        ),
      ),
      GoRoute(
        path: '/ngo/reports',
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'ngo',
          currentLocation: state.matchedLocation,
          child: const ESGReportGeneratorScreen(),
        ),
      ),

      GoRoute(
        path: '/sponsor/dashboard',
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'sponsor',
          currentLocation: state.matchedLocation,
          child: const AnalyticsDashboardScreen(),
        ),
      ),
    ],
  );
});
