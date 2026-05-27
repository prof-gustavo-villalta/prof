import 'package:flutter/material.dart';

/// Cores semânticas e de superfície usadas em todo o app.
///
/// Evita espalhar hex literais pelas telas e garante consistência visual.
abstract final class AppColors {
  // ─── Superfície e estrutura ───
  static const slate950 = Color(0xFF0F172A);
  static const slate900 = Color(0xFF1E293B);
  static const slate800 = Color(0xFF1E40AF);
  static const slate500 = Color(0xFF64748B);
  static const slate200 = Color(0xFFE2E8F0);
  static const white = Color(0xFFFFFFFF);

  // ─── Estados semânticos ───
  static const present = Color(0xFF10B981);
  static const absent = Color(0xFFEF4444);
  static const lateColor = Color(0xFFF59E0B);
  static const justified = Color(0xFF3B82F6);
  static const open = Color(0xFF2563EB);
  static const next = Color(0xFF2563EB);
  static const scheduled = Color(0xFF64748B);

  // ─── Ações ───
  static const primaryAction = Color(0xFF1E40AF);
  static const cancelBase = Color(0xFF2C1616);
  static const cancelFill = Color(0xFFB91C1C);

  // ─── Avatar ───
  static const indigo = Color(0xFF6366F1);
  static const pink = Color(0xFFEC4899);
  static const cyan = Color(0xFF06B6D4);
}
