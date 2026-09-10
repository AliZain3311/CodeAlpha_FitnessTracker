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

# 📖 About The Project

**FitTrack** is a modern mobile fitness tracking application developed
using **Flutter and Dart**.

The application provides users with a centralized fitness companion
where they can record physical activities, monitor daily performance,
create fitness goals, track workouts in real time, and review their
fitness statistics.

FitTrack combines **manual activity logging** with **real-time workout
tracking** to provide a practical and user-friendly fitness experience.

### 🎯 Project Goals

- Make daily fitness tracking simple
- Provide accurate workout monitoring
- Help users stay consistent with fitness goals
- Provide useful progress insights
- Keep user data separated between accounts
- Support offline local data storage
- Provide a clean and modern mobile experience

---

# ✨ Core Features

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

# 🏃 Real-Time Workout Tracking

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

The workout tracking implementation uses movement filtering techniques
to reduce inaccurate GPS distance caused by small location fluctuations.

The tracking logic considers factors such as:

- GPS accuracy
- Minimum movement threshold
- Distance jumps
- Movement speed
- Step information

This helps provide a more reliable real-time workout experience.

---

# 🎯 Fitness Goal System

Users can create personalized daily fitness targets.

### Available Targets

```text
👣 Daily Steps
🔥 Daily Calories
⏱️ Daily Duration
📏 Daily Distance