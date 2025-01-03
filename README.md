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
Let me help structure the environment configuration section in the 

README.md

 file:



## Environment Configuration

### Setting Up Environment Variables
1. Create a `.env` file in the project root
2. Add the following variables:
```properties
APPWRITE_PROJECT_ID=your_project_id
APPWRITE_DATABASE_ID=your_database_id
APPWRITE_USER_COLLECTION_ID=your_user_collection_id
APPWRITE_WORKOUT_COLLECTION_ID=your_workout_collection_id
APPWRITE_MEALS_COLLECTION_ID=your_meals_collection_id
APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
```

### Database Configuration

#### Appwrite Setup
1. Create an account on [Appwrite](https://appwrite.io/)
2. Create a new project
3. Set up the following collections:
   - User Profiles (`user_profiles`)
   - Workouts (`workouts`)
   - Meals (`meals`)
4. Copy your project credentials to 

.env

 file

#### Collection Structure

### Database Schema

#### User Profiles Collection
| Attribute | Type | Description |
|-----------|------|-------------|
| user_id | string | Unique identifier (document ID) |
| name | string | User's full name |
| email | string | User's email address |
| height | number | User's height in cm |
| weight | number | User's weight in kg |
| age | number | User's age |
| fitness_goal | string | User's fitness objective |
| water_intake | number | Daily water intake in glasses |
| water_goal | number | Daily water intake goal |

#### Workouts Collection
| Attribute | Type | Description |
|-----------|------|-------------|
| user_id | string | Reference to user |
| workout_name | string | Name of the workout |
| exercises | string[] | List of exercises |
| date | datetime | Date of workout |

#### Meals Collection
| Attribute | Type | Description |
|-----------|------|-------------|
| user_id | string | Reference to user |
| name | string | Meal name |
| calories | number | Total calories |
| carbs | number | Carbohydrates in grams |
| protein | number | Protein in grams |
| fat | number | Fat in grams |
| time_hour | number | Hour of meal (0-23) |
| time_minute | number | Minute of meal (0-59) |
| date | datetime | Date of meal |
| status | string | Meal status (pending/consumed/skipped) |
| reason | string | Reason for skipping (optional) |

### Security Notes
- Never commit 

.env

 file to version control
- Keep your API keys private
- Use appropriate security rules in Appwrite Console
- Enable authentication for all collections
- Set up proper backup procedures

## API Usage Guidelines
- Respect rate limits (1000 requests/minute)
- Implement proper error handling
- Cache responses when appropriate
- Follow Appwrite's best practices
- Monitor usage in Appwrite Console

## License
This project is licensed under the MIT License. You may freely use and modify the code, including Appwrite integrations, provided you:
- Include the original license
- Do not hold the authors liable
- Maintain security best practices
- Keep API credentials private
```

## License
This project is licensed under the MIT License - see the LICENSE file for details
```
