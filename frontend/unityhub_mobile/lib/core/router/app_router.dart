import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:unityhub_mobile/features/map/map_screen.dart';
import 'package:unityhub_mobile/features/wallet/wallet_screen.dart';
import 'package:unityhub_mobile/features/auth/auth_screen.dart';

import 'package:unityhub_mobile/features/admin/dashboard/admin_dashboard_screen.dart';
import 'package:unityhub_mobile/features/admin/tasks/admin_tasks_screen.dart';
import 'package:unityhub_mobile/features/admin/reports/admin_reports_screen.dart';

// Dummy Auth State
enum UserRole { none, volunteer, admin }

final authProvider = StateProvider<UserRole>((ref) => UserRole.none);

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/auth',
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == '/auth';
      
      if (authState == UserRole.none) {
        return isAuthRoute ? null : '/auth';
      }

      if (isAuthRoute) {
        return authState == UserRole.admin ? '/admin/dashboard' : '/';
      }

      // Prevent volunteers from accessing admin routes
      if (state.matchedLocation.startsWith('/admin') && authState != UserRole.admin) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      // Volunteer Routes
      GoRoute(
        path: '/',
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      // Admin Routes
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/tasks',
        builder: (context, state) => const AdminTasksScreen(),
      ),
      GoRoute(
        path: '/admin/reports',
        builder: (context, state) => const AdminReportsScreen(),
      ),
    ],
  );
});
