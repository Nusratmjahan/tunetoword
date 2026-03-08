# CassetteNote - Backend Migration Summary

## What Was Created

### ✅ Complete FastAPI Backend (`backend_fastapi/`)

**Core Files:**
- `main.py` - Main FastAPI application with all endpoints
- `models.py` - SQLAlchemy database models (User, SongLetter)
- `schemas.py` - Pydantic schemas for request/response validation
- `database.py` - Database configuration and session management
- `auth.py` - JWT authentication and password hashing
- `utils.py` - Helper functions (code generation, password hashing)

**Configuration:**
- `requirements.txt` - Python dependencies
- `.env.example` - Environment variables template
- `.gitignore` - Git ignore patterns
- `README.md` - Detailed backend documentation
- `setup.ps1` - Automated setup script for Windows
- `setup_database.sql` - PostgreSQL database schema

### ✅ Updated Flutter Services (`frontend_flutter/lib/services/`)

**New Service Files:**
- `api_service_new.dart` - HTTP client for FastAPI backend
- `auth_service_new.dart` - Authentication service (signup, login, logout)
- `songletter_service_new.dart` - Song letter operations wrapper

**Updated:**
- `pubspec.yaml` - Added `shared_preferences` package

### ✅ Documentation

- `MIGRATION_GUIDE.md` - Complete step-by-step migration guide

## Database Schema

### Users Table
```sql
users (
  id INTEGER PRIMARY KEY,
  email VARCHAR(255) UNIQUE,
  name VARCHAR(255),
  password_hash VARCHAR(255),  -- bcrypt
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
```

### Song Letters Table
```sql
song_letters (
  id INTEGER PRIMARY KEY,
  code VARCHAR(8) UNIQUE,       -- 8-character code
  sender_id INTEGER,            -- FK to users
  receiver_email VARCHAR(255),
  song_link VARCHAR(500),
  letter TEXT,
  password_hash VARCHAR(255),   -- SHA-256
  color_theme VARCHAR(50),
  emotion_tag VARCHAR(50),
  photo_url VARCHAR(500),
  created_at TIMESTAMP
)
```

## API Endpoints

### Authentication
- `POST /api/auth/signup` - Register new user
- `POST /api/auth/login` - Login and get JWT token
- `GET /api/auth/me` - Get current user info (requires auth)

### Photos
- `POST /api/photos/upload` - Upload photo (requires auth)

### Song Letters
- `POST /api/songletters/create` - Create song letter (requires auth)
- `POST /api/songletters/access` - Access song letter with code + password
- `GET /api/songletters/sent` - Get user's sent letters (requires auth)

## Quick Start

### 1. Setup Backend (10 minutes)

```powershell
# Navigate to backend
cd e:\flutterproject\TunetoWord\CassetteNote\backend_fastapi

# Run setup script
.\setup.ps1

# Create database
psql -U postgres
CREATE DATABASE cassettenote_db;
\q

# Edit .env file
notepad .env
# Update DATABASE_URL with your PostgreSQL password
# Update SECRET_KEY (generate with: python -c "import secrets; print(secrets.token_urlsafe(32))")

# Start server
python main.py
```

Backend will be running at: http://localhost:8000
API docs: http://localhost:8000/docs

### 2. Update Flutter App (5 minutes)

```bash
# Install new dependencies
cd e:\flutterproject\TunetoWord\CassetteNote\frontend_flutter
flutter pub get

# Find your computer's IP address
ipconfig
# Look for IPv4 Address (e.g., 192.168.1.105)

# Edit api_service_new.dart
# Update baseUrl with your IP:
# static const String baseUrl = 'http://192.168.1.105:8000/api';
```

### 3. Test the App

```bash
# Make sure backend is running (python main.py)

# Run Flutter app
flutter run -d R58W50GWQEE

# Test flow:
# 1. Sign up with new account
# 2. Login
# 3. Create song letter with photo
# 4. Access with code
```

## Key Differences from Firebase

### Authentication
**Before (Firebase):**
```dart
final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email, 
  password: password
);
String userId = result.user!.uid;  // Random Firebase UID
```

**After (FastAPI):**
```dart
final result = await ApiService.login(
  email: email, 
  password: password
);
String token = result['access_token'];  // JWT token (stored automatically)
int userId = result['user']['id'];      // Sequential integer ID
```

### Data Storage
**Before (Firebase Realtime Database):**
```dart
await FirebaseDatabase.instance
  .ref('songLetters')
  .push()
  .set(data);
```

**After (PostgreSQL):**
```dart
await ApiService.createSongLetter(/* data */);
// Handled by FastAPI, stored in PostgreSQL
```

### Photo Upload
**Before (Firebase Storage):**
```dart
final ref = FirebaseStorage.instance.ref('photos/$filename');
await ref.putFile(file);
final url = await ref.getDownloadURL();
```

