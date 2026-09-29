enum VehicleStatus { moving, idle, loading, unloading, fueling, rest, breakdown, offline, delivered }

enum TrailerType { curtain, flatbed, sidewall, refrigerated }

class Vehicle {
  const Vehicle({
    required this.id,
    required this.code,
    required this.plate,
    required this.trailerType,
    required this.status,
    this.driverName,
    this.latitude,
    this.longitude,
    this.speedKph = 0,
    this.heading = 0,
    this.loadPercent = 0,
    this.lastUpdated,
  });
  final String id;
  final String code;
  final String plate;
  final TrailerType trailerType;
  final VehicleStatus status;
  final String? driverName;
  final double? latitude;
  final double? longitude;
  final double speedKph;
  final double heading;
  final double loadPercent;
  final DateTime? lastUpdated;

  factory Vehicle.fromMap(Map<String, dynamic> m) => Vehicle(
        id: m['id'] as String,
        code: m['vehicle_code'] as String,
        plate: m['plate_number'] as String,
        trailerType: TrailerType.values.byName(m['trailer_type'] as String),
        status: VehicleStatus.values.byName(m['status'] as String),
        driverName: m['driver_name'] as String?,
        latitude: (m['last_latitude'] as num?)?.toDouble(),
        longitude: (m['last_longitude'] as num?)?.toDouble(),
        speedKph: (m['speed_kph'] as num?)?.toDouble() ?? 0,
        heading: (m['heading_deg'] as num?)?.toDouble() ?? 0,
        loadPercent: (m['load_percent'] as num?)?.toDouble() ?? 0,
        lastUpdated: DateTime.tryParse(m['last_updated_at'] as String? ?? ''),
      );
}
