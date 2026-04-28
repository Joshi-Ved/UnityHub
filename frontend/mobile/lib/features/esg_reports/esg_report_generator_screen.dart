import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';

class ESGReportGeneratorScreen extends StatefulWidget {
  const ESGReportGeneratorScreen({super.key});

  @override
  State<ESGReportGeneratorScreen> createState() => _ESGReportGeneratorScreenState();
}

class _ESGReportGeneratorScreenState extends State<ESGReportGeneratorScreen> {
  DateTimeRange? _range;
  String _org = 'UnityHub Foundation';
  XFile? _logo;
  final _sections = <String, bool>{
    'Executive Summary': true,
    'Task Breakdown by Category': true,
    'Volunteer Demographics': true,
    'Immutable Proof (Blockchain Hashes)': true,
    'AI Verification Accuracy': true,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = _range == null
        ? 'Select date range'
        : '${DateFormat('dd MMM yyyy').format(_range!.start)} - ${DateFormat('dd MMM yyyy').format(_range!.end)}';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 960;
        final controls = Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Report Controls', style: theme.textTheme.headlineLarge),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _org,
                    items: const [
                      DropdownMenuItem(value: 'UnityHub Foundation', child: Text('UnityHub Foundation')),
                      DropdownMenuItem(value: 'Helping Hands NGO', child: Text('Helping Hands NGO')),
                    ],
                    onChanged: (value) => setState(() => _org = value ?? _org),
                    decoration: const InputDecoration(labelText: 'Organization'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2024),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _range = picked);
                      }
                    },
                    icon: const Icon(Icons.date_range),
                    label: Text(dateLabel),
                  ),
                  const SizedBox(height: 12),
                  const Text('Report Sections', style: TextStyle(fontWeight: FontWeight.w700)),
                  ..._sections.entries.map(
                    (entry) => CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: entry.value,
                      title: Text(entry.key),
                      onChanged: (value) => setState(() => _sections[entry.key] = value ?? false),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final file = await picker.pickImage(source: ImageSource.gallery);
                      if (file != null) {
                        setState(() => _logo = file);
                      }
                    },
                    icon: const Icon(Icons.upload_file),
                    label: Text(_logo == null ? 'Upload Logo' : 'Logo selected'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      setState(() {}); // Refresh the preview
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Report generated for $_org • $dateLabel'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    child: const Text('Generate Report'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      if (_range == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Select a date range first to export report')),
                        );
                        return;
                      }
                      try {
                        // Build a minimal PDF text document using the printing package
                        final dateSuffix = _range == null
                            ? DateFormat('yyyyMMdd').format(DateTime.now())
                            : '${DateFormat('yyyyMMdd').format(_range!.start)}_${DateFormat('yyyyMMdd').format(_range!.end)}';
                        final filename = 'ESG_Report_${_org.replaceAll(' ', '_')}_$dateSuffix.pdf';

                        // Construct a simple text-based PDF bytes
                        // In production, use the `pdf` package to generate rich layout
                        final content = '''
UnityHub ESG Impact Report
Organisation: $_org
Period: $dateLabel
Total Verified Hours: 847
Active Volunteers: 128
Tasks Completed: 291
VIT Minted: 15,420
AI Verification Accuracy: 88%

Immutable Proof: All impact events are logged on Polygon Amoy blockchain.
Generated by UnityHub Verified Impact Protocol.
''';
                        final bytes = Uint8List.fromList(content.codeUnits);
                        await Printing.sharePdf(bytes: bytes, filename: filename);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('PDF export failed: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Download PDF'),
                  ),
              ],
            ),
          ),
        );

        if (isCompact) {
          return SingleChildScrollView(
            child: Column(
              children: [
                controls,
                const SizedBox(height: 12),
                _buildPreviewCard(dateLabel),
              ],
            ),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 360, child: controls),
            const SizedBox(width: 12),
            Expanded(child: _buildPreviewCard(dateLabel)),
          ],
        );
      },
    );
  }

  Widget _buildPreviewCard(String dateLabel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Live Report Preview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              const Text('847 Verified Hours of Social Impact', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
              Text('$dateLabel | Powered by Gemini AI + Polygon Blockchain', style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 18),
              const Text('Task Breakdown', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(value: 30, title: 'Food', color: AppColors.primary600),
                      PieChartSectionData(value: 25, title: 'Education', color: AppColors.primary500),
                      PieChartSectionData(value: 20, title: 'Environment', color: AppColors.primary400),
                      PieChartSectionData(value: 25, title: 'Health', color: AppColors.primary200),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Immutable Proof', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 760;
                  if (isCompact) {
                    return Column(
                      children: List.generate(3, (index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text('Task ${index + 1}'),
                            subtitle: Text(
                              'Volunteer ${index + 1} • ${DateFormat('dd MMM yyyy').format(DateTime.now().subtract(Duration(days: index)))}',
                            ),
                            trailing: const Text('0x1a2b...9f0e'),
                          ),
                        );
                      }),
                    );
                  }
                  return DataTable(
                    columns: const [
                      DataColumn(label: Text('Task')),
                      DataColumn(label: Text('Volunteer')),
                      DataColumn(label: Text('Timestamp')),
                      DataColumn(label: Text('Polygon Tx Hash')),
                      DataColumn(label: Text('Explorer Link')),
                    ],
                    rows: List.generate(3, (index) {
                      return DataRow(cells: [
                        DataCell(Text('Task ${index + 1}')),
                        DataCell(Text('Volunteer ${index + 1}')),
                        DataCell(Text(DateFormat('dd MMM yyyy').format(DateTime.now().subtract(Duration(days: index))))),
                        const DataCell(Text('0x1a2b...9f0e')),
                        DataCell(InkWell(onTap: () {}, child: const Text('View', style: TextStyle(color: AppColors.info)))),
                      ]);
                    }),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text('AI Verification Stats', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Approval Rate: 88%'),
              const SizedBox(height: 6),
              const Text('Gemini Accuracy note: 422 tasks auto-approved, 57 flagged for human review.'),
            ],
          ),
        ),
      ),
    );
  }
}
