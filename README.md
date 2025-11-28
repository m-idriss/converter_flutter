# converter_flutter

Converter with Flutter.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase Configuration

This app uses Firebase Authentication. Follow these steps to configure Firebase:

### Prerequisites

1. Install the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)

### Configuration Steps

1. **Initialize Firebase in your project:**
   ```bash
   flutterfire configure
   ```
   This will:
   - Create a Firebase project (or use existing one)
   - Register your app for each platform (Android, iOS, Web)
   - Generate `firebase_options.dart` with your configuration

2. **Update `lib/main.dart`** to use the generated options:
   ```dart
   import 'firebase_options.dart';
   
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
     runApp(const MyApp());
   }
   ```

3. **Enable Email/Password Authentication:**
   - Go to Firebase Console → Authentication → Sign-in method
   - Enable Email/Password provider

### Platform-Specific Setup

#### Android
The `flutterfire configure` command automatically handles Android configuration by generating the `google-services.json` file.

#### iOS
The `flutterfire configure` command automatically handles iOS configuration by generating the `GoogleService-Info.plist` file.

#### Web
The `flutterfire configure` command automatically handles Web configuration.

### Features

- User registration with email and password
- User sign-in with email and password
- Authentication state persistence across app restarts
- Sign-out functionality
- Error handling with user-friendly messages

