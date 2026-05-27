import 'dart:convert';
import 'package:flutter/material.dart';
import '../../domain/models.dart';
import '../design_system/app_colors.dart';

class StudentAvatar extends StatelessWidget {
  const StudentAvatar({super.key, required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final photo = student.photoBase64;
    final colors = [
      AppColors.indigo,
      AppColors.present,
      AppColors.lateColor,
      AppColors.justified,
      AppColors.pink,
      AppColors.cyan,
    ];
    final colorIndex = student.name.hashCode % colors.length;
    final color = colors[colorIndex.abs()];

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: photo == null ? color.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
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
      ),
    );
  }
}
