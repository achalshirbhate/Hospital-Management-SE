import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_theme.dart';

// ─── Date / time helpers ──────────────────────────────────────────────────────
String formatDate(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  try {
    final dt = DateTime.parse(iso);
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  } catch (_) {
    return iso;
  }
}

String formatDateOnly(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  try {
    final dt = DateTime.parse(iso);
    return DateFormat('dd MMM yyyy').format(dt);
  } catch (_) {
    return iso;
  }
}

// ─── Snackbar helpers ─────────────────────────────────────────────────────────
void showSuccess(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: AppTheme.success,
    behavior: SnackBarBehavior.floating,
  ));
}

void showError(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: AppTheme.error,
    behavior: SnackBarBehavior.floating,
  ));
}

// ─── Token status colour ──────────────────────────────────────────────────────
Color tokenStatusColor(String status) {
  switch (status) {
    case 'APPROVED':  return AppTheme.success;
    case 'REJECTED':  return AppTheme.error;
    case 'COMPLETED': return Colors.grey;
    default:          return AppTheme.warning; // REQUESTED
  }
}

// ─── Emergency level colour ───────────────────────────────────────────────────
Color emergencyColor(String level) {
  switch (level) {
    case 'CRITICAL': return AppTheme.critical;
    case 'URGENT':   return AppTheme.urgent;
    default:         return AppTheme.normal;
  }
}

// ─── Currency formatter ───────────────────────────────────────────────────────
String formatCurrency(double amount) =>
    NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
