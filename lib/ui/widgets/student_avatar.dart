import 'dart:convert';
import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../design_system.dart';

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
          color: photo == null
              ? color.withValues(alpha: 0.12)
              : AppColors.transparent,
          border: Border.all(
            color: color.withValues(alpha: 0.35),
            width: AppSizes.subtleDivider,
          ),
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
                  style: AppTextStyles.badge.copyWith(
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
