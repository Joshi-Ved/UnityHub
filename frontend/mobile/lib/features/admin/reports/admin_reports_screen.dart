import 'package:flutter/material.dart';
import 'package:unityhub_mobile/core/router/app_routes.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';
import 'package:unityhub_mobile/features/admin/data/admin_api.dart';
import 'package:go_router/go_router.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  DateTimeRange? _selectedRange;
  bool _isGenerating = false;

  Future<void> _generateReport() async {
    if (_selectedRange == null || _isGenerating) return;

    setState(() {
      _isGenerating = true;
    });

    final fromDate = _selectedRange!.start.toIso8601String().split('T').first;
    final toDate = _selectedRange!.end.toIso8601String().split('T').first;

    try {
      final response = await AdminApi().exportReport(
        orgId: 'demo-org',
        fromDate: fromDate,
        toDate: toDate,
      );
      if (!mounted) return;

      final downloadUrl = response['download_url'] ?? 'Unavailable';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report ready: $downloadUrl')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report generation failed: $error')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESG Report Generator'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.adminDashboard),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.analytics, size: 80, color: AppColors.primary500),
              const SizedBox(height: 24),
              Text(
                'Generate Corporate ESG Report',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 16),
              const Text(
                'Generate immutable proof of impact backed by Polygon ledger. Includes total hours, AI verification accuracy, and transaction hashes.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 48),
              
              // Date Range Picker
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  side: const BorderSide(color: AppColors.primary500),
                ),
                icon: const Icon(Icons.date_range),
                label: Text(
                  _selectedRange == null 
                    ? 'Select Date Range' 
                    : '${_selectedRange!.start.toLocal().toString().split(' ')[0]} to ${_selectedRange!.end.toLocal().toString().split(' ')[0]}',
                ),
                onPressed: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2023),
                    lastDate: DateTime.now(),
                  );
                  if (range != null) {
                    setState(() {
                      _selectedRange = range;
                    });
                  }
                },
              ),
              
              const SizedBox(height: 24),
              
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: AppColors.primary600,
                ),
                icon: _isGenerating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.picture_as_pdf),
                label: Text(
                  _isGenerating ? 'Generating...' : 'Download PDF Report',
                  style: const TextStyle(fontSize: 18),
                ),
                onPressed: _selectedRange == null || _isGenerating ? null : _generateReport,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
