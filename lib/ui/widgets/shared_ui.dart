import 'package:flutter/material.dart';
import '../../domain/models.dart';
import 'animated_tap_scale.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class Field extends StatelessWidget {
  const Field({super.key, required this.label, required this.controller, this.keyName});

  final String label;
  final TextEditingController controller;
  final String? keyName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        key: keyName == null ? null : ValueKey<String>(keyName!),
        controller: controller,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
        ),
      ),
    );
  }
}

class EmptyCard extends StatelessWidget {
  const EmptyCard({super.key, required this.text, this.noSideBorders = false});

  final String text;
  final bool noSideBorders;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (noSideBorders) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          border: const Border(
            top: BorderSide(color: Color(0xFF0F172A), width: 2.0),
            bottom: BorderSide(color: Color(0xFF0F172A), width: 2.0),
          ),
        ),
        child: content,
      );
    }

    return Card(child: content);
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.zero,
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            '$label $value',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

enum LessonDisplayStatus { current, next, pending, open, closed, scheduled }

({String label, Color color}) resolveLessonStatus(LessonDisplayStatus status) {
  return switch (status) {
    LessonDisplayStatus.current => (label: 'Atual', color: const Color(0xFFEF4444)),
    LessonDisplayStatus.next => (label: 'Próxima', color: const Color(0xFF2563EB)),
    LessonDisplayStatus.pending => (label: 'Pendente', color: const Color(0xFFEF4444)),
    LessonDisplayStatus.open => (label: 'Aberta', color: const Color(0xFF2563EB)),
    LessonDisplayStatus.closed => (label: 'Fechada', color: const Color(0xFF10B981)),
    LessonDisplayStatus.scheduled => (label: 'Agendada', color: const Color(0xFF64748B)),
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
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          flex: 50,
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
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
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w700,
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
        accentColor: const Color(0xFF10B981),
        borderColor: const Color(0xFF10B981).withOpacity(0.4),
        label: 'Presente',
      ),
    AttendanceStatus.absent => (
        accentColor: const Color(0xFFEF4444),
        borderColor: const Color(0xFFEF4444).withOpacity(0.4),
        label: 'Ausente',
      ),
    AttendanceStatus.late => (
        accentColor: const Color(0xFFF59E0B),
        borderColor: const Color(0xFFF59E0B).withOpacity(0.4),
        label: 'Atrasado',
      ),
    AttendanceStatus.justified => (
        accentColor: const Color(0xFF3B82F6),
        borderColor: const Color(0xFF3B82F6).withOpacity(0.4),
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
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: const Border(
          top: BorderSide(color: Color(0xFF0F172A), width: 2.0),
          bottom: BorderSide(color: Color(0xFF0F172A), width: 2.0),
        ),
      ),
      child: TextField(
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: selectedFilter == entry.$2
                      ? _colorFor(context, entry.$2)
                      : Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: selectedFilter == entry.$2
                          ? _colorFor(context, entry.$2)
                          : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                    bottom: BorderSide(
                      color: selectedFilter == entry.$2
                          ? _colorFor(context, entry.$2)
                          : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                ),
                child: Text(
                  entry.$2.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5,
                    color: selectedFilter == entry.$2
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
    this.height = 54.0,
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
    final effectiveColor = onPressed == null ? baseColor.withOpacity(0.4) : baseColor;
    
    // Gradiente sutil que escurece a cor base para dar o tom plano e mais escuro
    final gradient = LinearGradient(
      colors: [
        Color.alphaBlend(Colors.black.withOpacity(0.08), effectiveColor),
        Color.alphaBlend(Colors.black.withOpacity(0.24), effectiveColor),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final effectiveFontSize = fontSize ?? (height >= 60 ? 18.0 : 15.0);

    return AnimatedTapScale(
      onTap: onPressed,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.zero,
        ),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: icon == null
              ? Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: effectiveFontSize,
                    letterSpacing: 0.5,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: effectiveFontSize,
                          letterSpacing: 0.5,
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

class HoldToConfirmButton extends StatefulWidget {
  const HoldToConfirmButton({
    super.key,
    required this.text,
    required this.onConfirmed,
    required this.baseColor,
    required this.fillColor,
    this.height = 54.0,
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
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

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
        Color.alphaBlend(Colors.black.withOpacity(0.08), widget.baseColor),
        Color.alphaBlend(Colors.black.withOpacity(0.24), widget.baseColor),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final fillGradient = LinearGradient(
      colors: [
        Color.alphaBlend(Colors.black.withOpacity(0.08), widget.fillColor),
        Color.alphaBlend(Colors.black.withOpacity(0.24), widget.fillColor),
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
          height: widget.height,
          decoration: BoxDecoration(
            gradient: baseGradient,
            borderRadius: BorderRadius.zero,
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
                        decoration: BoxDecoration(
                          gradient: fillGradient,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: widget.height >= 60 ? 18.0 : 15.0,
                      letterSpacing: 0.5,
                    ),
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
