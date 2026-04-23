import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/md_service.dart';
import '../../../utils/helpers.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/loading_overlay.dart';

class MdFinanceTab extends StatefulWidget {
  final int mdId;
  const MdFinanceTab({super.key, required this.mdId});

  @override
  State<MdFinanceTab> createState() => _MdFinanceTabState();
}

class _MdFinanceTabState extends State<MdFinanceTab> {
  final _service    = MdService();
  final _amountCtrl = TextEditingController();
  final _descCtrl   = TextEditingController();
  String _type      = 'REVENUE';
  bool _loading     = false;

  @override
  void dispose() {
    _amountCtrl.dispose(); _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _addRecord() async {
    if (_amountCtrl.text.isEmpty || _descCtrl.text.isEmpty) {
      showError(context, 'Fill all fields'); return;
    }
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null) {
      showError(context, 'Invalid amount'); return;
    }
    setState(() => _loading = true);
    try {
      await _service.addFinancialRecord(
          type: _type, amount: amount, description: _descCtrl.text);
      if (mounted) {
        showSuccess(context, 'Record saved!');
        _amountCtrl.clear(); _descCtrl.clear();
      }
    } catch (e) {
      if (mounted) showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) showError(context, 'Cannot open URL');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finance & Reports')),
      body: LoadingOverlay(
        isLoading: _loading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Add Record ────────────────────────────────────────────────
              const Text('Add Financial Record',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                    labelText: 'Type',
                    prefixIcon: Icon(Icons.category_outlined)),
                items: ['REVENUE', 'EXPENDITURE']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.attach_money)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description_outlined)),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _addRecord,
                icon: const Icon(Icons.save),
                label: const Text('Save Record'),
              ),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),

              // ── Download Reports ──────────────────────────────────────────
              const Text('Download Reports',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              _ReportSection(
                title: 'Revenue Report',
                color: AppTheme.success,
                icon: Icons.trending_up,
                onExcel: () => _openUrl(_service.revenueExcelUrl()),
                onPdf: () => _openUrl(_service.revenuePdfUrl()),
              ),
              const SizedBox(height: 12),
              _ReportSection(
                title: 'Expense Report',
                color: AppTheme.error,
                icon: Icons.trending_down,
                onExcel: () => _openUrl(_service.expenseExcelUrl()),
                onPdf: () => _openUrl(_service.expensePdfUrl()),
              ),
              const SizedBox(height: 12),
              _ReportSection(
                title: 'Doctor Stats',
                color: AppTheme.accent,
                icon: Icons.medical_services,
                onExcel: () => _openUrl(_service.doctorExcelUrl()),
                onPdf: () => _openUrl(_service.doctorPdfUrl()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportSection extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final VoidCallback onExcel;
  final VoidCallback onPdf;
  const _ReportSection({
    required this.title,
    required this.color,
    required this.icon,
    required this.onExcel,
    required this.onPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          OutlinedButton.icon(
            onPressed: onExcel,
            icon: const Icon(Icons.table_chart, size: 16),
            label: const Text('Excel'),
            style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6)),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onPdf,
            icon: const Icon(Icons.picture_as_pdf, size: 16),
            label: const Text('PDF'),
            style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6)),
          ),
        ]),
      ),
    );
  }
}
