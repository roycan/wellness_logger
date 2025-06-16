# Flutter Setup Instructions

## 1. Install Flutter

### For Linux:
```bash
# Download Flutter
cd ~/Development
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH (add this to your ~/.bashrc or ~/.zshrc)
export PATH="$PATH:$HOME/Development/flutter/bin"

# Reload your shell
source ~/.bashrc  # or source ~/.zshrc

# Verify installation
flutter --version
flutter doctor
```

### Alternative: Using Snap (Ubuntu/Linux)
```bash
sudo snap install flutter --classic
flutter doctor
```

## 2. Install Dependencies

```bash
# Accept Android licenses (if you plan to develop for Android)
flutter doctor --android-licenses

# Install additional dependencies
sudo apt-get install curl git unzip xz-utils zip libglu1-mesa
```

## 3. IDE Setup

### VS Code Extensions:
- Flutter
- Dart
- Flutter Widget Inspector
- Flutter Tree

### Android Studio Plugins:
- Flutter Plugin
- Dart Plugin

## 4. Verify Setup

```bash
flutter doctor -v
```

This should show all green checkmarks or provide instructions for any missing components.

## 5. Create Flutter Project

Once Flutter is installed, navigate to the wellness_logger directory and run:

```bash
# Create the Flutter project
flutter create --org com.wellnesslogger --project-name wellness_logger_mobile .

# Or create in a subdirectory to preserve web app:
flutter create --org com.wellnesslogger --project-name wellness_logger_mobile mobile_app
```

## Next Steps

After Flutter is installed and the project is created, return to this guide for the detailed project structure setup.
