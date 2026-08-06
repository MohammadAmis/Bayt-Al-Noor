# 🕋 Bayt Al-Noor (بيت النور)

> **"The Celestial Compass"** — A digital sanctuary designed to mirror the rhythmic, cyclical nature of spiritual life. Moving away from the utilitarian "alarm clock" aesthetics of traditional prayer apps, Bayt Al-Noor delivers a highly refined, premium editorial experience.

---

## 🎨 Creative North Star & Design Philosophy

Bayt Al-Noor is built upon a custom visual identity outlined in [DESIGN.md](file:///c:/Users/Asus/Desktop/Bayt-Al-Noor/DESIGN.md):

*   **Tonal Depth & Intentional Asymmetry:** The application layout uses Golden Ratio-inspired proportions where UI elements breathe, eschewing rigid grids.
*   **The "No-Line" Rule:** Standard 1px solid borders are prohibited. Depth, boundaries, and section separations are defined entirely through background color shifts, negative space, and tonal shifts (e.g., placing interactive cards on slightly lower-brightness containers).
*   **Glassmorphism ("Glass & Gold"):** Floating elements, such as the prayer timeline, employ a soft backdrop filter blur (`12px`) and subtle HSL gold gradients to symbolize divine light.
*   **Typography System:** 
    *   **Noto Serif:** Enhances display headers and spiritual texts, evoking the timeless feel of printed scripture.
    *   **Manrope:** Handles secondary titles, utility metrics, and labels for absolute clarity.

---

## ✨ Core Features

1.  **Celestial Home & Prayer Times**
    *   An analog-style circular timeline depicting the day's progression.
    *   Accurate prayer times computed via coordinates using the `adhan` engine and location services (`geolocator`, `geocoding`).
    *   Silent & loud notifications for prayer boundaries handled by `flutter_local_notifications`.

2.  **End-to-End Encrypted (E2EE) Circles**
    *   Encrypted group and private chats built using the **Signal Protocol** (`libsignal_protocol_dart`).
    *   Secure local database storage using **Drift** (powered by **SQLCipher** for encrypted sqlite storage).
    *   Server-side key bundle negotiation utilizing Supabase database functions for identity keys and one-time prekeys.

3.  **Community Forums**
    *   A rich social feed for sharing spiritual reflections and resources.
    *   Local draft creation cached using **Hive** for a seamless offline-first experience.
    *   Secure, reactive data updates powered by Supabase Realtime.

4.  **Qibla Compass**
    *   An editorial direction finder utilizing the device's magnetic sensor and orientation APIs (`flutter_compass`, `sensors_plus`).

5.  **Deen Hub & Daily Devotionals**
    *   Contains the **Tasbih** counter (with micro-haptics) and **Zakat** calculator.
    *   A visual repository of Quranic verses, spiritual guides, and audio media (`just_audio`).

---

## 🛠️ Technology Stack

*   **Core:** Flutter SDK (v3.5.4+) & Dart
*   **State Management:** Riverpod (`flutter_riverpod`, `riverpod_annotation`) with code generation
*   **Authentication & Backend:** Supabase Client (`supabase_flutter`)
*   **Encrypted Local Database:** Drift (`drift`, `drift_dev`) + SQLite / SQLCipher (`sqlcipher_flutter_libs`)
*   **Caching & NoSQL:** Hive (`hive_flutter`) for UI preferences and forum drafts
*   **Navigation:** GoRouter (`go_router`) with integrated Auth Guards
*   **Push Notifications:** Firebase Messaging (`firebase_messaging`) & Local Notifications (`flutter_local_notifications`)

---

## 📂 Project Structure

The codebase is organized following a Feature-Sliced / clean presentation architecture under the [lib](file:///c:/Users/Asus/Desktop/Bayt-Al-Noor/lib) directory:

```
lib/
├── app/                  # Application initialization and routes
│   ├── app.dart          # Main application widget
│   └── router.dart       # GoRouter mapping & auth guard redirects
├── core/                 # Shared resources, styles, and global utilities
│   ├── design_tokens.dart# Color systems, spacing, shapes, and typography
│   ├── secrets.dart      # Supabase & Cloudinary credentials (ignore/change on prod)
│   └── providers/        # Core global services providers
└── features/             # Feature-sliced modules
    ├── auth/             # Login, Register, OTP Verification, and Passwords
    ├── circle/           # E2EE chats, message entities, Signal protocol logic
    ├── deen/             # Core devotions hub
    ├── forum/            # Community posts, drafts, comments, and search
    ├── home/             # Main dashboard and celestial circular timeline
    ├── prayer_times/     # Adhan calculation engine, clocks, and settings
    ├── profile/          # User and community profiles
    ├── qibla/            # Compass UI and sensor interfaces
    ├── quran/            # Scripture viewer & reader
    ├── settings/         # Preferences and notification toggles
    ├── splash/           # Launch visual
    ├── tasbih/           # Counter widgets
    └── zakat/            # Zakat calculator engine
```

---

## 🚀 Setting Up the Project

### 1. Prerequisites
Ensure you have the Flutter SDK installed on your system. Run `flutter doctor` to verify your environment setup.

### 2. Secrets Configuration
The application credentials are loaded from [lib/core/secrets.dart](file:///c:/Users/Asus/Desktop/Bayt-Al-Noor/lib/core/secrets.dart). Ensure it contains the correct credentials for your Supabase project and Cloudinary storage:

```dart
class SupabaseSecrets {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}

class CloudinarySecrets {
  static const String apiKey = 'YOUR_CLOUDINARY_API_KEY';
  static const String apiSecret = 'YOUR_CLOUDINARY_API_SECRET';
  static const String cloudName = 'YOUR_CLOUDINARY_CLOUD_NAME';
}
```

### 3. Database Initialization
To support end-to-end encryption key storage, session setup, and prekey consumption, run the SQL script located at [supabase/e2ee_setup.sql](file:///c:/Users/Asus/Desktop/Bayt-Al-Noor/supabase/e2ee_setup.sql) in your Supabase SQL Editor. This script:
*   Initializes the `user_signal_keys` and `user_one_time_pre_keys` tables.
*   Enables Row Level Security (RLS) policies for user privacy.
*   Declares the `fetch_and_consume_prekey_bundle` RPC to securely handshake E2EE parameters.

### 4. Code Generation
Run `build_runner` to generate Riverpod providers and local Drift database schemas:
```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Running the App
Start the app on an emulator or a connected physical device:
```powershell
flutter run
```

---

## 🔒 Security Architecture (E2EE Chat)

Bayt Al-Noor uses a state-of-the-art Double Ratchet (Signal) encryption process for circles:
1.  **Key Upload:** Upon registration or login, the client generates an `Identity Key`, `Signed Pre-Key`, and a pool of `One-Time Pre-Keys` stored in Supabase.
2.  **Pre-Key Consumption:** When initiating a secure chat, the initiator requests a bundle using the custom RPC `fetch_and_consume_prekey_bundle(target_user_id)`. The function reads the public credentials and deletes the consumed one-time key in an atomic transaction to ensure forward secrecy.
3.  **Local Storage Security:** Messages and key sessions are stored locally in SQLite encrypted using **SQLCipher**, ensuring that messages cannot be accessed even if the physical device file system is compromised.
