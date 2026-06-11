import 'package:flutter_test/flutter_test.dart';
import 'package:Kelivo/core/providers/runtime_provider.dart';

void main() {
  group('RuntimeHostStatus', () {
    test('values are correct', () {
      expect(RuntimeHostStatus.values, [
        RuntimeHostStatus.stopped,
        RuntimeHostStatus.running,
        RuntimeHostStatus.error,
      ]);
    });

    test('fromJson returns correct enum', () {
      expect(RuntimeHostStatus.fromJson('stopped'), RuntimeHostStatus.stopped);
      expect(RuntimeHostStatus.fromJson('running'), RuntimeHostStatus.running);
      expect(RuntimeHostStatus.fromJson('error'), RuntimeHostStatus.error);
    });

    test('fromJson returns stopped for unknown', () {
      expect(RuntimeHostStatus.fromJson('unknown'), RuntimeHostStatus.stopped);
    });

    test('toJson/fromJson round-trip', () {
      for (final status in RuntimeHostStatus.values) {
        expect(RuntimeHostStatus.fromJson(status.toJson()), status);
      }
    });
  });
}