import 'package:flutter_test/flutter_test.dart';
import 'package:Kelivo/core/providers/sync_provider.dart';

void main() {
  group('SyncConfig', () {
    test('constructor defaults', () {
      final config = const SyncConfig();
      expect(config.autoSyncEnabled, false);
      expect(config.relayServerUrl, '');
      expect(config.syncIntervalMinutes, 30);
      expect(config.syncWorkspaces, true);
      expect(config.syncAgents, true);
      expect(config.syncTasks, true);
      expect(config.syncChannels, true);
      expect(config.syncSkills, true);
    });

    test('copyWith preserves and overrides', () {
      final config = const SyncConfig();
      final updated = config.copyWith(
        autoSyncEnabled: true,
        relayServerUrl: 'https://relay.example.com',
        syncIntervalMinutes: 15,
      );
      expect(updated.autoSyncEnabled, true);
      expect(updated.relayServerUrl, 'https://relay.example.com');
      expect(updated.syncIntervalMinutes, 15);
      expect(updated.syncWorkspaces, true);
    });

    test('copyWith clearUrl clears the URL', () {
      final config = const SyncConfig(relayServerUrl: 'https://example.com');
      final cleared = config.copyWith(clearUrl: true);
      expect(cleared.relayServerUrl, '');
    });

    test('toJson/fromJson round-trip', () {
      final config = SyncConfig(
        autoSyncEnabled: true,
        relayServerUrl: 'https://sync.example.com',
        syncIntervalMinutes: 60,
        syncWorkspaces: true,
        syncAgents: false,
        syncTasks: true,
        syncChannels: false,
        syncSkills: true,
      );
      final json = config.toJson();
      final restored = SyncConfig.fromJson(json);
      expect(restored.autoSyncEnabled, config.autoSyncEnabled);
      expect(restored.relayServerUrl, config.relayServerUrl);
      expect(restored.syncIntervalMinutes, config.syncIntervalMinutes);
      expect(restored.syncWorkspaces, config.syncWorkspaces);
      expect(restored.syncAgents, config.syncAgents);
      expect(restored.syncTasks, config.syncTasks);
      expect(restored.syncChannels, config.syncChannels);
      expect(restored.syncSkills, config.syncSkills);
    });

    test('fromJson handles missing fields', () {
      final json = <String, dynamic>{};
      final config = SyncConfig.fromJson(json);
      expect(config.autoSyncEnabled, false);
      expect(config.syncIntervalMinutes, 30);
      expect(config.syncWorkspaces, true);
    });
  });
}