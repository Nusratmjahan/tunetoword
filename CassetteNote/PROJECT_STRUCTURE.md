# CassetteNote - Project Structure

```
CassetteNote/
│
├── 📁 backend_nodejs/                      # Node.js REST API Backend
│   │
│   ├── 📄 package.json                     # Dependencies & scripts
│   ├── 📄 index.js                         # Express server entry point
│   ├── 📄 .env.example                     # Environment variables template
│   ├── 📄 .gitignore                       # Git ignore rules
│   │
│   ├── 📁 controllers/                     # Business logic
│   │   ├── authController.js               # User signup/login/profile
│   │   ├── songLetterController.js         # CRUD for song letters
│   │   └── replyController.js              # CRUD for replies
│   │
│   ├── 📁 routes/                          # API endpoints
│   │   ├── auth.js                         # /api/auth/* routes
│   │   ├── songletter.js                   # /api/songletter/* routes
│   │   └── reply.js                        # /api/reply/* routes
│   │
│   └── 📁 utils/                           # Helper functions
│       ├── firebase_admin.js               # Firebase Admin SDK setup
│       ├── hashPassword.js                 # Password hashing utilities
│       └── generateCode.js                 # Unique code generation
│
├── 📁 frontend_flutter/                    # Flutter Mobile App
│   │
│   ├── 📄 pubspec.yaml                     # Flutter dependencies
│   ├── 📄 .gitignore                       # Git ignore rules
│   │
│   └── 📁 lib/
│       │
│       ├── 📄 main.dart                    # App entry point & routing
│       ├── 📄 globals.dart                 # Colors, fonts, constants
│       │
│       ├── 📁 screens/                     # UI Screens
│       │   ├── login_screen.dart           # User login
│       │   ├── signup_screen.dart          # User registration
│       │   ├── home_screen.dart            # Main dashboard
│       │   ├── create_song_screen.dart     # Create song letter form
│       │   ├── memory_screen.dart          # View received letter (password gate)
│       │   └── library_screen.dart         # Grid of sent letters
│       │
│       ├── 📁 widgets/                     # Reusable Components
│       │   ├── cassette_widget.dart        # Cassette animation with photo
│       │   ├── song_embed_widget.dart      # Song player/thumbnail
│       │   └── reply_form.dart             # Reply input form
│       │
│       └── 📁 services/                    # API & Firebase Integration
│           ├── firebase_service.dart       # Firebase Auth wrapper
│           └── api_service.dart            # Backend API calls
│
├── 📁 firebase/                            # Firebase Configuration
│   ├── firebase.json                       # Firebase project config
│   ├── firestore.rules                     # Database security rules
│   └── storage.rules                       # Storage security rules
│
└── 📁 docs/                                # Documentation
    ├── 📄 README.md                        # Project overview
    ├── 📄 SETUP.md                         # Detailed setup guide
    └── 📄 QUICKSTART.md                    # Quick start (5 min)
```

## File Count Summary

### Backend (12 files)
- 3 Controller files
- 3 Route files
- 3 Utility files
- 3 Configuration files (package.json, .env.example, .gitignore)

### Frontend (18 files)
- 1 Main app file (main.dart)
- 1 Globals file (theme/constants)
- 6 Screen files
- 3 Widget files
- 2 Service files
- 2 Configuration files (pubspec.yaml, .gitignore)

### Firebase (3 files)
- Configuration & security rules

### Documentation (3 files)
- README, SETUP, QUICKSTART guides

**Total: 36 files created** ✅

## Key Features Implemented

### Authentication ✅
- User signup with email/password
- User login
- Profile management
- Firebase Auth integration

### Song Letters ✅
- Create song letter (song + letter + photo + password)
- Generate unique shareable code
- Password-protected access
- Color themes & emotion tags
- Photo upload to Firebase Storage

### Memory Experience ✅
- Password gate screen
- Cassette animation
- Handwritten letter display
- Song embed with thumbnail
- Reply functionality

### Library ✅
- Grid view of sent letters
- Letter details modal
- Pull-to-refresh

### Reply System ✅
- Text replies
- Optional song attachment
- Optional photo attachment
- Threaded conversations

## API Endpoints

### Auth Routes
```
POST   /api/auth/signup
POST   /api/auth/login
GET    /api/auth/profile/:uid
```

### Song Letter Routes
```
POST   /api/songletter/create
POST   /api/songletter/:code           (with password verification)
GET    /api/songletter/sent/:sender_id
POST   /api/songletter/upload-photo
```

### Reply Routes
```
POST   /api/reply/create
GET    /api/reply/:song_letter_id
POST   /api/reply/upload-photo
```

## Database Collections

### Firestore Collections
1. **users** - User profiles
2. **songLetters** - Song letters with metadata
3. **replies** - Replies to song letters

### Firebase Storage Buckets
1. **songletters/** - Cover photos for letters
2. **replies/** - Photos in replies

## Design System

### Color Palette
- Cream (#FDF6E3) - Background
- Warm White (#FEFCF7) - Cards
- Brown Dark (#3D2B1F) - Primary text
- Brown Mid (#6B4226) - Secondary text
- Sepia (#A0826D) - Muted text
- Amber Deep (#C8860A) - Accent
- Amber Light (#F5C842) - Highlights

### Typography
- **Playfair Display** - Headings
- **Caveat** - Handwritten letters
- **Inter** - Body text

## What's Next?

### Future Enhancements (Not in MVP)
- [ ] Scheduled songs for special dates
- [ ] Calendar view in library
- [ ] Push notifications
- [ ] Advanced song search (YouTube/Spotify API)
- [ ] Public cassette feed
- [ ] Premium themes
- [ ] Analytics dashboard

## Getting Started

See [SETUP.md](SETUP.md) for detailed instructions!

Quick start:
1. Setup Firebase project
2. Install backend dependencies
3. Configure `.env` file
4. Install Flutter dependencies
5. Run backend: `npm start`
6. Run frontend: `flutter run`

Happy coding! 📼🎵
