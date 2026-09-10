<div align="center">

# 🏃‍♂️ FitTrack

### Personal Fitness & Real-Time Activity Tracker

<p>
  <strong>Track • Train • Improve • Achieve</strong>
</p>

<p>
  A modern Flutter-based fitness application for recording activities,
  tracking workouts in real time, setting personal fitness goals,
  and analyzing daily & weekly progress.
</p>

<br>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Hive](https://img.shields.io/badge/Hive-Local%20Storage-FFB300?style=for-the-badge)](https://pub.dev/packages/hive)
[![FL%20Chart](https://img.shields.io/badge/FL%20Chart-Analytics-2563EB?style=for-the-badge)](https://pub.dev/packages/fl_chart)
[![Android](https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://www.android.com/)
[![Version](https://img.shields.io/badge/Version-1.0.0-2563EB?style=for-the-badge)](#)

<br>

⭐ **Built with Flutter & Dart**

</div>

---

## 📖 About The Project

**FitTrack** is a modern mobile fitness tracking application developed using **Flutter and Dart**.

The application provides users with a centralized fitness companion where they can record physical activities, monitor daily performance, create fitness goals, track workouts in real time, and review their fitness statistics.

FitTrack combines **manual activity logging** with **real-time workout tracking** to deliver a practical and user-friendly fitness experience.

### 🎯 Project Goals

- Make daily fitness tracking simple
- Provide accurate workout monitoring
- Help users stay consistent with fitness goals
- Provide useful progress insights
- Keep user data separated between accounts
- Support offline local data storage
- Provide a clean and modern mobile experience

---

## ✨ Core Features

<table>
<tr>
<td width="50%">

### 🔐 Authentication
- Account registration
- Email/password login
- Duplicate email detection
- Password validation
- Persistent login session
- Secure logout flow
- User-specific data access

</td>
<td width="50%">

### 🏠 Dashboard
- Daily steps
- Calories burned
- Workout duration
- Workout count
- Quick activity logging
- Real-time workout access
- Clean modern dashboard

</td>
</tr>
<tr>
<td>

### 📝 Activity Management
- Add activities
- Edit activities
- Delete activities
- Activity categories
- Duration tracking
- Calories tracking
- Steps tracking
- Notes

</td>
<td>

### 🏃 Real-Time Workout
- Live workout timer
- GPS movement tracking
- Distance calculation
- Step tracking
- Calories estimation
- Pause / Resume
- Finish workout
- Movement filtering

</td>
</tr>
<tr>
<td>

### 🎯 Fitness Goals
- Daily step goals
- Daily calorie goals
- Daily duration goals
- Daily distance goals
- Goal workout mode
- Pending goals
- Completed goals
- Goal progress

</td>
<td>

### 📊 Statistics
- Daily activity insights
- Weekly progress
- Workout duration
- Calories
- Steps
- Activity history
- Visual charts
- Progress analysis

</td>
</tr>
<tr>
<td>

### 👤 Profile
- Personal profile
- User information
- Gallery profile image
- Local profile image storage
- User-specific profile data

</td>
<td>

### 🌙 Dark Mode
- Application-wide dark theme
- Persistent theme preference
- Modern dark color palette
- Light / dark theme switching
- Consistent Material 3 UI

</td>
</tr>
</table>

---

## 🏃 Real-Time Workout Tracking

FitTrack includes a dedicated real-time workout experience.

When a user starts a workout, the application can monitor:

| Metric | Description |
|---|---|
| ⏱️ Duration | Live workout duration |
| 👣 Steps | Steps detected during workout |
| 📍 GPS | Movement/location tracking |
| 📏 Distance | Distance calculated from movement |
| 🔥 Calories | Estimated calories burned |
| ⏸️ Pause | Temporarily pause workout |
| ▶️ Resume | Continue paused workout |
| ⏹️ Finish | Save completed workout |

### 📍 Movement Accuracy

The workout tracking implementation uses movement filtering techniques to reduce inaccurate GPS distance caused by small location fluctuations.

The tracking logic considers factors such as:

- GPS accuracy
- Minimum movement threshold
- Distance jumps
- Movement speed
- Step information

This helps provide a more reliable real-time workout experience.

---

## 🎯 Fitness Goal System

Users can create personalized daily fitness targets.

### Available Targets
```
👣 Daily Steps
🔥 Daily Calories
⏱️ Daily Duration
📏 Daily Distance
```

### Goal Workout

The **Goal Workout** mode is designed around the user's active fitness targets. The application tracks progress toward configured targets and marks the workout as completed once the applicable active targets are achieved.

Users can review their goals through:

```
All Goals → Pending / Completed
```

---

## 🔐 User Data Protection

FitTrack follows a **user-scoped data model**.

Every activity is associated with a unique user identifier: `userId`

Activities are retrieved according to the currently authenticated user.

```dart
ActivityService.getActivitiesForUser(userId);
```

Update and delete operations also verify ownership using:

```
Activity ID + Current User ID
```

**🔒 Result:** A logged-in user can only access and modify activities belonging to their own account through the application service layer. This design prevents normal application flows from exposing one user's activity data to another user.

---

## 💾 Offline & Local Storage

FitTrack uses **Hive** for local data persistence.

**Local Data stored:**
- 👤 User accounts
- 🔑 Login session
- 📝 Activities
- 🎯 Fitness goals
- 🌙 Theme preference
- 🖼️ Profile image path

**Why Hive?**
- ⚡ Fast local storage
- 📱 Offline support
- 🪶 Lightweight
- 🔧 Simple Flutter integration
- 💾 Persistent local data
- 🚫 No external database server required for the current local setup

---

## 🎨 UI / UX Design

FitTrack follows a modern **Material 3** design approach.

**Design Principles:**
Minimal interface • Consistent spacing • Rounded cards • Clear typography • Responsive layouts • Strong visual hierarchy • Easy navigation • Light & Dark themes • Clean information architecture

### 🎨 FitTrack Color System

The UI follows a blue/slate visual identity.

| Design Element | Color |
|---|---|
| 🔵 Primary | `#2563EB` |
| 💙 Dark Primary | `#60A5FA` |
| ⚪ Light Background | `#F8FAFC` |
| 🌑 Dark Background | `#0F172A` |
| 🖤 Dark Surface | `#1E293B` |
| ⚪ Light Surface | `#FFFFFF` |

---

## 🌙 Dark Mode

FitTrack supports application-wide Dark Mode.

Users can enable or disable Dark Mode from:

```
Drawer → Dark Mode
```

The selected theme preference is stored locally and restored when the application starts again.

---

## 🚀 Splash Screen & App Branding

FitTrack includes a custom branded startup experience.

**Splash Features:**
- Custom FitTrack splash artwork
- Approximately 3.5-second splash experience
- Smooth transition into the application
- Separate application launcher icon
- Android launcher icon configuration

**Branding Assets:**
```
assets/
└── images/
    ├── fittrack_icon.png
    └── fittrack_splash.png
```

---

## 🔔 Device Permissions

Real-time workout tracking requires device permissions.

**📍 Location Permission** — used for GPS movement, distance calculation, real-time workout tracking.

**👣 Physical Activity Permission** — used for step tracking, workout activity monitoring.

Permissions are handled through the application's dedicated permission service.

---

## 🧱 Technology Stack

<div align="center">

| Technology | Purpose |
|---|---|
| 🐦 Flutter | Cross-platform mobile UI framework |
| 🎯 Dart | Application programming language |
| 💾 Hive | Local data persistence |
| 📊 FL Chart | Fitness charts & analytics |
| 🆔 UUID | Unique user/activity identifiers |
| 📍 Geolocator | GPS & location tracking |
| 👣 Pedometer | Step tracking |
| 🔐 Permission Handler | Runtime permission management |
| 🖼️ Image Picker | Profile image selection |
| 🚀 Flutter Native Splash | Splash screen generation |
| 📱 Flutter Launcher Icons | Application icon generation |
| 📅 Intl | Date/time formatting |

</div>

---

## 🏗️ Project Architecture

FitTrack follows a modular Flutter structure.

```
fit_track/
│
├── android/
│
├── assets/
│   └── images/
│       ├── fittrack_icon.png
│       └── fittrack_splash.png
│
├── lib/
│   │
│   ├── models/
│   │   ├── activity_model.dart
│   │   ├── fitness_goals_model.dart
│   │   ├── user_model.dart
│   │   └── workout_session_model.dart
│   │
│   ├── screens/
│   │   ├── activity_details_screen.dart
│   │   ├── all_goals_screen.dart
│   │   ├── contact_us_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── fitness_goals_screen.dart
│   │   ├── help_support_screen.dart
│   │   ├── login_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── register_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── splash_screen.dart
│   │   ├── statistics_screen.dart
│   │   ├── weekly_dashboard_screen.dart
│   │   └── workout_tracker_screen.dart
│   │
│   ├── services/
│   │   ├── activity_service.dart
│   │   ├── auth_service.dart
│   │   ├── fitness_goals_service.dart
│   │   ├── permission_service.dart
│   │   ├── theme_service.dart
│   │   └── workout_tracking_service.dart
│   │
│   ├── widgets/
│   │   └── app_drawer.dart
│   │
│   └── main.dart
│
├── test/
│   └── widget_test.dart
│
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

---

## 🔄 Application Flow

```
                    ┌─────────────────────┐
                    │     FitTrack App     │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │    Splash Screen     │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │     Auth Gateway     │
                    └─────────┬───┬───────┘
                              │   │
                     Logged In   Not Logged In
                              │   │
                              ▼   ▼
                    ┌────────────┐ ┌──────────┐
                    │ Dashboard  │ │  Login   │
                    └──────┬─────┘ └────┬─────┘
                           │             │
                           │             ▼
                           │        Registration
                           │
                           ▼
                  ┌───────────────────┐
                  │   Fitness System   │
                  └─────────┬─────────┘
                            │
          ┌─────────────────┼─────────────────┐
          ▼                 ▼                 ▼
     Activities          Goals          Real-Time
                                          Workout
          │                 │                 │
          └─────────────────┼─────────────────┘
                            ▼
                       Statistics
```

---

## 📱 Screens & Modules

| Screen / Module | Purpose |
|---|---|
| 🔐 Login | User authentication |
| 📝 Register | New account creation |
| 🏠 Dashboard | Daily fitness overview |
| 📝 Activity Details | Add/edit activity information |
| 🎯 Fitness Goals | Create and manage goals |
| 📋 All Goals | View pending/completed goals |
| 🏃 Workout Tracker | Real-time workout tracking |
| 📊 Statistics | Fitness analytics |
| 📅 Weekly Dashboard | Weekly performance |
| 👤 Profile | Personal profile |
| ⚙️ Settings | Application preferences |
| ❓ Help & Support | User assistance |
| 📞 Contact Us | Developer/contact information |

---

## 🧪 Testing & Quality

FitTrack was tested during development using Flutter's built-in development tools.

**Static Analysis**
```bash
flutter analyze
```

**Widget Testing**
```bash
flutter test
```

**Build Verification**
```bash
flutter build apk --release
```

**The application was checked for:**
Authentication flow • User data isolation • Activity CRUD • Goal management • Real-time workout tracking • Permissions • Dark Mode • Splash screen • Navigation • Responsive layouts • Widget tests • Release build

---

## 📦 Installation

**Requirements:** Flutter SDK, Dart SDK, Android Studio, Android SDK, Git, and an Android device or emulator.

**1️⃣ Clone Repository**
```bash
git clone https://github.com/AliZain3311/CodeAlpha_FitnessTracker.git
```

**2️⃣ Open Project**
```bash
cd CodeAlpha_FitnessTracker
```

**3️⃣ Install Dependencies**
```bash
flutter pub get
```

**4️⃣ Run Application**

Connect an Android device or start an Android emulator, then:
```bash
flutter run
```

---

## 📱 Build Release APK

Generate a release APK with:
```bash
flutter build apk --release
```

The APK will be generated inside:
```
build/app/outputs/flutter-apk/
```

**Final APK:** `FitTrack-v1.0.0.apk`

---

## 📸 Application Screenshots

<div align="center">

**🏠 Dashboard**
<br>
<img src="screenshots/dashboard.png" width="280">

<br><br>

**🏃 Real-Time Workout**
<br>
<img src="screenshots/workout_tracker.png" width="280">

<br><br>

**🎯 Fitness Goals**
<br>
<img src="screenshots/fitness_goals.png" width="280">

<br><br>

**📊 Statistics**
<br>
<img src="screenshots/statistics.png" width="280">

<br><br>

**👤 Profile**
<br>
<img src="screenshots/profile.png" width="280">

<br><br>

**🌙 Dark Mode**
<br>
<img src="screenshots/dark_mode.png" width="280">

</div>

> 📌 **Note:** Add your final screenshots to the `screenshots/` directory using the filenames shown above.

---

## 🎥 Project Demonstration

A project demonstration can showcase the complete FitTrack workflow:

```
Splash → Authentication → Dashboard → Activity Logging → Fitness Goals →
Real-Time Workout → Statistics → Profile → Dark Mode
```

The demonstration can be shared through the developer's professional profile together with the GitHub repository.

---

## 🎓 CodeAlpha Internship

This project was developed as part of the **CodeAlpha App Development Internship**.

**📌 Internship Task:** Task 3 — Fitness Tracker

The project implements the major requirements of the fitness tracker task, including:

Daily activity logging • Fitness progress • Fitness goals • Statistics and charts • Local data storage • Real-time workout tracking • Modern mobile UI

---

## 📊 Project Overview

| Category | Implementation |
|---|---|
| 📱 Application | FitTrack |
| 🐦 Framework | Flutter |
| 💻 Language | Dart |
| 🔐 Authentication | Local email/password |
| 💾 Storage | Hive |
| 📝 Activity Tracking | Manual + Real-Time |
| 👣 Step Tracking | Pedometer |
| 📍 Location | GPS |
| 📊 Analytics | FL Chart |
| 🎯 Goals | Daily fitness targets |
| 🌙 Theme | Light + Dark |
| 👤 Profile | Local gallery image |
| 📴 Offline Storage | Yes |
| 📱 Platform | Android |
| 🔢 Version | 1.0.0 |

---

## 🛠️ Development Highlights

The project was progressively developed and refined with:

Modular Flutter architecture • User-specific data handling • Authentication flow • Activity CRUD • Fitness goal management • Real-time GPS tracking • Pedometer integration • Permission management • Local persistence • Statistics dashboards • Dark Mode • Custom splash screen • Custom launcher icon • Profile image support • Responsive UI • Widget testing • Flutter static analysis

---

## 🔮 Future Roadmap

Future versions of FitTrack may include:

- ☁️ Firebase cloud synchronization
- 🔄 Cloud backup & restore
- 🏆 Achievement and badge system
- 👥 Social fitness challenges
- 📈 Advanced analytics
- 🔔 Workout reminders
- 🗓️ Workout planning
- 📱 Additional platform support
- 🔐 Production-grade authentication
- ☁️ Multi-device synchronization

---

## 👨‍💻 Developer

<div align="center">

**Ali Zain**
<br>
Flutter Mobile Application Developer

<br>

Flutter • Dart • Firebase • REST APIs • Laravel • PHP • MySQL

</div>

---

## 📬 Contact

For feedback, collaboration, or project-related questions:

- 📧 **Email:** alizain263311@gmail.com
- 💻 **GitHub:** [github.com/AliZain3311](https://github.com/AliZain3311)
- 🔗 **LinkedIn:** [linkedin.com/in/alizain3311](https://www.linkedin.com/in/alizain3311)

---

## 📄 License

This project was developed for educational and internship purposes.

© 2026 Ali Zain. All rights reserved.

<div align="center">

### ⭐ Like the project?

Give the repository a ⭐ and support the project!

<br>

**🏃 Track Your Progress. Improve Every Day.**

Built with ❤️ using Flutter & Dart

<br>

© 2026 Ali Zain

</div>