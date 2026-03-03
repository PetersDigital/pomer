import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomer/core/services/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioService', () {
    test('audioServiceProvider provides an AudioService instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final audioServiceInstance = container.read(audioServiceProvider);
      expect(audioServiceInstance, isA<AudioService>());
    });
  });
}
