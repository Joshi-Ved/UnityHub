import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  static const LatLng _initialPosition = LatLng(19.0760, 72.8777); // Mumbai Center
  
  // Mapbox Style URL (Standard / Streets)
  static const String _mapboxStyle = "mapbox/streets-v12";

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
            'lat': _initialPosition.latitude,
            'lng': _initialPosition.longitude,
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

  Color _getMarkerColor(String status) {
    switch (status) {
      case 'available':
        return AppColors.primary500; // Emerald
      case 'in-progress':
        return AppColors.warning; // Amber
      case 'completed':
        return AppColors.neutral500; // Gray
      default:
        return AppColors.primary500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(mapTasksProvider);
    final selectedTask = ref.watch(selectedTaskProvider);

    final markers = tasks.map((task) {
      return Marker(
        point: LatLng(task.location.latitude, task.location.longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            ref.read(selectedTaskProvider.notifier).state = task;
          },
          child: Container(
            decoration: BoxDecoration(
              color: _getMarkerColor(task.status).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: _getMarkerColor(task.status), width: 2),
            ),
            child: Icon(
              Icons.location_on,
              color: _getMarkerColor(task.status),
              size: 24,
            ),
          ),
        ),
      );
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;
        final trayHeight = isDesktop ? 0.3 : 0.4;

        return Scaffold(
          body: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: _initialPosition,
                  initialZoom: 12.0,
                  onTap: (_, __) {
                    if (selectedTask != null) {
                      ref.read(selectedTaskProvider.notifier).state = null;
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://api.mapbox.com/styles/v1/{id}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}",
                    additionalOptions: const {
                      'accessToken': AppConstants.mapboxToken,
                      'id': _mapboxStyle,
                    },
                    userAgentPackageName: 'com.unityhub.unityhub_mobile',
                  ),
                  MarkerLayer(markers: markers),
                ],
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
