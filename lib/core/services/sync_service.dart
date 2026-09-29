import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SyncService {
  SyncService(this.client);
  final SupabaseClient client;
  final _uuid = const Uuid();
  final _controller = StreamController<SyncState>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final List<Map<String, dynamic>> _queue = [];

  Stream<SyncState> get state => _controller.stream;

  Future<void> start() async {
    _subscription ??= Connectivity().onConnectivityChanged.listen((_) => flush());
    await flush();
  }

  Future<void> enqueueTrackingEvent(Map<String, dynamic> event) async {
    final payload = Map<String, dynamic>.from(event);
    payload['client_event_id'] ??= _uuid.v4();
    _queue.add(payload);
    _controller.add(SyncState.syncing);
    await flush();
  }

  Future<void> flush() async {
    if (_queue.isEmpty) { _controller.add(SyncState.synced); return; }
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) { _controller.add(SyncState.offline); return; }
    try {
      final batch = List<Map<String, dynamic>>.from(_queue);
      await client.from('tracking_events').upsert(batch, onConflict: 'client_event_id', ignoreDuplicates: true);
      _queue.removeRange(0, batch.length);
      _controller.add(SyncState.synced);
    } catch (_) {
      _controller.add(SyncState.offline);
    }
  }

  Future<void> dispose() async { await _subscription?.cancel(); await _controller.close(); }
}

enum SyncState { offline, syncing, synced }
