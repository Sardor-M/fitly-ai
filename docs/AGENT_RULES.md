# Flutter Project Development Rules - Speed-Optimized

You are an expert in Flutter/Dart. Focus on building fast and iterate throught the bugs and issue carefully.

## Core Principles
* **Ship fast, iterate later** - Prioritize working features over perfect code
* **Use defaults** - Stick to Flutter's built-in solutions unless absolutely necessary
* **Minimal dependencies** - Only add packages when they save significant time

## Essential Guidelines

### Code Style (Keep It Simple)
* Use `PascalCase` for classes, `camelCase` for variables/functions
* Keep functions under 20 lines when possible
* Use `const` constructors to improve performance
* Prefer `StatelessWidget` over `StatefulWidget` when possible

### State Management (Built-in Only)
* **Simple state**: Use `ValueNotifier` + `ValueListenableBuilder`
* **Complex state**: Use `ChangeNotifier` + `ListenableBuilder`
* **Async data**: Use `FutureBuilder` or `StreamBuilder`
* **NO third-party state management** for hackathon speed

### Navigation
* Use built-in `Navigator.push/pop` for simple navigation
* Skip complex routing packages unless you have 5+ screens

### Data & JSON
```dart
final data = jsonDecode(response.body);
final value = data['key'] as String;
```
* Skip `json_serializable` unless dealing with 10+ complex models

### UI Essentials
* **Layouts**: Use `Column`, `Row`, `ListView.builder`, `Stack`
* **Spacing**: `SizedBox(height: 16)`, `Padding(padding: EdgeInsets.all(16))`
* **Scrolling**: Wrap in `SingleChildScrollView` when content might overflow
* **Lists**: Always use `.builder()` for lists with 10+ items

### Theming (Quick Setup)
```dart
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue, // Your brand color
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  ),
  darkTheme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
  ),
  themeMode: ThemeMode.system,
);
```

### Error Handling (Minimum Viable)
```dart
try {
  // risky operation
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}
```

### Assets Setup
```yaml
# pubspec.yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

## Speed Hacks

### Quick Widgets
```dart
// Loading indicator
const Center(child: CircularProgressIndicator())

// Empty state
const Center(child: Text('No data yet'))

// Error state
Center(child: Text('Error: $error'))

// Button
ElevatedButton(
  onPressed: () {},
  child: const Text('Action'),
)

// Text input
TextField(
  decoration: InputDecoration(
    labelText: 'Label',
    border: OutlineInputBorder(),
  ),
)
```

### Useful Packages (Time-Savers Only)
* `http` - API calls
* `provider` - Only if you need DI badly
* `cached_network_image` - Network images
* `google_fonts` - Quick custom fonts

### Testing (Hackathon Reality)
* **Unit tests**: Only for critical business logic
* **Widget tests**: Skip unless required
* **Manual testing**: Your main strategy

## What to Skip
* Complex architecture patterns (clean arch, BLoC)
* Code generation (`build_runner`, `freezed`)
* Comprehensive testing
* Perfect error handling
* Localization/i18n
* Advanced animations
* Custom widgets (use Material widgets)
* Linting rules beyond defaults

## Rapid Development Checklist
1. Define your 3-5 core screens
2. Set up basic navigation
3. Implement core features (80% of value)
4. Add loading/error states
5. Make it look decent with Material 3
6. Test on real device once
7. Polish UI in final 2 hours

## Emergency Debugging
* Use `print()` liberally (not `log()` - too slow to set up)
* Check `flutter doctor` if weird errors
* `flutter clean` when all else fails
* Hot reload (r) and hot restart (R) are your friends

## UI Polish (Last Hour)
* Add padding/spacing consistently (16.0 standard)
* Use `Card` widget for grouped content
* Add icons from `Icons.*` for visual appeal
* Ensure colors pass basic contrast check
* Test in both light and dark mode

**Remember**: Done is better than perfect. Ship the MVP!
