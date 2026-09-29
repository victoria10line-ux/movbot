import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_chip.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      SliverPadding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 12), sliver: SliverToBoxAdapter(child: _header(context))),
      SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20), sliver: SliverToBoxAdapter(child: _overview(context))),
      SliverPadding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 10), sliver: SliverToBoxAdapter(child: SectionHeader(title: 'الرحلة الحالية'))),
      SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20), sliver: SliverToBoxAdapter(child: _activeTrip(context))),
      SliverPadding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 10), sliver: SliverToBoxAdapter(child: SectionHeader(title: 'تنبيهات التشغيل'))),
      SliverPadding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), sliver: SliverList.builder(itemCount: 3, itemBuilder: (_, i) => _alert(i))),
    ]);
  }

  Widget _header(BuildContext context) => Row(children: [
    Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.orange.withValues(alpha: .14), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.local_shipping_rounded, color: AppColors.orange)),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('مرحباً بك', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)), Text('لوحة التشغيل', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900))])),
    Stack(children: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)), Positioned(right: 8, top: 7, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle)))])
  ]);

  Widget _overview(BuildContext context) => GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.45, children: const [
    _Metric(title: 'المتحركة', value: '18', icon: Icons.navigation_rounded, tone: StatusTone.success),
    _Metric(title: 'متوقفة', value: '07', icon: Icons.pause_circle_outline, tone: StatusTone.warning),
    _Metric(title: 'متأخرة', value: '03', icon: Icons.schedule_rounded, tone: StatusTone.danger),
    _Metric(title: 'رحلات نشطة', value: '24', icon: Icons.route_rounded, tone: StatusTone.accent),
  ]);

  Widget _activeTrip(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.navy900, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.border)), child: Column(children: [
    Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('TRIP-2026-1042', style: TextStyle(fontWeight: FontWeight.w800)), SizedBox(height: 4), Text('جدة → الرياض', style: TextStyle(color: AppColors.muted))])), const StatusChip(label: 'Moving', tone: StatusTone.success)]),
    const SizedBox(height: 18),
    Row(children: [Expanded(child: _routePoint('جدة', 'Loading complete', true)), Container(width: 70, height: 2, color: AppColors.orange), Expanded(child: _routePoint('الرياض', 'ETA 18:40', false))]),
    const SizedBox(height: 16),
    Row(children: [const Icon(Icons.local_shipping_outlined, size: 18, color: AppColors.orange), const SizedBox(width: 8), const Text('TRUCK-104'), const Spacer(), Text('312 km متبقي', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted))])
  ]));

  Widget _routePoint(String title, String sub, bool done) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.muted))]);

  Widget _alert(int i) { final items = [('مستند على وشك الانتهاء', 'تأمين TRUCK-104 خلال 6 أيام', StatusTone.warning), ('تأخير تحميل', 'TRIP-2026-1039 تجاوز 24 ساعة', StatusTone.danger), ('صيانة مستحقة', 'تغيير زيت TRUCK-087 عند 80,000 km', StatusTone.accent)]; final x = items[i]; return Padding(padding: const EdgeInsets.only(bottom: 10), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.navy900, borderRadius: BorderRadius.circular(16)), child: Row(children: [Icon(Icons.info_outline_rounded, color: x.$3 == StatusTone.danger ? AppColors.red : AppColors.amber), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(x.$1, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(x.$2, style: const TextStyle(color: AppColors.muted, fontSize: 12))])), const Icon(Icons.chevron_left_rounded, color: AppColors.muted)])));
}

class _Metric extends StatelessWidget { const _Metric({required this.title, required this.value, required this.icon, required this.tone}); final String title, value; final IconData icon; final StatusTone tone; @override Widget build(BuildContext context) { final c = switch (tone) {StatusTone.success => AppColors.green, StatusTone.warning => AppColors.amber, StatusTone.danger => AppColors.red, _ => AppColors.orange}; return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.navy900, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: c, size: 21), const Spacer(), Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)), Text(title, style: const TextStyle(color: AppColors.muted, fontSize: 11))])); } }
