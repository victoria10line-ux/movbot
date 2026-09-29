import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/status_chip.dart';

class VehiclesPage extends StatefulWidget { const VehiclesPage({super.key}); @override State<VehiclesPage> createState() => _VehiclesPageState(); }
class _VehiclesPageState extends State<VehiclesPage> {
  final search = TextEditingController();
  final demo = const [
    ('TRUCK-104','ABC-123','Curtain','محمد أحمد','Moving',StatusTone.success,72),
    ('TRUCK-087','KSA-871','Refrigerated','خالد علي','Idle',StatusTone.warning,48),
    ('TRUCK-031','JED-031','Flatbed','سامي حسن','Breakdown',StatusTone.danger,91),
  ];
  @override Widget build(BuildContext context) => Column(children: [
    Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 10), child: Row(children: [Expanded(child: Text('الشاحنات', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900))), IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list_rounded))])),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: TextField(controller: search, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'بحث بالـ ID أو اللوحة أو السائق', prefixIcon: Icon(Icons.search_rounded)))),
    const SizedBox(height: 12),
    Expanded(child: ListView.separated(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), itemCount: demo.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, i) { final x=demo[i]; if(search.text.isNotEmpty && !x.$1.toLowerCase().contains(search.text.toLowerCase()) && !x.$2.toLowerCase().contains(search.text.toLowerCase()) && !x.$4.contains(search.text)) return const SizedBox.shrink(); return _VehicleCard(data:x); }))
  ]);
}
class _VehicleCard extends StatelessWidget { const _VehicleCard({required this.data}); final (String,String,String,String,String,StatusTone,int) data; @override Widget build(BuildContext context) { final x=data; return Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppColors.navy900,borderRadius: BorderRadius.circular(20),border: Border.all(color: AppColors.border)), child: Column(children: [Row(children: [Container(width:64,height:64,decoration:BoxDecoration(color:AppColors.navy800,borderRadius:BorderRadius.circular(16)),child:const Icon(Icons.local_shipping_rounded,size:34,color:AppColors.orange)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(x.$1,style:const TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:3),Text('${x.$2} • ${x.$3}',style:const TextStyle(color:AppColors.muted,fontSize:12)),const SizedBox(height:5),Text('السائق: ${x.$4}',style:const TextStyle(fontSize:12))])),StatusChip(label:x.$5,tone:x.$6)]),const SizedBox(height:14),Row(children:[const Text('الحمولة',style:TextStyle(color:AppColors.muted,fontSize:11)),const Spacer(),Text('${x.$6 == StatusTone.danger ? 0 : x.$7}%',style:const TextStyle(fontWeight:FontWeight.w800))]),const SizedBox(height:7),ClipRRect(borderRadius:BorderRadius.circular(99),child:LinearProgressIndicator(value:x.$6==StatusTone.danger?0:x.$7/100,minHeight:6,backgroundColor:AppColors.navy700,color:AppColors.orange))])); }}
