import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_theme.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      FlutterMap(options: const MapOptions(initialCenter: LatLng(24.7136, 46.6753), initialZoom: 5.2, interactionOptions: InteractionOptions(flags: InteractiveFlag.all)), children: [
        TileLayer(urlTemplate: const String.fromEnvironment('MAP_TILE_URL', defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'), userAgentPackageName: 'com.movbot.app'),
      ]),
      Positioned(top:16,left:16,right:16,child:Container(padding:const EdgeInsets.symmetric(horizontal:14,vertical:12),decoration:BoxDecoration(color:AppColors.navy900.withValues(alpha:.94),borderRadius:BorderRadius.circular(16),border:Border.all(color:AppColors.border)),child:const Row(children:[Icon(Icons.gps_off_rounded,color:AppColors.amber),SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('الخريطة التشغيلية',style:TextStyle(fontWeight:FontWeight.w800)),SizedBox(height:2),Text('GPS غير متصل — لا يتم عرض موقع حي غير موثّق',style:TextStyle(color:AppColors.muted,fontSize:11))]))])),
      Positioned(left:16,right:16,bottom:16,child:Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:AppColors.navy900.withValues(alpha:.97),borderRadius:BorderRadius.circular(22),border:Border.all(color:AppColors.border)),child:Row(children:[_legend(AppColors.green,'متحركة'),const SizedBox(width:14),_legend(AppColors.amber,'متوقفة'),const SizedBox(width:14),_legend(AppColors.red,'عطل'),const Spacer(),IconButton(onPressed:(){},icon:const Icon(Icons.my_location_rounded,color:AppColors.orange))]))),
    ]);
  }
  Widget _legend(Color c,String t)=>Row(children:[Container(width:9,height:9,decoration:BoxDecoration(color:c,shape:BoxShape.circle)),const SizedBox(width:5),Text(t,style:const TextStyle(fontSize:11))]);
}
