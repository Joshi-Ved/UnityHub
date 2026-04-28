import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:unityhub_mobile/core/config/constants.dart';

class VolunteerTask {
  final String id;
  final String title;
  final String ngoName;
  final double distance;
  final List<String> skills;
  final int tokenReward;
  final LatLng location;
  final String status;

  VolunteerTask({
    required this.id,
    required this.title,
    required this.ngoName,
    required this.distance,
    required this.skills,
    required this.tokenReward,
    required this.location,
    required this.status,
  });

  factory VolunteerTask.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final geo = data['location'] as GeoPoint?;
    return VolunteerTask(
      id: doc.id,
      title: data['title'] ?? '',
      ngoName: data['ngoName'] ?? '',
      distance: (data['distance'] ?? 0.0).toDouble(),
      skills: List<String>.from(data['skills'] ?? []),
      tokenReward: data['tokenReward'] ?? 0,
      location: geo != null ? LatLng(geo.latitude, geo.longitude) : const LatLng(0, 0),
      status: data['status'] ?? 'available',
    );
  }

  /// Constructs a task from the local mocks/tasks_nearby.json format.
  factory VolunteerTask.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>;
    return VolunteerTask(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      ngoName: json['ngo_name'] ?? '',
      distance: (json['distance_km'] ?? 0.0).toDouble(),
      skills: List<String>.from(json['skills'] ?? []),
      tokenReward: json['token_reward'] ?? 0,
      location: LatLng(
        (loc['lat'] as num).toDouble(),
        (loc['lng'] as num).toDouble(),
      ),
      status: json['status'] ?? 'available',
    );
  }

  /// Constructs a task from backend PostgreSQL API format.
  factory VolunteerTask.fromBackendJson(Map<String, dynamic> json) {
    return VolunteerTask(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      ngoName: json['ngo_name'] ?? 'Admin Created',
      distance: (json['distance_km'] ?? 0.0).toDouble(),
      skills: List<String>.from(json['skills'] ?? []),
      tokenReward: json['token_reward'] ?? 0,
      location: LatLng(
        (json['lat'] as num?)?.toDouble() ?? 0,
        (json['lng'] as num?)?.toDouble() ?? 0,
      ),
      status: json['status'] ?? 'available',
    );
  }
}

final mapTasksProvider = StateNotifierProvider<MapTasksNotifier, List<VolunteerTask>>((ref) {
  return MapTasksNotifier();
});

class MapTasksNotifier extends StateNotifier<List<VolunteerTask>> {
  StreamSubscription? _subscription;
  final _db = FirebaseFirestore.instance;

  MapTasksNotifier() : super([]) {
    listenToTasks();
  }

  void listenToTasks() {
    _subscription?.cancel();
    _subscription = _db
        .collection('tasks')
        .where('status', isEqualTo: 'available')
        .snapshots()
        .listen(
          (snapshot) {
            state = snapshot.docs.map((doc) => VolunteerTask.fromFirestore(doc)).toList();
          },
          onError: (e) {
            // Firestore not available (e.g. Firebase not configured for this build).
            // Fallback order: backend(PostgreSQL) -> local mock JSON.
            debugPrint('[MapTasksNotifier] Firestore error — trying backend: $e');
            _loadTasksFromBackend();
          },
        );
  }

  Future<void> _loadTasksFromBackend() async {
    try {
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/tasks?status=available');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as List<dynamic>;
        state = decoded
            .map((item) => VolunteerTask.fromBackendJson(item as Map<String, dynamic>))
            .toList();
        return;
      }
    } catch (_) {}
    // Backend unavailable -> keep demo resilient.
    _loadMockTasks();
  }

  Future<void> _loadMockTasks() async {
    try {
      final jsonStr = await rootBundle.loadString('packages/unityhub_mobile/mocks/tasks_nearby.json');
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final tasks = (decoded['tasks'] as List)
          .map((t) => VolunteerTask.fromJson(t as Map<String, dynamic>))
          .toList();
      state = tasks;
    } catch (e2) {
      // rootBundle path failed — try the assets path directly
      try {
        final jsonStr = await rootBundle.loadString('assets/mocks/tasks_nearby.json');
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        state = (decoded['tasks'] as List)
            .map((t) => VolunteerTask.fromJson(t as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // Absolute last resort: hardcoded fallback tasks so the map is never empty
        state = _hardcodedFallbackTasks();
      }
    }
  }

  List<VolunteerTask> _hardcodedFallbackTasks() {
    return [
      VolunteerTask(
        id: 'demo_t1',
        title: 'Beach Cleanup Drive',
        ngoName: 'Ocean Savers',
        distance: 2.5,
        skills: ['Physical Labor'],
        tokenReward: 15,
        location: const LatLng(19.0760, 72.8777),
        status: 'available',
      ),
      VolunteerTask(
        id: 'demo_t2',
        title: 'Tree Plantation',
        ngoName: 'Green Earth',
        distance: 5.0,
        skills: ['Gardening'],
        tokenReward: 20,
        location: const LatLng(19.0800, 72.8800),
        status: 'available',
      ),
      VolunteerTask(
        id: 'demo_t3',
        title: 'Food Kit Distribution',
        ngoName: 'Helping Hands NGO',
        distance: 1.2,
        skills: ['Logistics'],
        tokenReward: 25,
        location: const LatLng(19.0720, 72.8750),
        status: 'available',
      ),
    ];
  }

  /// Adds a task locally (e.g. created via the admin panel).
  /// In production, this would POST to /api/tasks/create and Firestore would
  /// update the stream, automatically propagating to the UI.
  Future<void> addLocalTask({
    required String title,
    required String description,
    required int reward,
    required String criteria,
  }) async {
    // Source-of-truth write to backend PostgreSQL.
    try {
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/tasks');
      final body = jsonEncode({
        'title': title,
        'description': description,
        'token_reward': reward,
        'verification_criteria': criteria,
        'skills': <String>[],
        'lat': 19.0760,
        'lng': 72.8777,
      });
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _loadTasksFromBackend();
        return;
      }
    } catch (_) {}

    // If backend unavailable, keep the app usable with local optimistic insert.
    final newTask = VolunteerTask(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      ngoName: 'Admin Created',
      distance: 0.0,
      skills: [],
      tokenReward: reward,
      location: const LatLng(19.0760, 72.8777), // Default to Mumbai center
      status: 'available',
    );
    state = [...state, newTask];
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final selectedTaskProvider = StateProvider<VolunteerTask?>((ref) => null);
