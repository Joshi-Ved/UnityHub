import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unityhub_mobile/core/router/app_routes.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';
import 'package:unityhub_mobile/core/router/app_router.dart';
import 'package:unityhub_mobile/features/auth/auth_service.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, required this.role});

  final UserRole role;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signInAsVolunteer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInAnonymously();
      if (!mounted) return;
      ref.read(authProvider.notifier).state = UserRole.volunteer;
      context.go(AppRoutes.volunteerMap);
    } catch (e) {
      setState(() {
        _errorMessage = 'Sign-in failed. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _signInAsNgo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authService = ref.read(authServiceProvider);
      final credential = await authService.signInWithGoogle();
      if (!mounted) return;
      if (credential == null) {
        // User cancelled
        setState(() => _isLoading = false);
        return;
      }
      ref.read(authProvider.notifier).state = UserRole.ngo;
      context.go(AppRoutes.adminDashboard);
    } catch (e) {
      setState(() {
        _errorMessage = 'Google sign-in failed: ${e.toString().split(']').last.trim()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
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

                if (_isLoading)
                  const CircularProgressIndicator()
                else ...[
                  if (widget.role == UserRole.volunteer)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _signInAsVolunteer,
                        icon: const Icon(Icons.volunteer_activism),
                        label: const Text('Login via DigiLocker (Volunteer)'),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                      ),
                    ),
                  if (widget.role == UserRole.ngo)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _signInAsNgo,
                        icon: const Icon(Icons.admin_panel_settings),
                        label: const Text('Login via Google OAuth (NGO)'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                      ),
                    ),
                ],

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: AppColors.error, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => context.go(
                            widget.role == UserRole.volunteer
                                ? AppRoutes.authNgo
                                : AppRoutes.authVolunteer,
                          ),
                  child: Text(
                    widget.role == UserRole.volunteer
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
