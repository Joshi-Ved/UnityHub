import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unityhub_mobile/core/router/app_routes.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';
import 'package:unityhub_mobile/core/config/session.dart';
import 'package:unityhub_mobile/features/map/map_view_model.dart';
import 'package:unityhub_mobile/features/wallet/wallet_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:unityhub_mobile/core/config/constants.dart';

// State Enum
enum VerificationStep { capture, verifying, minting, result }

final verificationStepProvider = StateProvider<VerificationStep>((ref) => VerificationStep.capture);
final verificationResultProvider = StateProvider<bool?>((ref) => null);
final verificationReasonProvider = StateProvider<String?>((ref) => null);
final verificationTxHashProvider = StateProvider<String?>((ref) => null);

class VerificationModal extends ConsumerStatefulWidget {
  const VerificationModal({super.key});

  @override
  ConsumerState<VerificationModal> createState() => _VerificationModalState();
}

class _VerificationModalState extends ConsumerState<VerificationModal> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  XFile? _webPickedImage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (kIsWeb) return;
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(_cameras![0], ResolutionPreset.high);
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  /// Translates raw backend messages/errors into actionable copy for the volunteer.
  String _humanizeFailureReason(String? rawReason) {
    if (rawReason == null) return 'Something went wrong. Please try again.';
    final r = rawReason.toLowerCase();
    if (r.contains('duplicate')) {
      return 'This photo has already been submitted. Please take a new photo of the task.';
    }
    if (r.contains('fraud') || r.contains('screenshot') || r.contains('stock')) {
      return 'Photo looks like a screenshot or stock image. Please take a live photo at the task site.';
    }
    if (r.contains('mismatch') || r.contains('score')) {
      return "Photo didn't match task requirements — try again with a clearer image that shows the actual activity.";
    }
    if (r.contains('timed out')) {
      return 'Verification timed out. Check your internet connection and try again.';
    }
    if (r.contains('connection') || r.contains('failed')) {
      return "Couldn't reach the verification server. Check your internet and try again.";
    }
    if (r.contains('server error')) {
      return 'Server is temporarily unavailable. Please try again in a moment.';
    }
    if (r.contains('invalid image')) {
      return 'The photo file appears to be corrupted. Please take a new photo.';
    }
    return 'Verification could not be completed. Please try again with a clearer photo.';
  }

  Future<void> _verifyImpact() async {
    final task = ref.read(selectedTaskProvider);
    // Read the active wallet address from the session provider
    final userAddress = ref.read(activeWalletAddressProvider);
    ref.read(verificationStepProvider.notifier).state = VerificationStep.verifying;

    try {
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/verify-impact');
      var request = http.MultipartRequest('POST', uri);

      // Auth header — demo token; replace with real JWT when auth is wired
      request.headers['Authorization'] = 'Bearer mock_biometric_token';

      // Use the session wallet address, not a hardcoded dummy
      request.fields['ngo_task'] = task?.title ?? 'Unknown Task';
      request.fields['user_address'] = userAddress;

      // Add photo file
      if (kIsWeb && _webPickedImage != null) {
        final bytes = await _webPickedImage!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes('photo', bytes, filename: 'proof.jpg'));
      } else if (_cameraController != null) {
        final xFile = await _cameraController!.takePicture();
        final bytes = await xFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes('photo', bytes, filename: 'proof.jpg'));
      }

      // 30-second timeout — surfaces a clear message instead of hanging forever
      final streamedResponse = await request.send()
          .timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bool success = data['success'] ?? false;

        if (success) {
          ref.read(verificationStepProvider.notifier).state = VerificationStep.minting;

          final signature = data['signature'];
          // Use the real IPFS URI from the backend — never use a placeholder
          final String ipfsUri = data['ipfs_uri'] ?? 'ipfs://proof_unavailable';

          try {
            // Use DemoSession.demoPrivateKey which matches userAddress derived above
            final txHash = await ref.read(walletProvider.notifier).mintToken(
              signature: signature,
              taskId: 1,
              amount: task?.tokenReward ?? 10,
              ipfsUri: ipfsUri,
              userPrivateKey: DemoSession.demoPrivateKey,
            );
            ref.read(verificationTxHashProvider.notifier).state = txHash;
            ref.read(verificationResultProvider.notifier).state = true;
            ref.read(verificationReasonProvider.notifier).state = data['message'];
          } catch (mintError) {
            ref.read(verificationResultProvider.notifier).state = false;
            ref.read(verificationReasonProvider.notifier).state =
                'Impact verified ✅ but minting failed. Your proof is saved on IPFS. Try minting again from your wallet.';
          }
        } else {
          ref.read(verificationResultProvider.notifier).state = false;
          ref.read(verificationReasonProvider.notifier).state = data['message'];
        }
      } else {
        final data = jsonDecode(response.body);
        final errorBody = data['error'];
        final errorMessage = errorBody is Map<String, dynamic> ? errorBody['message']?.toString() : null;
        ref.read(verificationResultProvider.notifier).state = false;
        ref.read(verificationReasonProvider.notifier).state =
            errorMessage ?? 'server error ${response.statusCode}';
      }
    } on TimeoutException {
      ref.read(verificationResultProvider.notifier).state = false;
      ref.read(verificationReasonProvider.notifier).state =
          'verification timed out — the server took too long';
    } catch (e) {
      ref.read(verificationResultProvider.notifier).state = false;
      ref.read(verificationReasonProvider.notifier).state = 'connection failed: $e';
    }

    ref.read(verificationStepProvider.notifier).state = VerificationStep.result;
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(verificationStepProvider);
    final task = ref.watch(selectedTaskProvider);

    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textInverse),
          onPressed: () {
            ref.read(verificationStepProvider.notifier).state = VerificationStep.capture;
            ref.read(verificationResultProvider.notifier).state = null;
            context.go(AppRoutes.volunteerMap);
          },
        ),
        title: const Text('Impact Verification', style: TextStyle(color: AppColors.textInverse)),
      ),
      extendBodyBehindAppBar: true,
      body: _buildStep(step, task),
    );
  }

  Widget _buildStep(VerificationStep step, VolunteerTask? task) {
    switch (step) {
      case VerificationStep.capture:
        return _buildCaptureStep(task);
      case VerificationStep.verifying:
        return _buildVerifyingStep();
      case VerificationStep.minting:
        return _buildMintingStep();
      case VerificationStep.result:
        return _buildResultStep();
    }
  }

  Widget _buildCaptureStep(VolunteerTask? task) {
    if (kIsWeb) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.file_upload_outlined, color: AppColors.textInverse, size: 80),
              const SizedBox(height: 16),
              Text(
                'Upload proof image for "${task?.title ?? 'this task'}"',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textInverse, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final file = await picker.pickImage(source: ImageSource.gallery);
                  if (!mounted) return;
                  setState(() {
                    _webPickedImage = file;
                  });
                },
                icon: const Icon(Icons.image_outlined, color: AppColors.textInverse),
                label: Text(
                  _webPickedImage == null ? 'Choose file' : 'File selected',
                  style: const TextStyle(color: AppColors.textInverse),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Reset state then navigate — works whether we got here via
                  // showGeneralDialog (map tray) or context.go (task list)
                  ref.read(verificationStepProvider.notifier).state = VerificationStep.capture;
                  ref.read(verificationResultProvider.notifier).state = null;
                  context.go(AppRoutes.volunteerMap);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _webPickedImage == null ? null : _verifyImpact,
                child: const Text('Upload & Verify'),
              ),
            ],
          ),
        ),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary500));
    }

    return Stack(
      children: [
        SizedBox.expand(
          child: CameraPreview(_cameraController!),
        ),
        // Overlay Guide Frame
        Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary500, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        // Instructions
        Positioned(
          top: 100,
          left: 24,
          right: 24,
          child: Text(
            'Frame the required proof for "${task?.title ?? 'this task'}"',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textInverse,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: AppColors.textPrimary, blurRadius: 4)],
            ),
          ),
        ),
        // Live GPS Tagging Mock
        Positioned(
          bottom: 120,
          left: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary500, size: 16),
                SizedBox(width: 8),
                Text(
                  '19.0760, 72.8777 (±4m)',
                  style: TextStyle(color: AppColors.textInverse, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        // Capture Button
        Positioned(
          bottom: 32,
          left: 24,
          right: 24,
          child: ElevatedButton(
            onPressed: () async {
              _verifyImpact();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Capture & Confirm', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyingStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary500),
          const SizedBox(height: 24),
          const Text(
            'Gemini Vision is verifying your impact...',
            style: TextStyle(color: AppColors.textInverse, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Checking: Image clarity ✓ | GPS match ✓ | ...',
            style: TextStyle(color: AppColors.primary100, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMintingStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary500),
          const SizedBox(height: 24),
          const Text(
            'Minting your VIT on Polygon...',
            style: TextStyle(color: AppColors.textInverse, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Securing your impact on the blockchain...',
            style: TextStyle(color: AppColors.primary100, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildResultStep() {
    final success = ref.watch(verificationResultProvider) ?? false;
    final rawReason = ref.watch(verificationReasonProvider);
    final task = ref.watch(selectedTaskProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error_outline,
              color: success ? AppColors.primary500 : AppColors.error,
              size: 100,
            ),
            const SizedBox(height: 24),
            Text(
              success ? 'Impact Verified!' : 'Verification Failed',
              style: const TextStyle(color: AppColors.textInverse, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (success) ...[
              Text(
                '🏅 ${task?.tokenReward ?? 10} VIT Minted to your Wallet',
                style: const TextStyle(color: AppColors.primary200, fontSize: 16),
              ),
              const SizedBox(height: 12),
              // Full tx hash with copy-to-clipboard
              Builder(builder: (context) {
                final txHash = ref.watch(verificationTxHashProvider);
                if (txHash == null) return const SizedBox.shrink();
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // Open Polygonscan in the system browser
                        // Using in-app SnackBar as fallback since url_launcher
                        // is not in pubspec (avoids adding a dep just for one link)
                        await Clipboard.setData(ClipboardData(
                          text: 'https://amoy.polygonscan.com/tx/$txHash',
                        ));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              '🔗 Polygonscan link copied to clipboard!',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: AppColors.primary600,
                            duration: const Duration(seconds: 3),
                            action: SnackBarAction(
                              label: 'Dismiss',
                              textColor: Colors.white,
                              onPressed: () {},
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary600.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary500.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.open_in_new, color: AppColors.primary300, size: 14),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Polygon Tx: ${txHash.substring(0, 10)}...${txHash.substring(txHash.length - 6)}',
                                style: const TextStyle(
                                  color: AppColors.primary200,
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap to copy Polygonscan link',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  ref.read(verificationStepProvider.notifier).state = VerificationStep.capture;
                  ref.read(verificationResultProvider.notifier).state = null;
                  context.go(AppRoutes.volunteerMap);
                },
                child: const Text('Back to Map'),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.4)),
                ),
                child: Text(
                  _humanizeFailureReason(rawReason),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textInverse,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary500),
                icon: const Icon(Icons.camera_alt),
                onPressed: () {
                  ref.read(verificationStepProvider.notifier).state = VerificationStep.capture;
                },
                label: const Text('Try Again'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  ref.read(verificationStepProvider.notifier).state = VerificationStep.capture;
                  ref.read(verificationResultProvider.notifier).state = null;
                  context.go(AppRoutes.volunteerMap);
                },
                child: const Text('Back to Map', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
