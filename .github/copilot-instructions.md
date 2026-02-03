# TechKnowlEdgeConnect - AI Coding Instructions

## Project Overview

A Flutter education app (German-language) for students to learn through bite-sized lessons and exchange with peers. Multi-platform targeting Web, Android, and iOS with Firebase backend.

## Architecture

### Layer Structure

- **`lib/pages/`** - Screen-level widgets organized by feature (`home/`, `search/`, `chats/`, `profile/`, `library/`)
- **`lib/components/`** - Reusable UI widgets (tiles, buttons, text fields)
- **`lib/services/`** - Firebase integration layer (`AuthService`, `ChatService`, `LearningMaterialService`, `AiTechService`)
- **`lib/models/`** - Data classes with `toMap()`/`fromMap()` for Firestore serialization
- **`lib/data/`** - Static educational content organized by subject/topic/concept hierarchy

### Navigation Pattern

`OverviewPage` uses `IndexedStack` with 5 tabs: Home → Search → Feed → Chats → Profile. Feature pages push onto the navigation stack from these tabs.

### Firebase Collections

- `Users` - User profiles keyed by UID
- `chat_rooms` - Chat messages with `{userId1}_{userId2}` room IDs (sorted alphabetically)
- `learningMaterials` - User-uploaded files with Storage URLs

## Key Development Commands

```bash
# Environment setup (required before first run/build)
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Build for platforms
flutter build appbundle --debug    # Android
flutter build web                  # Web
```

## Critical Patterns

### Environment Variables

Secrets use `envied` package. Create `.env` with `OPENAI_API_KEY`, then regenerate `lib/env/env.g.dart` with build_runner. **Never commit `env.g.dart`** - CI decodes from secrets.

### Model Serialization

All Firestore models follow this pattern (see [learning_material.dart](lib/models/learning_material.dart)):

```dart
Map<String, dynamic> toMap() => {'field': value, ...};
factory Model.fromMap(Map<String, dynamic> map) => Model(field: map['field'], ...);
```

### Theming

Use `Theme.of(context).colorScheme` for all colors. Custom theme defined in [theme.dart](lib/theme.dart) with `ThemeConfig.lightTheme`/`darkTheme`.

### Firebase App Check

Debug mode uses debug providers; production uses Play Integrity (Android), App Attest (iOS), ReCaptcha V3 (Web). See `main.dart`.

### AI Integration

`AiTechService` uses Firebase AI with Gemini models for:

- Document summarization (`summarizeMultipleData`)
- Learning bite generation (`generateLearningBite`) with structured JSON schema

### Static Learning Content

Educational content is structured hierarchically in `lib/data/`:

- `subjects` → `categories` → `topics` → `units` → `concepts` → `learning_bites`
- Each learning bite contains tasks (singleChoice, indexCard, cloze types)

## Localization

App uses German as primary language. German text in UI, prompts, and error messages. Supported locales: `de`, `en`.

## Release Workflow

1. Update version in `pubspec.yaml`
2. Create git tag: `git tag vX.Y.Z && git push origin vX.Y.Z`
3. CI deploys: Android → Play Console internal track, Web → Firebase Hosting, iOS → Xcode Cloud
