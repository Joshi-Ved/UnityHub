import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:unityhub_mobile/core/router/app_routes.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';
import 'package:unityhub_mobile/core/responsive/layout_builder.dart';
import 'package:unityhub_mobile/features/map/map_view_model.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unityhub_mobile/core/config/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unityhub_mobile/features/map/task_tray.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(19.0760, 72.8777), // Mumbai Center
    zoom: 12.0,
  );

  Timer? _pingTimer;

  @override
  void initState() {
    super.initState();
    _startLocationPinging();
  }

  void _startLocationPinging() {
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        final token = await FirebaseAuth.instance.currentUser?.getIdToken();
        await http.post(
          Uri.parse('${AppConstants.apiBaseUrl}/api/volunteers/ping'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'lat': _initialPosition.target.latitude,
            'lng': _initialPosition.target.longitude,
          }),
        );
      } catch (_) {
        // Ignore silently for demo
      }
    });
  }

  @override
  void dispose() {
    _pingTimer?.cancel();
    super.dispose();
  }

  BitmapDescriptor _getMarkerIcon(String status) {
    // In a real app, load custom SVGs or asset images here
    // based on color specs: Emerald (available), Amber (in-progress), Gray (completed)
    switch (status) {
      case 'available':
        return BitmapDescriptor.defaultMarkerWithHue(150.0); // Approx Emerald
      case 'in-progress':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange); // Approx Amber
      case 'completed':
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure); // Generic Gray fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(mapTasksProvider);
    final selectedTask = ref.watch(selectedTaskProvider);

    Set<Marker> markers = tasks.map((task) {
      return Marker(
        markerId: MarkerId(task.id),
        position: task.location,
        icon: _getMarkerIcon(task.status),
        onTap: () {
          ref.read(selectedTaskProvider.notifier).state = task;
        },
      );
    }).toSet();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;
        final trayHeight = isDesktop ? 0.3 : 0.4;

        return Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _initialPosition,
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                tiltGesturesEnabled: !kIsWeb,
                onMapCreated: (_) {},
                onTap: (_) {
                  if (selectedTask != null) {
                    ref.read(selectedTaskProvider.notifier).state = null;
                  }
                },
              ),
              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(color: AppColors.neutral200, blurRadius: 8),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: AppColors.textSecondary),
                            SizedBox(width: 12),
                            Text('Search nearby tasks...', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppColors.neutral200, blurRadius: 8),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.account_balance_wallet, color: AppColors.primary500),
                        onPressed: () => context.go(AppRoutes.volunteerWallet),
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedTask != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: TaskTray(heightFactor: trayHeight),
                ),
            ],
          ),
        );
      },
    );
  }
}
