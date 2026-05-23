import 'dart:convert';
import 'package:flutter/material.dart';
import '../../domain/models.dart';

class StudentAvatar extends StatelessWidget {
  const StudentAvatar({super.key, required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final photo = student.photoBase64;
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF3B82F6), // Royal Blue
      const Color(0xFFEC4899), // Pink
      const Color(0xFF06B6D4), // Cyan
    ];
    final colorIndex = student.name.hashCode % colors.length;
    final color = colors[colorIndex.abs()];

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: photo == null ? color.withOpacity(0.12) : Colors.transparent,
        border: Border.all(color: color.withOpacity(0.35), width: 1.5),
        image: photo == null
            ? null
            : DecorationImage(
                image: MemoryImage(base64Decode(photo)),
                fit: BoxFit.cover,
              ),
      ),
      child: photo == null
          ? Center(
              child: Text(
                student.initials,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            )
          : null,
    );
  }
}
