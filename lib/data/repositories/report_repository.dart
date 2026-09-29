import 'package:supabase_flutter/supabase_flutter.dart';

class ReportRepository {
  ReportRepository(this.client);
  final SupabaseClient client;

  Future<List<Map<String, dynamic>>> vehicleReport({required String vehicleId, required DateTime from, required DateTime to}) async {
    final rows = await client.from('tracking_events').select('event_type,occurred_at,speed_kph,latitude,longitude,trip_id,driver_id').eq('vehicle_id', vehicleId).gte('occurred_at', from.toIso8601String()).lte('occurred_at', to.toIso8601String()).order('occurred_at');
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> driverReport({required String driverId, required DateTime from, required DateTime to}) async {
    final rows = await client.from('tracking_events').select('event_type,occurred_at,speed_kph,latitude,longitude,trip_id,vehicle_id').eq('driver_id', driverId).gte('occurred_at', from.toIso8601String()).lte('occurred_at', to.toIso8601String()).order('occurred_at');
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> delayReport({DateTime? from, DateTime? to}) async {
    var q = client.from('delay_records').select('trip_id,shipment_id,vehicle_id,driver_id,arrival_at,delay_started_at,elapsed_hours,compensation_amount,currency,status');
    if (from != null) q = q.gte('arrival_at', from.toIso8601String());
    if (to != null) q = q.lte('arrival_at', to.toIso8601String());
    final rows = await q.order('arrival_at', ascending: false);
    return (rows as List).cast<Map<String, dynamic>>();
  }
}