**After (FastAPI):**
```dart
final result = await ApiService.uploadPhoto(file);
final url = result['url'];  // e.g., "/uploads/photos/123.jpg"
// Full URL: http://YOUR_IP:8000/uploads/photos/123.jpg
```

## Benefits

✅ **No More Firebase Limitations**
- Unlimited users (no more free tier limits)
- No more quota restrictions
- No more Firebase billing surprises

✅ **Complete Control**
- Own your data
- Customize business logic
- Direct SQL queries
- Easy backups

✅ **Better Performance**
- PostgreSQL is faster for complex queries
- Direct database access
- No Firebase SDK overhead

✅ **Cost Effective**
- Free hosting options available
- PostgreSQL is free
- No per-user costs

✅ **Developer Friendly**
- Interactive API docs (Swagger UI)
- Easy testing
- Standard REST API
- Type-safe with Pydantic

## Migration Checklist

- [ ] PostgreSQL installed and running
- [ ] Database created (`cassettenote_db`)
- [ ] Backend dependencies installed
- [ ] `.env` configured with correct credentials
- [ ] Backend server starts successfully
- [ ] Can access API docs at `/docs`
- [ ] Flutter dependencies updated (`flutter pub get`)
- [ ] API base URL updated with correct IP
- [ ] Test signup works
- [ ] Test login works
- [ ] Test photo upload works
- [ ] Test create song letter works
- [ ] Test access song letter works
- [ ] Old Firebase services can be removed (optional)

## Troubleshooting

### Backend won't start
**Error: `connection refused`**
- Check PostgreSQL is running:
  ```bash
  # Windows
  Get-Service postgresql*
  
  # If stopped, start it:
  Start-Service postgresql-x64-14  # or your version
  ```

**Error: `database does not exist`**
- Create the database:
  ```bash
  psql -U postgres -c "CREATE DATABASE cassettenote_db;"
  ```

### Flutter can't connect
**Error: `Connection refused` or `Failed to connect`**
- Verify backend is running: `curl http://localhost:8000`
- Check firewall: Allow port 8000
- Use correct IP (not localhost on physical device)
- For Android emulator: Use `http://10.0.2.2:8000`
- For physical device: Use `http://YOUR_IP:8000`

**Find your IP:**
```bash
ipconfig  # Windows
# Look for IPv4 Address under your active network adapter
```

### Photos not loading
**Photos upload but don't display**
- Check photo URL format
- Ensure full URL is used: `http://YOUR_IP:8000/uploads/photos/file.jpg`
- Backend must be running to serve photos
- Check file was actually saved in `uploads/photos/` directory

## Next Steps

After successful migration:

1. **Remove Firebase (Optional)**
   - Remove Firebase packages from `pubspec.yaml`
   - Delete `firebase_options.dart`
   - Remove Firebase config files
   - Clean up old service files

2. **Deploy to Production**
   - Choose hosting provider (DigitalOcean, Heroku, AWS)
   - Set up cloud storage for photos (AWS S3, Cloudinary)
   - Configure domain name
   - Set up SSL certificate
   - Update Flutter app with production URL

3. **Enhance Security**
   - Add rate limiting
   - Implement refresh tokens
   - Add request validation
   - Set up logging
   - Add monitoring

4. **Optimize Performance**
   - Add database indexes
   - Implement caching (Redis)
   - Optimize photo compression
   - Add CDN for photos

## Support

For detailed instructions, see:
- `backend_fastapi/README.md` - Backend documentation
- `MIGRATION_GUIDE.md` - Step-by-step migration guide

API Documentation: http://localhost:8000/docs

## File Structure

```
CassetteNote/
├── backend_fastapi/          ← NEW FastAPI backend
│   ├── main.py              ← Main API application
│   ├── models.py            ← Database models
│   ├── schemas.py           ← API schemas
│   ├── database.py          ← DB configuration
│   ├── auth.py              ← Authentication
│   ├── utils.py             ← Helper functions
│   ├── requirements.txt     ← Python dependencies
│   ├── .env.example         ← Environment template
│   ├── .gitignore           ← Git ignore
│   ├── README.md            ← Backend docs
│   ├── setup.ps1            ← Setup script
│   ├── setup_database.sql   ← DB schema
│   └── uploads/             ← Photo storage (created on first upload)
│       └── photos/
│
├── frontend_flutter/
│   └── lib/
│       └── services/
│           ├── api_service_new.dart        ← NEW API client
│           ├── auth_service_new.dart       ← NEW Auth service
│           ├── songletter_service_new.dart ← NEW Song letter service
│           ├── firebase_service.dart       ← OLD (can remove later)
│           └── songletter_service.dart     ← OLD (can remove later)
│
└── MIGRATION_GUIDE.md       ← Detailed migration guide
```

---

**Ready to start?** Follow the Quick Start section above!

**Need help?** Check the MIGRATION_GUIDE.md for detailed troubleshooting.
