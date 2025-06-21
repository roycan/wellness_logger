import 'package:mockito/mockito.dart';
import '../../lib/domain/repositories/wellness_repository_simple.dart';

/// Simple mock repository for widget testing
/// Following TESTING_PHILOSOPHY.md - focus on user behavior, not implementation details
class MockWellnessRepositorySimple extends Mock implements WellnessRepositorySimple {}

/// Test helper functions following our testing philosophy
class TestHelpers {
  /// Register test services - keeping it simple for widget tests
  static void registerTestServices() {
    // Simple setup for widget tests
    // Focus on testing user interactions, not complex dependency injection
  }
}

// Export for easy imports
MockWellnessRepositorySimple createMockRepository() => MockWellnessRepositorySimple();
void registerTestServices() => TestHelpers.registerTestServices();
