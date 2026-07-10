# CodeAlpha Internship - Flutter Tasks

This repository contains the Flutter projects completed during the **CodeAlpha Flutter Developer Internship**. Each task demonstrates key aspects of mobile development, including clean architecture, database integration, state management (Provider), third-party APIs (Gemini AI), and rich animations.

---

## 📁 Repository Structure

```
codealpha_tasks/
│
├── task-1/            # FlashMaster (Flashcard Quiz App)
├── task-2/            # Random Quote Generator
└── task-3/            # FitTrack (AI Fitness Tracker)
```

---

## 🚀 Projects Overview

### 🏷️ Task 1: FlashMaster (Flashcard Quiz App)
**FlashMaster** is a complete, production-ready Flashcard Quiz App designed to help users study smarter. It features an interactive, clean Material 3 UI with persistent local storage.

*   **Key Features**:
    *   **Study Mode**: Interactive 3D flip card animations with custom session timers and progress tracking.
    *   **Manage Flashcards**: Full CRUD capabilities (Create, Read, Update, Delete) with global search.
    *   **Categorization**: Organize flashcards into dynamic categories (Programming, Maths, Science, etc.).
    *   **Statistics Dashboard**: Beautiful visualization of study time, sessions completed, and success rate using `fl_chart`.
    *   **Backup & Restore**: Export/Import flashcards easily via JSON.
    *   **Database**: High-performance local storage using `Hive`.
*   **State Management**: `Provider`

---

### 💬 Task 2: Random Quote Generator
A highly modular Flutter application designed to fetch, display, and manage random quotes across multiple categories.

*   **Key Features**:
    *   **Randomization**: Instantly generate random inspirational, scientific, or general quotes.
    *   **Categorized Quotes**: Filter quotes by author, topic, or tags.
    *   **Favorites & Sharing**: Save favorite quotes locally and share them directly on social channels.
    *   **Aesthetics**: Sleek minimal design with custom typography.
*   **State Management**: `Provider`

---

### 🏋️ Task 3: FitTrack (AI-Powered Fitness Tracker)
**FitTrack** is a state-of-the-art wellness and fitness dashboard that integrates AI guidance with robust gamification to motivate user progress.

*   **Key Features**:
    *   **AI Coach**: Conversational workspace powered by the **Google Gemini API** to provide workout plans, nutrition advice, and posture tips.
    *   **Activity Logging**: Log exercises, steps, water intake, and track daily goals.
    *   **Gamification Engine**: Level up with XP points, maintain daily streaks, and unlock unique achievement badges.
    *   **Analytics**: View progress charts showing workout volume and hydration trends.
    *   **Emergency Card**: Keep crucial medical information (blood group, emergency contact) readily accessible in-app.
*   **Database**: Local database storage using `Sqflite` and secure keys via `flutter_secure_storage`.
*   **APK Included**: Ready-to-test `FitTrack.apk` is available in the root folder of Task 3.

---

## ⚙️ How to Setup & Run

### Prerequisites
Make sure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your system.

### Steps
1. **Clone the repository**:
   ```bash
   git clone https://github.com/niha147/codealpha_tasks.git
   cd codealpha_tasks
   ```

2. **Navigate to a task folder**:
   For example, to run **Task 3 (FitTrack)**:
   ```bash
   cd task-3
   ```

3. **Fetch dependencies**:
   ```bash
   flutter pub get
   ```

4. **Code Generation (For Hive/Task 1 if changes are made)**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**:
   ```bash
   flutter run
   ```

---

*Developed with ❤️ as part of the CodeAlpha Internship Program.*
