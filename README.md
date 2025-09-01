Dynamic Cards Flutter App

This project is a Flutter assignment submission that demonstrates rendering dynamic card layouts using API-driven data. The app fetches UI configurations from an API and builds reusable card widgets accordingly.

<img width="452" height="797" alt="Screenshot 2025-09-02 at 12 18 23 AM" src="https://github.com/user-attachments/assets/78438ad9-0510-4ba0-aa35-9f061700f93e" />
<img width="417" height="802" alt="Screenshot 2025-09-02 at 12 18 37 AM" src="https://github.com/user-attachments/assets/b454d4b7-636b-4720-9481-1f7b17db37ce" />

🚀 Features

Fetches card layout data from remote API (JSON-based)

Supports multiple design types (HC1, HC9, etc.)

Uses BLoC (Business Logic Component) for state management

Persists lightweight data using SharedPreferences

Scrollable & responsive layouts with multiple row structures

Handles refresh with RefreshIndicator

Platform compatibility: iOS & Android

📂 Project Structure
lib/
 ┣ bloc/               # BLoC state management files
 ┣ models/             # Data models (HomeModel, CardItem, etc.)
 ┣ repository/         # API service and data handling
 ┣ ui/                 # Widgets and screens
 ┣ utils/              # Helper methods
 ┗ main.dart           # Entry point

⚙️ State Management – BLoC

HomeBloc manages loading states (HomeLoading, HomeLoaded, HomeError)

Events such as FetchHomeData trigger API calls

The UI listens to state changes using BlocBuilder

This ensures a clean separation of concerns between UI and logic

🌐 API Integration

Data is fetched from a remote endpoint that returns a JSON defining card sections

Each section has a design_type, height, and list of cards

Example (simplified):

{
  "id": 80,
  "name": "DisplayCards",
  "design_type": "HC1",
  "cards": [
    {
      "id": 3,
      "name": "smallCardWithArrow",
      "title": "Small card with an arrow",
      "icon": { "image_url": "https://..." },
      "url": "https://google.com",
      "bg_color": "#FBAF03"
    }
  ]
}


The UI dynamically builds cards using this config

💾 SharedPreferences

Used to persist lightweight app state (like refresh flags, simple preferences)

Ensures data persistence between app launches

📱 Running the App
Prerequisites

Flutter SDK installed

Android Studio / Xcode

Device emulator or physical device

📦 APK Build

The release APK is included in the repo under:

apk/app-release.apk

🎥 Demo
 https://drive.google.com/file/d/1UR1ZMWzEhdrtsT_lWF3Akf6E5xfqGhb6/view?usp=sharing

 🛠️ Tech Stack

Flutter (UI)

BLoC (state management)

Dio/http (API requests)

SharedPreferences (local persistence)
