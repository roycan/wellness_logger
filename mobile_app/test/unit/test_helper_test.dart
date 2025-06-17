import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';

void main() {
  test('test helper method exists', () {
    final entry = TestDataFactory.createSampleSvtEpisode();
    expect(entry, isNotNull);
    expect(entry.id, isNotEmpty);
  });
}
