import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/datasources/hive_local_data_source.dart';
import '../../data/datasources/local_data_source.dart';
import '../../data/repositories/wellness_repository_impl.dart';
import '../../domain/repositories/wellness_repository.dart';

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
/// 2. Data layer services (Local storage, Data sources)
/// 3. Domain layer services (Repositories)
/// 4. Additional services will be added in later phases
/// 
/// [testDirectory] - Optional directory for testing. When provided, 
/// Hive will use this directory instead of the default documents directory.
Future<void> setupServiceLocator({String? testDirectory}) async {
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
    
    // === DATA LAYER SERVICES ===
    
    // Note: Hive initialization is handled by HiveLocalDataSource
    // to support both production and test environments
    
    // Local Data Source (singleton)
    serviceLocator.registerLazySingleton<LocalDataSource>(
      () => HiveLocalDataSource(testDirectory: testDirectory),
    );
    
    // === DOMAIN LAYER SERVICES ===
    
    // Wellness Repository (singleton)
    serviceLocator.registerLazySingleton<WellnessRepository>(
      () => WellnessRepositoryImpl(
        localDataSource: serviceLocator<LocalDataSource>(),
      ),
    );
    
    // TODO: Additional services will be added in later phases:
    // - Use Cases (Phase 3)
    // - Analytics Service (Phase 6) 
    // - Export Service (Phase 7)
    
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
