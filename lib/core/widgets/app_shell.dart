import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/trips/trips_page.dart';
import '../../features/vehicles/vehicles_page.dart';
import '../../features/map/map_page.dart';
import '../../features/more/more_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  final pages = const [DashboardPage(), TripsPage(), VehiclesPage(), MapPage(), MorePage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: index, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        backgroundColor: AppColors.navy900,
        indicatorColor: AppColors.orange.withValues(alpha: .15),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), selectedIcon: Icon(Icons.grid_view_rounded, color: AppColors.orange), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.route_rounded), selectedIcon: Icon(Icons.route_rounded, color: AppColors.orange), label: 'الرحلات'),
          NavigationDestination(icon: Icon(Icons.local_shipping_outlined), selectedIcon: Icon(Icons.local_shipping, color: AppColors.orange), label: 'الشاحنات'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map, color: AppColors.orange), label: 'الخريطة'),
          NavigationDestination(icon: Icon(Icons.more_horiz_rounded), selectedIcon: Icon(Icons.more_horiz_rounded, color: AppColors.orange), label: 'المزيد'),
        ],
      ),
    );
  }
}
