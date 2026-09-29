import 'package:flutter_test/flutter_test.dart';
import 'package:movbot/domain/models/vehicle.dart';

void main() {
  test('vehicle identity is UUID-backed and display codes are not identity', () {
    const a = Vehicle(id: 'uuid-a', code: 'TRUCK-01', plate: 'ABC-123', trailerType: TrailerType.curtain, status: VehicleStatus.moving);
    const b = Vehicle(id: 'uuid-b', code: 'TRUCK-01', plate: 'ABC-999', trailerType: TrailerType.curtain, status: VehicleStatus.idle);
    expect(a.id, isNot(b.id));
    expect(a.code, b.code);
  });
}
