# CodeAlpha_FlashcardQuizApp - FlashMaster

**FlashMaster** is a complete, production-ready Flashcard Quiz App built with Flutter. It helps users study smarter and learn faster using a beautiful, intuitive Material 3 interface.

## Features
- **Flashcard Study Mode**: Test your knowledge with an interactive flip card animation, timer, and progress bar.
- **Manage Flashcards**: Create, Edit, Delete, and Search your flashcards easily.
- **Categories**: Organize flashcards into categories (Default: Programming, Mathematics, Science, English, General Knowledge).
- **Favorites & Shuffle**: Mark difficult cards as favorites and randomize your study order.
- **Statistics Dashboard**: Track your total study time, sessions, cards reviewed, and completion rate with beautiful charts.
- **Import / Export Data**: Backup and restore your flashcards via JSON.
- **Dark Mode**: Seamless light and dark mode toggling.
- **Persistent Storage**: Uses Hive for lightning-fast, offline local storage.

## Architecture & State Management
This project follows **Clean Architecture** principles and uses **Provider** for state management.
- **core/**: App themes, routing, and mock data logic.
- **data/**: Hive models, adapters, and database initialization.
- **providers/**: App state (FlashcardProvider, CategoryProvider, StatsProvider, StudySessionProvider).
- **screens/**: UI for Home, Study, Flashcards, Categories, Stats, and Settings.
- **widgets/**: Reusable UI components like the custom `FlipCardWidget`.

## Installation Guide

1. Clone the repository:
```bash
git clone https://github.com/yourusername/CodeAlpha_FlashcardQuizApp.git
```
2. Navigate into the directory:
```bash
cd CodeAlpha_FlashcardQuizApp
```
3. Get Flutter dependencies:
```bash
flutter pub get
```
4. Run the code generation for Hive (if modifying models):
```bash
dart run build_runner build --delete-conflicting-outputs
```
5. Run the app:
```bash
flutter run
```

## Screenshots Placeholder
*(Replace this section with actual screenshots of your app running)*
- Splash Screen
- Dashboard
- Study Screen (Front & Back of Card)
- Manage Flashcards
- Statistics Dashboard

## Dependencies
- `provider`: State Management
- `hive` & `hive_flutter`: NoSQL local database
- `google_fonts`: Custom typography
- `fl_chart`: Analytics dashboard charts
- `uuid`: Generating unique identifiers
- `file_picker`: Importing and exporting JSON backups

## Future Enhancements
- Implement cloud sync via Firebase.
- Add spaced repetition algorithm.
- Add text-to-speech for language learning.

---
**Developed for CodeAlpha Internship Task 1**
