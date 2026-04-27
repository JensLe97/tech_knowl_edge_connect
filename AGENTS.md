# TechKnowlEdgeConnect: Agent Context

This document outlines the architecture, data models, and specific conventions for the TechKnowlEdgeConnect Flutter application to ensure accurate and safe code generation.

## 1. Project Overview

- **App:** Educational Flutter app, multi-platform (Android, iOS, Web, Desktop).
- **Primary Locale:** German (`de`), supports English (`en`).
- **Backend:** Firebase (Auth, Firestore, Storage, Functions, App Check).
- **Key Commands:**
  - Unit Tests: `flutter test`
  - Integration Tests: `./test_driver/run_tests.sh`
  - Android Debug Build: `flutter build appbundle --debug`

## 2. Architecture & UI Conventions

- **`lib/pages/`**: Feature-based screen widgets.
  - _Navigation:_ `OverviewPage` uses an `IndexedStack` (5 tabs). Push feature pages onto the stack from these tabs.
- **`lib/components/`**: Reusable UI widgets.
- **`lib/services/`**: Backend/Firebase logic.
- **`lib/models/`**: Data classes. **Must** implement `toMap()` and `fromMap()` for Firestore serialization.
- **`lib/theme.dart`**: Core styling. Always use `Theme.of(context).colorScheme` and `ThemeConfig.lightTheme`/`darkTheme`. Do not hardcode colors.

## 3. Database Schema & Content Hierarchy

- **Users:** `Users` collection (keyed by UID).
- **Chats:** `chat_rooms` (ID format: `{uid1}_{uid2}`, alphabetically sorted).
- **Materials:** `learningMaterials` (Files in Storage, URLs in Firestore).
- **Content Hierarchy (Strict Pathing):** `content_subjects/{subjectId}/categories/{categoryId}/topics/{topicId}/units/{unitId}/concepts/{conceptId}/learning_bites/{learningBiteId}`
  - Interact with this hierarchy using `content_service.dart` and `content_admin_service.dart` (e.g., `findLearningBitePath()`, `getLearningBite()`) rather than manual path construction.

## 4. AI Generation & Tasks (`LearningBite`)

Orchestrated by `LearningJourneyAgent`, generation is handled by `AiTechGenService` which outputs JSON arrays (`learningBites` or `tasks`).

**Task Types & JSON Schema:**
Shape: `{ "type": "...", "question": "...", "correctAnswer": "...", "answers": ["...", ...] }`

- `singleChoice`: `correctAnswer` must _exactly_ match a string inside the `answers` array.
- `singleChoiceCloze`: Gap-fill presented as a multiple-choice pick.
- `freeTextFieldCloze`: Free-text gap fill. Use `{}` separators for multi-part answers (e.g., `Word1{}Word2`).
- `indexCard`: Flashcard. `question` = front, `correctAnswer` = back/explanation.

_Constraint:_ Validate AI JSON schema strictly. Normalize `correctAnswer`/`answers` to plain text (strip HTML/Markdown).

## 5. Standard Feature Implementation Flow

1.  Define model in `lib/models/` with `toMap()`/`fromMap()`.
2.  Build/extend service in `lib/services/` for logic and DB access.
3.  Build UI in `lib/pages/` or `lib/components/` utilizing `ThemeConfig`.
4.  Wire navigation via `IndexedStack` tabs or standard stack pushing.
5.  Run `build_runner` for generated code.
6.  Write and execute unit (`test/`) and integration tests (`integration_test/`).

## 6. Project Constraints & Safety

- **Secrets:** NEVER embed API keys, service accounts, or signing keys. Use environment variables.
- **Migrations:** Any schema change to Firestore or Storage requires a documented migration plan and tests.
- **Explicit Permission Required Before:** \* Executing large refactors or modifying release pipelines.
  - Pushing to remote branches or creating PRs.
  - Triggering App Store/Play Console releases.

## 7. Release Pipeline

1.  Bump semantic version in `pubspec.yaml`.
2.  Tag release and push (`git tag vX.Y.Z && git push origin vX.Y.Z`).
3.  CI automatically handles deployments (Android -> Play Console Internal, Web -> Firebase Hosting, iOS -> Xcode Cloud).
