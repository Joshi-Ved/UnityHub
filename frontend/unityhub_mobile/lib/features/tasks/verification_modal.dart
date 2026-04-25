import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:lottie/lottie.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';
import 'package:unityhub_mobile/features/map/map_view_model.dart';
import 'package:go_router/go_router.dart';

// State Enum
enum VerificationStep { capture, verifying, result }

final verificationStepProvider = StateProvider<VerificationStep>((ref) => VerificationStep.capture);
final verificationResultProvider = StateProvider<bool?>((ref) => null);

class VerificationModal extends ConsumerStatefulWidget {
  const VerificationModal({super.key});

  @override
  ConsumerState<VerificationModal> createState() => _VerificationModalState();
}

class _VerificationModalState extends ConsumerState<VerificationModal> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
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

  Future<void> _simulateVerification() async {
    ref.read(verificationStepProvider.notifier).state = VerificationStep.verifying;
    
    // Simulate AI API call
    await Future.delayed(const Duration(seconds: 4));
    
    // 80% chance of success for demo
    final success = DateTime.now().second % 5 != 0;
    ref.read(verificationResultProvider.notifier).state = success;
    ref.read(verificationStepProvider.notifier).state = VerificationStep.result;
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(verificationStepProvider);
    final task = ref.watch(selectedTaskProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Impact Verification', style: TextStyle(color: Colors.white)),
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
      case VerificationStep.result:
        return _buildResultStep();
    }
  }

  Widget _buildCaptureStep(VolunteerTask? task) {
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
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
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
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary500, size: 16),
                SizedBox(width: 8),
                Text(
                  '19.0760, 72.8777 (±4m)',
                  style: TextStyle(color: Colors.white, fontSize: 12),
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
              // await _cameraController!.takePicture();
              _simulateVerification();
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
          // Fallback if lottie is missing:
          const CircularProgressIndicator(color: AppColors.primary500),
          const SizedBox(height: 24),
          const Text(
            'Gemini Vision is verifying your impact...',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Checking: Image clarity ✓ | GPS match ✓ | ...',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildResultStep() {
    final success = ref.watch(verificationResultProvider) ?? false;
    final task = ref.watch(selectedTaskProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? AppColors.primary500 : AppColors.error,
              size: 100,
            ),
            const SizedBox(height: 24),
            Text(
              success ? 'Impact Verified!' : 'Verification Failed',
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (success) ...[
              Text(
                '🏅 ${task?.tokenReward ?? 10} VIT Minted to your Wallet',
                style: const TextStyle(color: AppColors.primary200, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Polygon Tx: 0x123...abc9',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Back to Map'),
              ),
            ] else ...[
              const Text(
                'Gemini Reason: Photo unclear — retake from 1m distance.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () {
                  ref.read(verificationStepProvider.notifier).state = VerificationStep.capture;
                },
                child: const Text('Retry Capture'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
