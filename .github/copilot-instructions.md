# AIGrove Project Guide for AI Coding Agents

## Project Overview

AIGrove is a Flutter application focusing on eco-friendly AI assistance. The project uses:

- Flutter for cross-platform development
- Supabase for authentication and backend services
- Material Design for UI components

## Project Structure

```
lib/
├── main.dart                # Application entry point
├── auth/                    # Authentication related pages
│   ├── landing_page.dart
│   ├── login_page.dart
│   └── register_page.dart
├── pages/                   # Main application pages (Home, Scan, Map, Challenge, Profile, etc.)
│   ├── home_page.dart
│   ├── scan_page.dart
│   ├── map_page.dart
│   ├── challenge_page.dart
│   └── profile_page.dart
├── services/                # Business logic and API services
│   ├── user_service.dart
│   └── profile_service.dart
├── theme/                   # Theme configuration
│   └── app_theme.dart
├── widgets/                 # Reusable UI components
│   └── app_drawer.dart
```

## Key Patterns and Conventions

### Authentication Flow

- Entry point is `landing_page.dart`
- Authentication state managed through Supabase
- Protected routes require valid session
- Always check mounted state before using context after async operations

Example from `login_page.dart`:

```dart
if (!mounted) return; // Check before using context
if (response.session != null) {
  Navigator.pushReplacementNamed(context, '/home');
}
```

### State Management

- StatefulWidget for pages with local state
- TextEditingController for form inputs
- Loading states for async operations

### UI Patterns

- Consistent use of Material Design components
- Stack with background image for auth pages
- Form validation with SnackBar feedback
- Loading indicators during async operations

## Development Workflow

1. Run `flutter pub get` to install dependencies
2. Use `flutter run` to start the app in debug mode
3. Test on multiple platforms using `flutter run -d <platform>`

## Common Tasks

- Adding new pages: Create in appropriate subdirectory under `lib/`
- Auth changes: Modify files in `lib/auth/`
- Theme updates: Check `lib/theme/`
- New widgets: Add to `lib/widgets/`

## Integration Points

- Supabase: Used for authentication and data storage
- Flutter Material: UI components and theming
- Assets: Stored in `assets/` directory

## Comments

- Make the comments Tagalog or bisaya for better understanding
