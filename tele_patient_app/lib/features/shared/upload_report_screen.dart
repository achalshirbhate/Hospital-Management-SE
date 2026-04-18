import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class UploadReportScreen extends StatefulWidget {
  final int patientId;

  const UploadReportScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<UploadReportScreen> createState() => _UploadReportScreenState();
}

class _UploadReportScreenState extends State<UploadReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _fileName;
  String? _fileBase64;
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Check file size (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size must be less than 5MB'),
                backgroundColor: AppColors.danger,
              ),
            );
          }
          return;
        }

        // Read file as base64
        if (file.bytes != null) {
          setState(() {
            _fileName = file.name;
            _fileBase64 = base64Encode(file.bytes!);
          });
        } else if (file.path != null) {
          final bytes = await File(file.path!).readAsBytes();
          setState(() {
            _fileName = file.name;
            _fileBase64 = base64Encode(bytes);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _uploadReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fileBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await ApiService.uploadReport({
        'patientId': widget.patientId,
        'title': _titleController.text.trim(),
        'notes': _notesController.text.trim(),
        'fileName': _fileName,
        'fileData': _fileBase64,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Report uploaded successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📤 Upload Report'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header card
                Card(
                  color: AppColors.primaryLight.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.upload_file,
                          size: 48,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Upload Medical Report',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Supported formats: PDF, JPG, PNG (Max 5MB)',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title field
                AppTextField(
                  controller: _titleController,
                  label: 'Report Title *',
                  hint: 'e.g., Blood Test Results',
                  prefixIcon: Icons.title,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Notes field
                AppTextField(
                  controller: _notesController,
                  label: 'Notes',
                  hint: 'Additional notes about this report...',
                  prefixIcon: Icons.notes,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // File picker
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _fileName != null ? AppColors.success : AppColors.border,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: _fileName != null
                        ? AppColors.success.withOpacity(0.05)
                        : AppColors.bgSecondary,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _fileName != null ? Icons.check_circle : Icons.cloud_upload,
                        size: 48,
                        color: _fileName != null ? AppColors.success : AppColors.textMuted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _fileName ?? 'No file selected',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _fileName != null ? FontWeight.w600 : FontWeight.w400,
                          color: _fileName != null ? AppColors.success : AppColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: _fileName != null ? 'Change File' : 'Select File',
                        onPressed: _pickFile,
                        outline: true,
                        icon: Icons.folder_open,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Info box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cyan.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.cyan, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Important:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '• Ensure the report is clear and readable\n'
                              '• File will be securely stored\n'
                              '• You can share this report in chat sessions',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Upload button
                AppButton(
                  label: 'Upload Report',
                  onPressed: _loading ? null : _uploadReport,
                  loading: _loading,
                  icon: Icons.upload,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
