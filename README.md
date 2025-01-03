# Fitness App

A modern fitness tracking app built with Flutter featuring workout tracking, meal planning, and progress monitoring.

## Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Android Studio or VS Code
- Git

### Installation
1. Clone the repository
```bash
git clone https://github.com/talha1230/Fitness_unimy.git
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## Features

- 🏃‍♂️ Workout Tracking
- 📊 Progress Monitoring
- 🍎 Meal Planning
- 📈 Activity Statistics
- 💪 Exercise Library

## Screenshots

<p align="center">
  <img src="flutter_01.png" width="270" alt="Fitness App Home Screen">
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="flutter_02.png" width="270" alt="Fitness App Workout Screen">
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="flutter_03.png" width="270" alt="Fitness App Meal Screen">
</p>

## Project Structure

```
lib/
├── fitness_app/
│   ├── models/
│   ├── ui_view/
│   └── fitness_app_home_screen.dart
├── main.dart
└── app_theme.dart
```

## Development

### Code Style
Follow the official [Flutter style guide](https://flutter.dev/docs/development/style-guide)

### Running Tests
```bash
flutter test
```

### Building for Production
```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

### Running on Different Platforms

#### Web Browsers
```bash
# Run on Edge
flutter run -d edge

# Run on Chrome
flutter run -d chrome

# List all available devices
flutter devices
```

#### Enable Web Support
If web support is not enabled:
```bash
flutter config --enable-web
flutter devices # Verify web devices are listed
```

#### Build for Web
```bash
# Build for web deployment
flutter build web

# Build with specific renderer
flutter build web --web-renderer html
flutter build web --web-renderer canvaskit
```

The built web files will be in `build/web` directory.

### Debugging in Browsers
- Chrome DevTools: Press F12 or right-click -> Inspect
- Edge DevTools: Press F12 or right-click -> Inspect

## Database Configuration

### Appwrite Setup
1. Create an account on [Appwrite](https://appwrite.io/)

## License
This project is licensed under the MIT License - see the LICENSE file for details
```
