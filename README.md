# 📚 Learnity Mobile

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![License](https://img.shields.io/github/license/raaflii/Learnity-Mobile?style=for-the-badge)

### 🚀 Innovative Digital Learning Platform
*Learn Easier, Anytime, Anywhere*

---

## 🌟 About Learnity Mobile

Learnity Mobile is a digital learning application designed to provide an interactive and enjoyable learning experience. With a user-friendly interface and advanced features, this application allows users to access various learning materials, take online courses.

### ✨ Key Features

- 📖 **Interactive Learning Materials** - Access thousands of learning materials from various categories
- 🎥 **Video Learning** - Learning through high-quality videos
- 🌙 **Dark Mode** - Supports dark theme for eye comfort
- 👥 **Role Management** - Complete user role management system
- 📝 **CRUD Operations** - Full Create, Read, Update, Delete functionality

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform UI framework
- **Dart** - Main programming language
- **Riverpod** - State management


### Backend & Services
- **Supabase** - Backend-as-a-Service (Database, Auth, Storage, Edge Functions)
- **PostgreSQL** - Database (via Supabase)
- **REST API** - Supabase Auto-generated APIs
- **Realtime** - Real-time subscriptions for live updates

## 🚀 Quick Start

### Prerequisites

Make sure you have installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.0+)
- [Dart SDK](https://dart.dev/get-dart) (version 2.17+)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)

### Installation

1. **Clone repository**
   ```bash
   git clone https://github.com/raaflii/Learnity-Mobile.git
   cd Learnity-Mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Supabase**
   ```bash
   # Install Supabase CLI
   npm install -g supabase
   
   # Login to Supabase
   supabase login
   
   # Initialize project
   supabase init
   
   # Link to remote project
   supabase link --project-ref your-project-ref
   ```

4. **Configure environment**
   ```bash
   # Copy configuration file
   cp .env.example .env
   
   # Edit .env file with Supabase configuration
   nano .env
   ```
   
   Add Supabase configuration in `.env` file:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```

5. **Run application**
   ```bash
   # Debug mode
   flutter run
   
   # Release mode
   flutter run --release
   ```

## 📁 Project Structure

```
lib/
├── auth/                  # Contains authentication logic 
├── components/            # Reusable UI components and widgets used across multiple screens
├── providers/             # Riverpod state management for theme toggle
├── screens/               # Contains all the main screens (UI pages) of the application
│   ├── admin/             # Screens and features specific to admin users
│   ├── pengajar/          # Screens and features specific to teacher users
│   ├── siswa/             # Screens and features specific to student users
│   │   └── provider/      # Riverpod provider for siswa
│   ├── splash/            # Splash screen displayed when the app is launched
│   └── welcome/           # Welcome/onboarding screen shown before login
└── main.dart              # Main entry point of the Flutter app
      
```

## 📦 Build & Deployment

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

## 🌍 Localization

The application supports multiple languages:
- 🇮🇩 Indonesian
- 🇺🇸 English
- 🇸🇦 Arabic

To add new languages, edit files in `lib/l10n/`.

## 🤝 Contributing

We greatly appreciate contributions from the community! Here's how to contribute:

1. Fork this repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Create Pull Request

### Guidelines
- Follow existing code style
- Write tests for new features
- Update documentation if needed
- Use conventional commits

## 📄 API Documentation

API documentation using Supabase Auto-generated REST API.

### Supabase Configuration
```dart
// lib/core/config/supabase_config.dart
const supabaseUrl = 'https://your-project.supabase.co';
const supabaseAnonKey = 'your-anon-key';
```

### Base URL
```
Development: https://your-dev-project.supabase.co
Production: https://your-prod-project.supabase.co
```

### Authentication
```dart
// Supabase Auth
final response = await supabase.auth.signInWithPassword(
  email: email,
  password: password,
);
```

## 🔐 Security

- **JWT Authentication** - Secure authentication with Supabase Auth
- **API Key Management** - Secure API key handling
- **Real-time Security** - Authenticated real-time subscriptions
- **Data Encryption** - End-to-end encryption for sensitive data

## 📞 Support

Need help? Don't hesitate to contact us:

- 🐛 Bug Reports: [GitHub Issues](https://github.com/raaflii/Learnity-Mobile/issues)

## 👥 Team

| Avatar | Name | Role |
|--------|------|------|
| ![Raafli](https://github.com/raaflii.png) | **Rafli** | Developer |
| ![Mutiarn](https://github.com/mutiarn.png) | **Mutia** | Developer |
| ![Nadzirarifqi](https://github.com/nadzirarifqi.png) | **Onet** | Developer |

[⬆️ Back to Top](#-learnity-mobile)
---