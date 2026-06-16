import 'package:flutter/material.dart';
import 'design_system.dart';
import '../domain/diario_de_classe.dart';
import 'screens/today_screen.dart';
import 'screens/classes_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/animated_tap_scale.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.diario, required this.now});

  final DiarioDeClasse diario;
  final DateTime now;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  void selectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TodayScreen(diario: widget.diario, now: widget.now),
      ClassesScreen(diario: widget.diario),
      HistoryScreen(diario: widget.diario),
      SettingsScreen(diario: widget.diario),
    ];
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.03),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_selectedIndex),
            child: pages[_selectedIndex],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        // ui-drift-ok: intentional use of BoxDecoration in this screen style context.
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          border: Border(top: AppBorders.subtleSide),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.gutter,
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.space_dashboard_outlined,
                activeIcon: Icons.space_dashboard_rounded,
                label: 'Hoje',
                isSelected: _selectedIndex == 0,
                onTap: () => selectTab(0),
              ),
              _NavBarItem(
                icon: Icons.layers_outlined,
                activeIcon: Icons.layers_rounded,
                label: 'Turmas',
                isSelected: _selectedIndex == 1,
                onTap: () => selectTab(1),
              ),
              _NavBarItem(
                icon: Icons.insights_outlined,
                activeIcon: Icons.insights_rounded,
                label: 'Historico',
                isSelected: _selectedIndex == 2,
                onTap: () => selectTab(2),
              ),
              _NavBarItem(
                icon: Icons.tune_rounded,
                activeIcon: Icons.tune_rounded,
                label: 'Ajustes',
                isSelected: _selectedIndex == 3,
                onTap: () => selectTab(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).colorScheme.primary;
    final inactiveColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.5);

    return AnimatedTapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.gutter,
          vertical: AppSpacing.md,
        ),
        // ui-drift-ok: intentional use of BoxDecoration in this screen style context.
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.08)
              : AppColors.transparent,
          borderRadius: AppBorders.radius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? activeColor : inactiveColor,
              size: AppSizes.navIcon,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.badge.copyWith(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
