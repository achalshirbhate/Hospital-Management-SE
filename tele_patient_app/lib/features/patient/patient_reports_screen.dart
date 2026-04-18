import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/report_model.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/app_button.dart';
import '../shared/upload_report_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientReportsScreen extends StatefulWidget {
  final int patientId;
  const PatientReportsScreen({super.key, required this.patientId});
  @override
  State<PatientReportsScreen> createState() => _PatientReportsScreenState();
}

class _PatientReportsScreenState extends State<PatientReportsScreen> {
  List<ReportModel> _reports = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await ApiService.getReports(widget.patientId);
      setState(() {
        _reports = data.map((e) => ReportModel.fromJson(e)).toList();
        _loading = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UploadReportScreen(patientId: widget.patientId),
                ),
              );
              if (result == true) _load();
            },
            tooltip: 'Upload Report',
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.folder_open, size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    const Text('No reports found', style: TextStyle(color: AppColors.textMuted)),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Upload First Report',
                      icon: Icons.upload_file,
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UploadReportScreen(patientId: widget.patientId),
                          ),
                        );
                        if (result == true) _load();
                      },
                      width: 200,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _reports.length,
                itemBuilder: (_, i) => _ReportCard(report: _reports[i], onRefresh: _load)),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onRefresh;
  const _ReportCard({required this.report, required this.onRefresh});

  IconData get _icon => report.reportType == 'PDF'
      ? Icons.picture_as_pdf
      : report.reportType == 'IMAGE'
        ? Icons.image
        : Icons.description;

  Color get _color => report.reportType == 'PDF'
      ? AppColors.danger
      : report.reportType == 'IMAGE'
        ? AppColors.cyan
        : AppColors.textMuted;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(_icon, color: _color, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(report.reportName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              Text('Dr. ${report.doctorName}  ·  ${report.uploadedAt.day}/${report.uploadedAt.month}/${report.uploadedAt.year}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ])),
            Chip(label: Text(report.reportType, style: const TextStyle(fontSize: 11)),
              backgroundColor: AppColors.primaryLight,
              labelStyle: const TextStyle(color: AppColors.primary)),
          ]),
          if (report.notes != null && report.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(report.notes!, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ],
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: AppButton(
              label: 'View',
              icon: Icons.open_in_new,
              onPressed: () async {
                final uri = Uri.tryParse(report.fileUrl);
                if (uri != null && await canLaunchUrl(uri)) launchUrl(uri);
              },
            )),
            const SizedBox(width: 10),
            Expanded(child: AppButton(
              label: 'Send to Chat',
              icon: Icons.send,
              outline: true,
              onPressed: () => _showSendToChatDialog(context),
            )),
          ]),
        ],
      )),
    );
  }

  void _showSendToChatDialog(BuildContext context) {
    // TODO: Get active chat sessions for this patient
    // For now, show a simple dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send to Chat'),
        content: const Text(
          'This feature will send the report to an active chat session.\n\n'
          'Note: You need an active consultation session to send reports.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
