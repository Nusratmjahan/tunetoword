# CassetteNote 📼

**Send songs with heartfelt letters** - A nostalgic music dedication app inspired by cassette tapes and handwritten notes.

## Overview

CassetteNote is a mobile-first app that lets users:
- Send songs with personal letters in a cassette-style presentation
- Protect memories with password-protected links
- Create threaded conversations through song replies
- Preserve special moments in a personal library

## Tech Stack

- **Frontend:** Flutter (iOS & Android)
- **Backend:** Node.js + Express
- **Database:** Firebase (Firestore + Auth + Storage)
- **APIs:** YouTube Data API / Spotify API (for song embedding)

## Project Structure

```
CassetteNote/
├── backend_nodejs/          # Node.js REST API
│   ├── controllers/         # Business logic
│   ├── routes/              # API endpoints
│   ├── utils/               # Helper functions
│   └── index.js             # Server entry point
│
├── frontend_flutter/        # Flutter mobile app
│   └── lib/
│       ├── screens/         # UI screens
│       ├── widgets/         # Reusable components
│       ├── services/        # API & Firebase services
│       ├── globals.dart     # Theme & constants
│       └── main.dart        # App entry point
│
└── firebase/                # Firebase configuration
    ├── firestore.rules      # Database security rules
    └── storage.rules        # Storage security rules
```

## Features

### MVP Features (Current)
✅ User authentication (signup/login)  
✅ Create song letters (song + letter + photo + password)  
✅ Password-protected memory links  
✅ Cassette animation experience  
✅ Reply to song letters  
✅ Personal library of sent letters  

### Future Enhancements
⏳ Scheduled songs for special days  
⏳ Calendar view in library  
⏳ Push notifications for replies  
⏳ Advanced song search (YouTube/Spotify API)  
⏳ Public cassette feed  
⏳ Premium cassette themes  

## Getting Started

### Prerequisites

- Node.js (v16 or higher)
- Flutter SDK (v3.0 or higher)
- Firebase account
- Code editor (VS Code recommended)

### Backend Setup

1. Navigate to backend directory:
   ```bash
   cd backend_nodejs
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create `.env` file (copy from `.env.example`):
   ```bash
   cp .env.example .env
   ```

4. Configure Firebase Admin SDK:
   - Go to Firebase Console → Project Settings → Service Accounts
   - Generate new private key
   - Add credentials to `.env` file

5. Start the server:
   ```bash
   npm run dev
   ```

   Server runs on `http://localhost:3000`

### Frontend Setup

1. Navigate to Flutter directory:
   ```bash
   cd frontend_flutter
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase for Flutter:
   - Install FlutterFire CLI:
     ```bash
     dart pub global activate flutterfire_cli
     ```
   
   - Configure Firebase:
     ```bash
     flutterfire configure
     ```

4. Update API endpoint in `lib/services/api_service.dart`:
   ```dart
   static const String baseUrl = 'http://YOUR_BACKEND_URL/api';
   ```

5. Run the app:
   ```bash
   flutter run
   ```

### Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)

2. Enable services:
   - Authentication (Email/Password)
   - Firestore Database
   - Storage

3. Deploy security rules:
   ```bash
   firebase deploy --only firestore:rules,storage:rules
   ```

## API Endpoints

### Authentication
- `POST /api/auth/signup` - Create new user
- `POST /api/auth/login` - User login
- `GET /api/auth/profile/:uid` - Get user profile

### Song Letters
- `POST /api/songletter/create` - Create song letter
- `POST /api/songletter/:code` - Get song letter (with password)
- `GET /api/songletter/sent/:sender_id` - Get sent letters
- `POST /api/songletter/upload-photo` - Upload cover photo

### Replies
- `POST /api/reply/create` - Create reply
- `GET /api/reply/:song_letter_id` - Get replies for a letter
- `POST /api/reply/upload-photo` - Upload reply photo

## Database Collections

### users
```json
{
  "uid": "user123",
  "name": "User Name",
  "email": "user@example.com",
  "photo_url": "profile.jpg",
  "created_at": "2026-03-08T12:00:00Z"
}
```

### songLetters
```json
{
  "code": "ABC12345",
  "sender_id": "user123",
  "receiver_email": "friend@example.com",
  "song_link": "https://youtu.be/abc123",
  "letter": "This song reminds me of you...",
  "photo_url": "cover.jpg",
  "password_hash": "hashed_password",
  "color_theme": "amber-deep",
  "emotion_tag": "nostalgia",
  "created_at": "2026-03-08T12:00:00Z"
}
```

### replies
```json
{
  "song_letter_id": "letter123",
  "sender_id": "user456",
  "message": "Thank you! This is beautiful.",
  "song_link": "https://youtu.be/xyz456",
  "photo_url": "reply.jpg",
  "created_at": "2026-03-08T13:00:00Z"
}
```

## Design System

### Colors
- Cream: `#FDF6E3` - Background
- Warm White: `#FEFCF7` - Input backgrounds
- Brown Dark: `#3D2B1F` - Primary text
- Brown Mid: `#6B4226` - Secondary text
- Sepia: `#A0826D` - Muted text
- Amber Deep: `#C8860A` - Accent
- Amber Light: `#F5C842` - Highlights

### Fonts
- **Playfair Display** - Headings
- **Caveat** - Handwritten letters
- **Inter** - Body text

## Contributing

This is a personal project, but suggestions and feedback are welcome!

## License

MIT License - Feel free to use and modify for your own projects.

## Support

For issues or questions, please create an issue in the repository.

---

Built with ❤️ and nostalgia for mixtapes and handwritten notes.
