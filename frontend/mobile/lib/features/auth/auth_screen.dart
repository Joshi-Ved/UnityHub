import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unityhub_mobile/core/router/app_routes.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';
import 'package:unityhub_mobile/core/router/app_router.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      // Prevent Android back button from clearing auth state and looping
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.primary50,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hub_rounded, size: 100, color: AppColors.primary500),
                const SizedBox(height: 24),
                Text('UnityHub', style: Theme.of(context).textTheme.displayLarge),
                const SizedBox(height: 8),
                const Text(
                  'Verified Impact Protocol',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
                ),
                const SizedBox(height: 64),
                if (role == UserRole.volunteer)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Set role then navigate — GoRouter redirect picks up the change
                        ref.read(authProvider.notifier).state = UserRole.volunteer;
                        context.go(AppRoutes.volunteerMap);
                      },
                      icon: const Icon(Icons.volunteer_activism),
                      label: const Text('Login via DigiLocker (Volunteer)'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                    ),
                  ),
                if (role == UserRole.ngo)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref.read(authProvider.notifier).state = UserRole.ngo;
                        context.go(AppRoutes.ngoDashboard);
                      },
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text('Login via Google OAuth (NGO)'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                    ),
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go(
                    role == UserRole.volunteer ? AppRoutes.authNgo : AppRoutes.authVolunteer,
                  ),
                  child: Text(
                    role == UserRole.volunteer
                        ? 'NGO Admin? Switch to Google OAuth'
                        : 'Volunteer? Switch to DigiLocker',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
