import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unityhub_mobile/core/router/app_routes.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unityhub_mobile/core/config/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLinking = false;
  bool _isLinked = false;
  String? _walletAddress;

  Future<void> _linkDigiLocker() async {
    setState(() => _isLinking = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLinking = false;
      _isLinked = true;
    });
    // Move to next page after a short delay
    await Future.delayed(const Duration(milliseconds: 500));
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  Future<void> _createWalletAndFinish() async {
    setState(() => _isLinking = true);
    
    // Generate an EVM address
    var random = Random.secure();
    EthPrivateKey credentials = EthPrivateKey.createRandom(random);
    var address = credentials.address;
    
    _walletAddress = address.hexEip55;

    // Simulate pushing to backend
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/api/volunteers/wallet'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'wallet_address': _walletAddress}),
      );
    } catch (_) {
      // Ignore for demo purposes
    }

    setState(() => _isLinking = false);
    if (mounted) {
      context.go(AppRoutes.volunteerMap);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                physics: const NeverScrollableScrollPhysics(), // Force using buttons
                children: [
                  // Page 1: Impact
                  _buildPage(
                    title: 'Welcome to UnityHub',
                    description: 'Track your volunteering impact with cryptographic proof and AI verification.',
                    icon: Icons.public,
                    action: ElevatedButton(
                      onPressed: () {
                        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                      },
                      child: const Text('Next'),
                    ),
                  ),
                  // Page 2: Identity
                  _buildPage(
                    title: 'Verify Identity',
                    description: 'Link your DigiLocker to start earning Verified Impact Tokens (VIT).',
                    icon: Icons.badge,
                    action: _isLinked
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: AppColors.success),
                              SizedBox(width: 8),
                              Text('DigiLocker Linked', style: TextStyle(color: AppColors.success)),
                            ],
                          )
                        : ElevatedButton(
                            onPressed: _isLinking ? null : _linkDigiLocker,
                            child: _isLinking
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Link DigiLocker'),
                          ),
                  ),
                  // Page 3: Wallet
                  _buildPage(
                    title: 'Your Impact Wallet',
                    description: 'We will create a local Polygon wallet to securely store your VITs.',
                    icon: Icons.account_balance_wallet,
                    action: ElevatedButton(
                      onPressed: _isLinking ? null : _createWalletAndFinish,
                      child: _isLinking
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Create Wallet & Start'),
                    ),
                  ),
                ],
              ),
            ),
            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? AppColors.primary500 : AppColors.neutral200,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({required String title, required String description, required IconData icon, required Widget action}) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: AppColors.primary500),
          const SizedBox(height: 40),
          Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(description, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
          const SizedBox(height: 48),
          action,
        ],
      ),
    );
  }
}
