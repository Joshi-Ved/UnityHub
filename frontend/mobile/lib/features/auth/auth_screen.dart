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
  bool _isRegistering = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

  Future<void> _submitEmailPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter email and password');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      if (_isRegistering) {
        await authService.registerWithEmailPassword(email, password);
      } else {
        await authService.signInWithEmailPassword(email, password);
      }
      if (!mounted) return;
      ref.read(authProvider.notifier).state = UserRole.ngo;
      context.go(AppRoutes.adminDashboard);
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentication failed: ${e.toString().split(']').last.trim()}';
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
          child: SingleChildScrollView(
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
                const SizedBox(height: 48),

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
                  if (widget.role == UserRole.ngo) ...[
                    // Email Field
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    // Password Field
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submitEmailPassword(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Sign In / Register Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitEmailPassword,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                        child: Text(_isRegistering ? 'Register' : 'Sign In'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Toggle Register/Sign In mode
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isRegistering = !_isRegistering;
                          _errorMessage = null;
                        });
                      },
                      child: Text(
                        _isRegistering
                            ? 'Already have an account? Sign In'
                            : 'Need an account? Register',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('OR', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Google Sign In Alternative
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _signInAsNgo,
                        icon: const Icon(Icons.admin_panel_settings),
                        label: const Text('Continue with Google'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                      ),
                    ),
                  ],
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
                      : () {
                          setState(() {
                            _errorMessage = null;
                            _isRegistering = false;
                            _emailController.clear();
                            _passwordController.clear();
                          });
                          context.go(
                            widget.role == UserRole.volunteer
                                ? AppRoutes.authNgo
                                : AppRoutes.authVolunteer,
                          );
                        },
                  child: Text(
                    widget.role == UserRole.volunteer
                        ? 'NGO Admin? Switch to NGO Login'
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
