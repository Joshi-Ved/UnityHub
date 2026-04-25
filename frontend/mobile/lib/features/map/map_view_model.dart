import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Dummy Task Model
class VolunteerTask {
  final String id;
  final String title;
  final String ngoName;
  final double distance;
  final List<String> skills;
  final int tokenReward;
  final LatLng location;
  final String status; // 'available', 'in-progress', 'completed'

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
}

// Dummy Tasks Provider
final mapTasksProvider = StateNotifierProvider<MapTasksNotifier, List<VolunteerTask>>((ref) {
  return MapTasksNotifier();
});

class MapTasksNotifier extends StateNotifier<List<VolunteerTask>> {
  MapTasksNotifier() : super([]) {
    _loadMockTasks();
  }

  void _loadMockTasks() {
    state = [
      VolunteerTask(
        id: '1',
        title: 'Beach Cleanup Drive',
        ngoName: 'Ocean Savers',
        distance: 2.5,
        skills: ['Physical Labor'],
        tokenReward: 15,
        location: const LatLng(19.0760, 72.8777), // Mumbai
        status: 'available',
      ),
      VolunteerTask(
        id: '2',
        title: 'Tree Plantation',
        ngoName: 'Green Earth',
        distance: 5.0,
        skills: ['Gardening'],
        tokenReward: 20,
        location: const LatLng(19.0800, 72.8800),
        status: 'in-progress',
      ),
    ];
  }

  // Placeholder for WebSocket updates
  void updateTaskStatus(String id, String newStatus) {
    state = state.map((task) {
      if (task.id == id) {
        return VolunteerTask(
          id: task.id,
          title: task.title,
          ngoName: task.ngoName,
          distance: task.distance,
          skills: task.skills,
          tokenReward: task.tokenReward,
          location: task.location,
          status: newStatus,
        );
      }
      return task;
    }).toList();
  }
}

// Selected Task Provider
final selectedTaskProvider = StateProvider<VolunteerTask?>((ref) => null);
