import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/vehicle.dart';

class VehicleRepository {
  VehicleRepository(this.client);
  final SupabaseClient client;

  Future<List<Vehicle>> list({String? query}) async {
    final q = client.from('vehicles').select('''id, vehicle_code, plate_number, trailer_type, status, last_latitude, last_longitude, speed_kph, heading_deg, load_percent, last_updated_at, drivers:current_driver_id(full_name)''');
    final data = query == null || query.trim().isEmpty
        ? await q.order('vehicle_code')
        : await q.or('vehicle_code.ilike.%${query.trim()}%,plate_number.ilike.%${query.trim()}%').order('vehicle_code');
    return (data as List).map((row) {
      final map = Map<String, dynamic>.from(row as Map);
      final driver = map.remove('drivers');
      map['driver_name'] = driver is Map ? driver['full_name'] : null;
      return Vehicle.fromMap(map);
    }).toList();
  }
}
