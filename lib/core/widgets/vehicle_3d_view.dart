import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../theme/app_theme.dart';

enum VehicleVisualState { empty, quarterLoad, halfLoad, fullLoad, loading, unloading, moving, rest, fueling, breakdown, offline, delivered }

class Vehicle3DView extends StatelessWidget {
  const Vehicle3DView({super.key, required this.assetPath, required this.state});
  final String assetPath;
  final VehicleVisualState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.navy800, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        ModelViewer(
          src: assetPath,
          alt: '3D fleet vehicle',
          cameraControls: true,
          autoRotate: true,
          backgroundColor: AppColors.navy800,
          loading: Loading.lazy,
          reveal: Reveal.auto,
        ),
        Positioned(left:12,bottom:12,child:Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:7),decoration:BoxDecoration(color:AppColors.navy950.withValues(alpha:.9),borderRadius:BorderRadius.circular(99)),child:Text(_label(state),style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800))))
      ]),
    );
  }

  String _label(VehicleVisualState s) => switch (s) {
    VehicleVisualState.empty => 'EMPTY',
    VehicleVisualState.quarterLoad => '25% LOAD',
    VehicleVisualState.halfLoad => '50% LOAD',
    VehicleVisualState.fullLoad => 'FULL LOAD',
    VehicleVisualState.loading => 'LOADING',
    VehicleVisualState.unloading => 'UNLOADING',
    VehicleVisualState.moving => 'MOVING',
    VehicleVisualState.rest => 'REST',
    VehicleVisualState.fueling => 'FUELING',
    VehicleVisualState.breakdown => 'BREAKDOWN',
    VehicleVisualState.offline => 'OFFLINE',
    VehicleVisualState.delivered => 'DELIVERED',
  };
}
