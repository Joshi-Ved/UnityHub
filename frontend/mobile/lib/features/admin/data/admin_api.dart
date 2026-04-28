import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:unityhub_mobile/core/config/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminApi {
  Future<Map<String, String>> _getHeaders() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> fetchDashboard({String orgId = 'demo-org', String range = '30d'}) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/api/analytics/dashboard')
        .replace(queryParameters: {'org_id': orgId, 'range': range});
    final response = await http.get(uri, headers: await _getHeaders());
    return _parseJson(response);
  }

  Future<Map<String, dynamic>> fetchActivity({String orgId = 'demo-org'}) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/api/analytics/activity')
        .replace(queryParameters: {'org_id': orgId});
    final response = await http.get(uri, headers: await _getHeaders());
    return _parseJson(response);
  }

  Future<List<Map<String, dynamic>>> fetchTasks({String orgId = 'demo-org'}) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/api/tasks')
        .replace(queryParameters: {'org_id': orgId});
    final response = await http.get(uri, headers: await _getHeaders());
    final body = _parseJson(response);
    return _asMapList(body['tasks']);
  }

  Future<void> createTask({
    required String title,
    required String description,
    required int tokenReward,
    required String verificationCriteria,
  }) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/api/tasks/create');
    final response = await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode({
        'title': title,
        'description': description,
        'token_reward': tokenReward,
        'verification_criteria': verificationCriteria,
      }),
    );
    _parseJson(response);
  }

  Future<List<String>> fetchTaskLogs(String taskId) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/api/tasks/$taskId/logs');
    final response = await http.get(uri, headers: await _getHeaders());
    final body = _parseJson(response);
    final logs = body['logs'];
    if (logs is List) {
      return logs.map((log) => '$log').toList();
    }
    return const [];
  }

  Future<Map<String, dynamic>> exportReport({
    required String orgId,
    required String fromDate,
    required String toDate,
  }) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/api/reports/export').replace(
      queryParameters: {
        'org_id': orgId,
        'from_date': fromDate,
        'to_date': toDate,
      },
    );

    final response = await http.get(uri, headers: await _getHeaders());
    return _parseJson(response);
  }

  Map<String, dynamic> _parseJson(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API error ${response.statusCode}: ${response.body}');
    }

    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      return body;
    }
    throw Exception('Unexpected API response format');
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is List) {
      return value.whereType<Map>().map((entry) => Map<String, dynamic>.from(entry)).toList();
    }
    return const [];
  }
}
