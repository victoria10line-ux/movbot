import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';

class MorePage extends StatelessWidget { const MorePage({super.key}); @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.fromLTRB(20,20,20,28),children:[
  Text('المزيد',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w900)),const SizedBox(height:18),
  _item(context,Icons.description_outlined,'المستندات','هوية، رخص، تأمين وفحص',()=>_snack(context,'سيتم ربط المستندات مباشرة بـ Storage وRLS.')),
  _item(context,Icons.build_outlined,'الصيانة','جداول الخدمة والتكاليف',()=>_snack(context,'سجل الصيانة مصمم ليكون مرتبطاً بـ Vehicle UUID.')),
  _item(context,Icons.assessment_outlined,'التقارير','PDF وExcel مع فلاتر حقيقية',()=>_snack(context,'Reporting Engine موجود في طبقة الخدمات.')),
  _item(context,Icons.settings_outlined,'الإعدادات','سياسات التأخير والتنبيهات',()=>_snack(context,'إعدادات النظام تحفظ في system_settings.')),
  const SizedBox(height:12),
  OutlinedButton.icon(onPressed:()=>Supabase.instance.client.auth.signOut(),icon:const Icon(Icons.logout_rounded),label:const Text('تسجيل الخروج')),
]);
Widget _item(BuildContext context,IconData icon,String title,String sub,VoidCallback tap)=>Padding(padding:const EdgeInsets.only(bottom:10),child:InkWell(onTap:tap,borderRadius:BorderRadius.circular(18),child:Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:AppColors.navy900,borderRadius:BorderRadius.circular(18),border:Border.all(color:AppColors.border)),child:Row(children:[Container(width:44,height:44,decoration:BoxDecoration(color:AppColors.orange.withValues(alpha:.12),borderRadius:BorderRadius.circular(14)),child:Icon(icon,color:AppColors.orange)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:3),Text(sub,style:const TextStyle(color:AppColors.muted,fontSize:12))])),const Icon(Icons.chevron_left_rounded,color:AppColors.muted)]))));
void _snack(BuildContext context,String text)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(text)));
}
