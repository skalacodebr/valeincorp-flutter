import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/routes.dart';

enum NavItem { inicio, buscar, atividades, favoritos, perfil }

class BottomNavigation extends StatelessWidget {
  final NavItem currentItem;

  const BottomNavigation({
    super.key,
    required this.currentItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                NavItem.inicio,
                Icons.home_outlined,
                Icons.home,
                'Início',
                AppRoutes.dashboard,
              ),
              _buildNavItem(
                context,
                NavItem.buscar,
                Icons.search,
                Icons.search,
                'Buscar',
                AppRoutes.buscar,
              ),
              _buildNavItem(
                context,
                NavItem.atividades,
                Icons.analytics_outlined,
                Icons.analytics,
                'Atividades',
                AppRoutes.atividades,
              ),
              _buildNavItem(
                context,
                NavItem.perfil,
                Icons.person_outline,
                Icons.person,
                'Perfil',
                AppRoutes.perfil,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    NavItem item,
    IconData icon,
    IconData activeIcon,
    String label,
    String route,
  ) {
    final isActive = currentItem == item;

    return GestureDetector(
      onTap: () {
        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryGold.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primaryGold : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.primaryGold : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

