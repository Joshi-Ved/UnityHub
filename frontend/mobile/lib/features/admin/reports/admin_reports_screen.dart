import 'package:flutter/material.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';
import 'package:go_router/go_router.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  DateTimeRange? _selectedRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESG Report Generator'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/dashboard'),
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
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Download PDF Report', style: TextStyle(fontSize: 18)),
                onPressed: _selectedRange == null ? null : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Generating PDF via backend... Please wait.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
