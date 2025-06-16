# Wellness Logger Mobile App

A Flutter-based mobile application for tracking SVT (Supraventricular Tachycardia) episodes, exercise routines, and medication intake with comprehensive offline functionality and health insights.

## 📱 Features

- **Offline-First**: Complete functionality without internet connection
- **Health Tracking**: Log SVT episodes, exercise, and medication
- **Smart Analytics**: Comprehensive health insights and patterns
- **Data Export**: CSV export for medical consultations
- **Search & Filter**: Find entries quickly with advanced filtering
- **Calendar View**: Visual timeline of health events
- **Material Design 3**: Modern, accessible UI

## 🏗️ Architecture

This app follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                   # Core utilities and configuration
│   ├── constants/         # App-wide constants
│   ├── errors/           # Error handling classes
│   ├── theme/            # UI theme configuration
│   └── utils/            # Utility functions and services
├── data/                   # Data layer
│   ├── models/           # Data models and DTOs
│   ├── repositories/     # Repository implementations
│   └── services/         # External services (storage, export)
├── domain/                 # Business logic layer
│   ├── entities/         # Business entities
│   ├── repositories/     # Repository interfaces
│   └── usecases/         # Business use cases
├── presentation/           # UI layer
│   ├── screens/          # App screens
│   ├── widgets/          # Reusable UI components
│   └── providers/        # State management
└── main.dart              # App entry point
```

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: Version 3.10.0 or higher
- **Dart SDK**: Version 3.0.0 or higher
- **Android Studio** or **VS Code** with Flutter extensions
- **Git** for version control

### Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd wellness_logger/mobile_app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate code** (if needed):
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

### Development Setup

1. **Enable Flutter web** (optional):
   ```bash
   flutter config --enable-web
   ```

2. **Check doctor**:
   ```bash
   flutter doctor
   ```

3. **Run tests**:
   ```bash
   flutter test
   ```

## 🧪 Testing

The app includes comprehensive testing:

- **Unit Tests**: Business logic and utility functions
- **Widget Tests**: UI components and interactions
- **Integration Tests**: End-to-end user workflows
- **Golden Tests**: Visual regression testing

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/constants_test.dart

# Run widget tests
flutter test test/widget/

# Run integration tests
flutter test integration_test/
```

### Test Coverage

We maintain >90% test coverage. To view coverage:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 📦 Dependencies

### Core Dependencies
- `flutter_bloc`: State management
- `hive_flutter`: Local database
- `sqflite`: SQL database support
- `go_router`: Navigation
- `json_annotation`: JSON serialization

### UI Dependencies
- `fl_chart`: Charts and graphs
- `share_plus`: File sharing
- `csv`: CSV export functionality

### Development Dependencies
- `very_good_analysis`: Strict linting rules
- `mockito`: Mocking for tests
- `bloc_test`: BLoC testing utilities
- `golden_toolkit`: Golden file testing

## 🎨 Code Style

This project follows strict coding standards:

- **Dart Style Guide**: Official Dart conventions
- **Very Good Analysis**: Comprehensive linting rules
- **Clean Architecture**: Clear separation of concerns
- **SOLID Principles**: Object-oriented design principles

### Code Formatting

```bash
# Format all files
dart format .

# Check formatting
dart format --set-exit-if-changed .
```

### Code Analysis

```bash
# Analyze code
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

## 🚀 Building

### Debug Build
```bash
flutter build apk --debug
```

### Release Build
```bash
# Android APK
flutter build apk --release

# Android App Bundle (recommended for Play Store)
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release
```

## 📱 Platform Support

- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 11.0+
- **Web**: Modern browsers (future enhancement)
- **Desktop**: Windows, macOS, Linux (future enhancement)

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the root directory:

```env
# Development settings
DEBUG_MODE=true
ENABLE_LOGGING=true

# Analytics (future)
ANALYTICS_ENABLED=false

# Cloud sync (future)
CLOUD_SYNC_ENABLED=false
```

### Build Flavors

The app supports multiple build flavors:

```bash
# Development
flutter run --flavor dev

# Staging
flutter run --flavor staging

# Production
flutter run --flavor prod
```

## 📊 Performance

Performance targets:
- **Startup time**: <2 seconds
- **Memory usage**: <100MB typical
- **Frame rate**: 60fps consistently
- **Database queries**: <100ms for most operations

### Performance Monitoring

```bash
# Profile performance
flutter run --profile

# Analyze memory usage
flutter run --track-widget-creation

# Generate performance report
flutter build apk --analyze-size
```

## 📚 Documentation

- **API Documentation**: Auto-generated from code comments
- **Architecture Decisions**: See `docs/adr/` directory
- **User Guide**: See `docs/user-guide.md`
- **Development Guide**: See `docs/development.md`

### Generating Documentation

```bash
# Generate API docs
dart doc

# Serve documentation locally
dhttpd --host localhost --port 8080 doc/api/
```

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Commit** changes: `git commit -m 'Add amazing feature'`
4. **Push** to branch: `git push origin feature/amazing-feature`
5. **Create** a Pull Request

### Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new analytics dashboard
fix: resolve calendar date selection bug
docs: update API documentation
test: add unit tests for entry validation
refactor: restructure data layer
```

## 🐛 Troubleshooting

### Common Issues

1. **Build errors**: Run `flutter clean && flutter pub get`
2. **Missing dependencies**: Check `pubspec.yaml` and run `flutter pub get`
3. **Platform issues**: Run `flutter doctor` and resolve any issues
4. **Test failures**: Ensure you're using the latest Flutter version

### Debug Tools

- Use `flutter inspector` for UI debugging
- Enable `flutter logs` for runtime logging
- Use `flutter analyze` for static analysis

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for design guidelines
- Contributors and testers who help improve the app

## 📞 Support

- **Email**: support@wellnesslogger.com
- **Issues**: Create an issue on GitHub
- **Discussions**: Use GitHub Discussions for questions

---

**Built with ❤️ using Flutter**
