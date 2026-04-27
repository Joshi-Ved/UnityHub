import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unityhub_mobile/core/router/app_routes.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-redirect to the volunteer auth screen after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) context.go(AppRoutes.authVolunteer);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary500,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hub_rounded, size: 88, color: AppColors.textInverse),
            const SizedBox(height: 20),
            const Text(
              'UnityHub',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.textInverse,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Verified Impact Protocol',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.primary100,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textInverse),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
