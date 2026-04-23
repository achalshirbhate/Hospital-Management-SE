import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/report_service.dart';
import '../../../models/report_model.dart';
import '../../../utils/helpers.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_overlay.dart';

class PatientReportsTab extends StatefulWidget {
  final int patientId;
  const PatientReportsTab({super.key, required this.patientId});

  @override
  State<PatientReportsTab> createState() => _PatientReportsTabState();
}

class _PatientReportsTabState extends State<PatientReportsTab> {
  final _service = ReportService();
  List<ReportModel> _reports = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _reports = await _service.getReports(widget.patientId);
    } catch (e) {
      if (mounted) showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openReport(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) showError(context, 'Cannot open this URL');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: LoadingOverlay(
        isLoading: _loading,
        child: RefreshIndicator(
          onRefresh: _load,
          child: _reports.isEmpty && !_loading
              ? const EmptyState(
                  message: 'No reports uploaded yet.',
                  icon: Icons.folder_open_outlined)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reports.length,
                  itemBuilder: (_, i) => _ReportCard(
                    report: _reports[i],
                    onOpen: () => _openReport(_reports[i].fileUrl),
                  ),
                ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onOpen;
  const _ReportCard({required this.report, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final isPdf = report.reportType.toUpperCase() == 'PDF';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              (isPdf ? Colors.red : Colors.green).withOpacity(0.15),
          child: Icon(
            isPdf ? Icons.picture_as_pdf : Icons.table_chart,
            color: isPdf ? Colors.red : Colors.green,
          ),
        ),
        title: Text(report.reportName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By Dr. ${report.doctorName}',
                style: const TextStyle(fontSize: 12)),
            Text(formatDate(report.uploadedAt),
                style: const TextStyle(fontSize: 11)),
            if (report.notes != null && report.notes!.isNotEmpty)
              Text(report.notes!,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new, color: AppTheme.primary),
          onPressed: onOpen,
        ),
        isThreeLine: true,
      ),
    );
  }
}
