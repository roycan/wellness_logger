import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

/// Service locator for dependency injection using GetIt.
/// 
/// This class configures all the dependencies for the application following
/// the Clean Architecture principles. It ensures proper separation of concerns
/// and makes the code more testable by providing easy mocking capabilities.
/// 
/// Dependencies are organized by layers:
/// - Core services (logging, storage)
/// - Data layer (repositories, services) - TO BE IMPLEMENTED
/// - Domain layer (use cases) - TO BE IMPLEMENTED
/// - Presentation layer (BLoCs, providers) - TO BE IMPLEMENTED
final GetIt serviceLocator = GetIt.instance;

/// Sets up all dependencies for the application.
/// 
/// This function should be called once during app initialization.
/// The setup follows a specific order to ensure dependencies are available
/// when needed by other services.
/// 
/// Order of initialization:
/// 1. Core services (Logger)
/// 2. Additional services will be added in Phase 1
Future<void> setupServiceLocator() async {
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );
  
  logger.i('🔧 Setting up service locator dependencies...');
  
  try {
    // === CORE SERVICES ===
    
    // Logger (singleton)
    serviceLocator.registerLazySingleton<Logger>(() => logger);
    
    // TODO: Additional services will be added in Phase 1:
    // - Local Storage Service
    // - Analytics Service  
    // - Export Service
    // - Repositories
    // - Use Cases
    
    logger.i('✅ Service locator setup completed successfully');
    
  } catch (error, stackTrace) {
    logger.e('❌ Failed to setup service locator', error: error, stackTrace: stackTrace);
    rethrow;
  }
}

/// Resets all dependencies. Useful for testing.
/// 
/// This function clears all registered dependencies and allows for
/// fresh registration. Primarily used in test environments to ensure
/// clean state between tests.
void resetServiceLocator() {
  serviceLocator.reset();
}

/// Extension to make service locator usage more convenient
extension ServiceLocatorX on GetIt {
  /// Gets a dependency with better error handling
  T getDependency<T extends Object>() {
    try {
      return get<T>();
    } catch (error) {
      final logger = isRegistered<Logger>() ? get<Logger>() : null;
      logger?.e('Failed to get dependency ${T.toString()}', error: error);
      rethrow;
    }
  }
  
  /// Checks if a dependency is registered
  bool hasDependency<T extends Object>() {
    return isRegistered<T>();
  }
}
