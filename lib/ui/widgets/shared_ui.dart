import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../design_system.dart';
import 'animated_tap_scale.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            ...children,
          ],
        ),
      ),
    );
  }
}

class Field extends StatelessWidget {
  const Field({
    super.key,
    required this.label,
    required this.controller,
    this.keyName,
  });

  final String label;
  final TextEditingController controller;
  final String? keyName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.formFieldGap,
      child: TextField(
        key: keyName == null ? null : ValueKey<String>(keyName!),
        controller: controller,
        style: AppTextStyles.support.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class MultilineField extends StatelessWidget {
  const MultilineField({
    super.key,
    required this.label,
    required this.controller,
    this.minLines = 3,
    this.maxLines = 6,
  });

  final String label;
  final TextEditingController controller;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      style: AppTextStyles.support.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(labelText: label, alignLabelWithHint: true),
    );
  }
}

class EmptyCard extends StatelessWidget {
  const EmptyCard({super.key, required this.text, this.noSideBorders = false});

  final String text;
  final bool noSideBorders;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = _emptyCardContent(theme);

    return Container(
      // ui-drift-ok: intentional use of BoxDecoration in this screen style context.
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: AppBorders.horizontalWithSides(sideBorders: !noSideBorders),
      ),
      child: content,
    );
  }

  Widget _emptyCardContent(ThemeData theme) {
    return Padding(
      padding: AppSpacing.card,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            size: AppSizes.infoIcon,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyLarge.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class StatBadge extends StatelessWidget {
  const StatBadge({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      // ui-drift-ok: intentional use of BoxDecoration in this screen style context.
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppBorders.radius,
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: AppSizes.subtleDivider,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSizes.badgeDot,
            height: AppSizes.badgeDot,
            color: color,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label $value',
            style: AppTextStyles.badge.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

enum LessonDisplayStatus { current, next, pending, open, closed, scheduled }

({String label, Color color}) resolveLessonStatus(LessonDisplayStatus status) {
  return switch (status) {
    LessonDisplayStatus.current => (label: 'Atual', color: AppColors.absent),
    LessonDisplayStatus.next => (label: 'Próxima', color: AppColors.open),
    LessonDisplayStatus.pending => (label: 'Pendente', color: AppColors.absent),
    LessonDisplayStatus.open => (label: 'Aberta', color: AppColors.open),
    LessonDisplayStatus.closed => (label: 'Fechada', color: AppColors.present),
    LessonDisplayStatus.scheduled => (
      label: 'Agendada',
      color: AppColors.scheduled,
    ),
  };
}

class LessonInfoRow extends StatelessWidget {
  const LessonInfoRow({
    super.key,
    required this.statusLabel,
    required this.statusColor,
    required this.title,
    required this.time,
  });

  final String statusLabel;
  final Color statusColor;
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 20,
          child: Text(
            statusLabel.toUpperCase(),
            style: AppTextStyles.rowKicker.copyWith(color: statusColor),
          ),
        ),
        Expanded(
          flex: 50,
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Text(
              title,
              style: AppTextStyles.rowTitle.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Expanded(
          flex: 30,
          child: Text(
            time,
            textAlign: TextAlign.right,
            style: AppTextStyles.rowMeta.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}

typedef AttendanceStatusStyle = ({
  Color accentColor,
  Color borderColor,
  String label,
});

AttendanceStatusStyle resolveAttendanceStatusStyle(AttendanceStatus status) {
  return switch (status) {
    AttendanceStatus.present => (
      accentColor: AppColors.present,
      borderColor: AppColors.present.withValues(alpha: 0.4),
      label: 'Presente',
    ),
    AttendanceStatus.absent => (
      accentColor: AppColors.absent,
      borderColor: AppColors.absent.withValues(alpha: 0.4),
      label: 'Ausente',
    ),
    AttendanceStatus.late => (
      accentColor: AppColors.lateColor,
      borderColor: AppColors.lateColor.withValues(alpha: 0.4),
      label: 'Atraso',
    ),
    AttendanceStatus.justified => (
      accentColor: AppColors.justified,
      borderColor: AppColors.justified.withValues(alpha: 0.4),
      label: 'Justificado',
    ),
  };
}

bool matchesAttendanceFilter(AttendanceStatus status, String filter) {
  return switch (filter) {
    'Todos' => true,
    'Presentes' => status == AttendanceStatus.present,
    'Ausentes' => status == AttendanceStatus.absent,
    'Atrasos' => status == AttendanceStatus.late,
    'Justificados' => status == AttendanceStatus.justified,
    _ => true,
  };
}

String lessonTime(LessonOccurrence lesson) {
  return '${clock(lesson.weeklyClass.startMinutes)} - ${clock(lesson.weeklyClass.endMinutes)}';
}

String clock(int minutes) {
  final hour = (minutes ~/ 60).toString().padLeft(2, '0');
  final minute = (minutes % 60).toString().padLeft(2, '0');
  return '$hour:$minute';
}

int parseClock(String value) {
  final parts = value.split(':');
  if (parts.length != 2) {
    return 0;
  }
  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = int.tryParse(parts[1]) ?? 0;
  return (hour.clamp(0, 23) * 60 + minute.clamp(0, 59)).toInt();
}

String weekdayLabel(int weekday) {
  return switch (weekday) {
    1 => 'Segunda',
    2 => 'Terça',
    3 => 'Quarta',
    4 => 'Quinta',
    5 => 'Sexta',
    6 => 'Sábado',
    _ => 'Domingo',
  };
}

DateTime? parseDate(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  return DateTime.tryParse(trimmed);
}

String dateText(DateTime? date) {
  if (date == null) {
    return '';
  }
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
  });

  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      // ui-drift-ok: intentional use of BoxDecoration in this screen style context.
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: AppBorders.horizontal,
      ),
      child: TextField(
        style: AppTextStyles.titleLarge.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          hintText: hintText,
          hintStyle: AppTextStyles.titleLarge.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          contentPadding: AppSpacing.row,
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class AppFilterRow extends StatelessWidget {
  const AppFilterRow({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onSelected,
    this.filterColors,
  });

  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onSelected;
  final Map<String, Color>? filterColors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final entry in filters.indexed)
          Expanded(
            child: AnimatedTapScale(
              onTap: () => onSelected(entry.$2),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.gutter,
                ),
                // ui-drift-ok: intentional use of BoxDecoration in this screen style context.
                decoration: BoxDecoration(
                  color: selectedFilter == entry.$2
                      ? _colorFor(context, entry.$2)
                      : Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: selectedFilter == entry.$2
                          ? _colorFor(context, entry.$2)
                          : AppColors.slate950,
                      width: AppSizes.divider,
                    ),
                    bottom: BorderSide(
                      color: selectedFilter == entry.$2
                          ? _colorFor(context, entry.$2)
                          : AppColors.slate950,
                      width: AppSizes.divider,
                    ),
                  ),
                ),
                child: Text(
                  entry.$2.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.badge.copyWith(
                    color: selectedFilter == entry.$2
                        ? AppColors.white
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _colorFor(BuildContext context, String filter) {
    return filterColors?[filter] ?? Theme.of(context).colorScheme.primary;
  }
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.height = AppSizes.buttonHeight,
    this.fontSize,
    this.icon,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final double height;
  final double? fontSize;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? Theme.of(context).colorScheme.primary;
    final effectiveColor = onPressed == null
        ? baseColor.withValues(alpha: 0.4)
        : baseColor;

    // Gradiente sutil que escurece a cor base para dar o tom plano e mais escuro
    final gradient = LinearGradient(
      colors: [
        Color.alphaBlend(
          AppColors.black.withValues(alpha: 0.08),
          effectiveColor,
        ),
        Color.alphaBlend(
          AppColors.black.withValues(alpha: 0.24),
          effectiveColor,
        ),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final effectiveFontSize =
        fontSize ??
        (height >= AppSizes.actionHeight
            ? 18.0
            : AppTextStyles.titleMedium.fontSize!);

    return AnimatedTapScale(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: height,
        // ui-drift-ok: intentional use of BoxDecoration in this screen style context.
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: AppBorders.radius,
        ),
        child: Container(
          alignment: Alignment.center,
          padding: AppSpacing.actionHorizontal,
          child: icon == null
              ? Text(
                  text,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.action.copyWith(
                    fontSize: effectiveFontSize,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: AppColors.white, size: AppSizes.icon),
                    const SizedBox(width: AppSpacing.md),
                    Flexible(
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.action.copyWith(
                          fontSize: effectiveFontSize,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class HoldToConfirmButton extends StatefulWidget {
  const HoldToConfirmButton({
    super.key,
    required this.text,
    required this.onConfirmed,
    required this.baseColor,
    required this.fillColor,
    this.height = AppSizes.buttonHeight,
    this.duration = const Duration(milliseconds: 1500),
  });

  final String text;
  final VoidCallback onConfirmed;
  final Color baseColor;
  final Color fillColor;
  final double height;
  final Duration duration;

  @override
  State<HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<HoldToConfirmButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onConfirmed();
        _controller.reset();
        setState(() {
          _isHolding = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startHolding() {
    setState(() {
      _isHolding = true;
    });
    _controller.forward();
  }

  void _stopHolding() {
    setState(() {
      _isHolding = false;
    });
    if (_controller.status != AnimationStatus.completed) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseGradient = LinearGradient(
      colors: [
        Color.alphaBlend(
          AppColors.black.withValues(alpha: 0.08),
          widget.baseColor,
        ),
        Color.alphaBlend(
          AppColors.black.withValues(alpha: 0.24),
          widget.baseColor,
        ),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final fillGradient = LinearGradient(
      colors: [
        Color.alphaBlend(
          AppColors.black.withValues(alpha: 0.08),
          widget.fillColor,
        ),
        Color.alphaBlend(
          AppColors.black.withValues(alpha: 0.24),
          widget.fillColor,
        ),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return GestureDetector(
      onTapDown: (_) => _startHolding(),
      onTapUp: (_) => _stopHolding(),
      onTapCancel: () => _stopHolding(),
      child: AnimatedScale(
        scale: _isHolding ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: widget.height,
          // ui-drift-ok: intentional use of BoxDecoration in this screen style context.
          decoration: BoxDecoration(
            gradient: baseGradient,
            borderRadius: AppBorders.radius,
          ),
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: _controller.value,
                      heightFactor: 1.0,
                      child: Container(
                        // ui-drift-ok: intentional use of BoxDecoration in this screen style context.
                        decoration: BoxDecoration(gradient: fillGradient),
                      ),
                    ),
                  );
                },
              ),
              Center(
                child: Padding(
                  padding: AppSpacing.actionHorizontal,
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.action.copyWith(
                      fontSize: widget.height >= AppSizes.actionHeight
                          ? 18.0
                          : AppTextStyles.titleMedium.fontSize!,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: AppSizes.actionHeight, child: child);
  }
}

class BottomSplitActionBar extends StatelessWidget {
  const BottomSplitActionBar({
    super.key,
    required this.left,
    required this.right,
  });

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return BottomActionBar(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 50, child: left),
          const ActionDivider(),
          Expanded(flex: 50, child: right),
        ],
      ),
    );
  }
}

class ActionDivider extends StatelessWidget {
  const ActionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: AppSizes.divider, color: AppColors.slate950);
  }
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = AppSizes.iconButton,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedTapScale(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(AppSpacing.md),
        // ui-drift-ok: intentional use of BoxDecoration in this screen style context.
        decoration: const BoxDecoration(border: AppBorders.strong),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          size: AppSizes.icon,
        ),
      ),
    );
  }
}

void showAppSnackBar(BuildContext context, String message) {
  if (!context.mounted) {
    return;
  }

  final theme = Theme.of(context);
  final messenger = ScaffoldMessenger.of(context);
  messenger.removeCurrentSnackBar();

  messenger.showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: AppTextStyles.rowMeta.copyWith(
          color: theme.colorScheme.onInverseSurface,
        ),
      ),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      backgroundColor: theme.colorScheme.inverseSurface,
    ),
  );
}
