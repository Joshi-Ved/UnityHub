import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:unityhub_mobile/core/router/app_routes.dart';
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
import 'package:unityhub_mobile/features/admin/dashboard/admin_dashboard_screen.dart';
import 'package:unityhub_mobile/features/admin/tasks/admin_tasks_screen.dart';
import 'package:unityhub_mobile/features/admin/reports/admin_reports_screen.dart';

// Dummy Auth State
enum UserRole { none, volunteer, ngo, sponsor }

final authProvider = StateProvider<UserRole>((ref) => UserRole.none);

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuthRoute = location.startsWith(AppRoutes.authPrefix);

      if (location == AppRoutes.splash) {
        if (authState == UserRole.none) return null;
        if (authState == UserRole.volunteer) return AppRoutes.volunteerMap;
        if (authState == UserRole.ngo) return AppRoutes.ngoDashboard;
        return AppRoutes.sponsorDashboard;
      }

      if (authState == UserRole.none) {
        if (isAuthRoute || location == AppRoutes.splash) return null;
        if (location.startsWith(AppRoutes.ngoPrefix) || location.startsWith(AppRoutes.sponsorPrefix)) {
          return AppRoutes.authNgo;
        }
        return AppRoutes.authVolunteer;
      }

      if (isAuthRoute) {
        if (authState == UserRole.volunteer) return AppRoutes.volunteerMap;
        if (authState == UserRole.ngo) return AppRoutes.ngoDashboard;
        return AppRoutes.sponsorDashboard;
      }

      if (authState == UserRole.volunteer && location.startsWith(AppRoutes.ngoPrefix)) {
        return AppRoutes.volunteerMap;
      }
      if (authState == UserRole.ngo && location.startsWith(AppRoutes.volunteerPrefix)) {
        return AppRoutes.ngoDashboard;
      }
      if (authState == UserRole.sponsor && location.startsWith(AppRoutes.volunteerPrefix)) {
        return AppRoutes.sponsorDashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.authVolunteer,
        builder: (context, state) => const AuthScreen(role: UserRole.volunteer),
      ),
      GoRoute(
        path: AppRoutes.authNgo,
        builder: (context, state) => const AuthScreen(role: UserRole.ngo),
      ),

      GoRoute(
        path: AppRoutes.volunteerMap,
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'volunteer',
          currentLocation: state.matchedLocation,
          child: const MapScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.volunteerTasks,
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'volunteer',
          currentLocation: state.matchedLocation,
          child: const TaskListScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.volunteerVerifyBase}/:id',
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'volunteer',
          currentLocation: state.matchedLocation,
          child: const VerificationModal(),
        ),
      ),
      GoRoute(
        path: AppRoutes.volunteerWallet,
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'volunteer',
          currentLocation: state.matchedLocation,
          child: const WalletScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.volunteerProfile,
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'volunteer',
          currentLocation: state.matchedLocation,
          child: const VolunteerProfileScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.ngoDashboard,
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'ngo',
          currentLocation: state.matchedLocation,
          child: const AnalyticsDashboardScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.ngoTasks,
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'ngo',
          currentLocation: state.matchedLocation,
          child: const TaskManagementScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.ngoVolunteers,
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'ngo',
          currentLocation: state.matchedLocation,
          child: const VolunteerDirectoryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.ngoReports,
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'ngo',
          currentLocation: state.matchedLocation,
          child: const ESGReportGeneratorScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.sponsorDashboard,
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'sponsor',
          currentLocation: state.matchedLocation,
          child: const AnalyticsDashboardScreen(),
        ),
      ),

      // Admin routes — previously scaffolded but unreachable; now wired
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'ngo',
          currentLocation: state.matchedLocation,
          child: const AdminDashboardScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminTasks,
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'ngo',
          currentLocation: state.matchedLocation,
          child: const AdminTasksScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminReports,
        builder: (context, state) => AdaptiveLayout(
          roleScope: 'ngo',
          currentLocation: state.matchedLocation,
          child: const AdminReportsScreen(),
        ),
      ),
    ],
  );
});
