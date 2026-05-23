import 'package:flutter/material.dart';
import 'prof_controller.dart';
import 'screens/today_screen.dart';
import 'screens/classes_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/animated_tap_scale.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.controller});

  final ProfController controller;

  @override
  Widget build(BuildContext context) {
    final pages = [
      TodayScreen(controller: controller),
      ClassesScreen(controller: controller),
      HistoryScreen(controller: controller),
      SettingsScreen(controller: controller),
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
            key: ValueKey<int>(controller.selectedIndex),
            child: pages[controller.selectedIndex],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          border: Border(
            top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.space_dashboard_outlined,
                activeIcon: Icons.space_dashboard_rounded,
                label: 'Hoje',
                isSelected: controller.selectedIndex == 0,
                onTap: () => controller.selectTab(0),
              ),
              _NavBarItem(
                icon: Icons.layers_outlined,
                activeIcon: Icons.layers_rounded,
                label: 'Turmas',
                isSelected: controller.selectedIndex == 1,
                onTap: () => controller.selectTab(1),
              ),
              _NavBarItem(
                icon: Icons.insights_outlined,
                activeIcon: Icons.insights_rounded,
                label: 'Historico',
                isSelected: controller.selectedIndex == 2,
                onTap: () => controller.selectTab(2),
              ),
              _NavBarItem(
                icon: Icons.tune_rounded,
                activeIcon: Icons.tune_rounded,
                label: 'Ajustes',
                isSelected: controller.selectedIndex == 3,
                onTap: () => controller.selectTab(3),
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
    final inactiveColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.5);

    return AnimatedTapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.zero,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
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
