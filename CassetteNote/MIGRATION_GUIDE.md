# Migration Guide: Firebase to FastAPI + PostgreSQL

## Overview
This guide walks you through migrating CassetteNote from Firebase to FastAPI backend with PostgreSQL database.

## Prerequisites
- PostgreSQL installed on your system
- Python 3.8+ installed
- Flutter project set up

## Step-by-Step Migration

### Phase 1: Backend Setup (30 minutes)

#### 1.1 Create PostgreSQL Database

Open pgAdmin or use psql command line:

```sql
CREATE DATABASE cassettenote_db;
```

Or using command line:
```bash
# Windows
psql -U postgres
CREATE DATABASE cassettenote_db;
\q

# Verify connection
psql -U postgres -d cassettenote_db
\l
```

#### 1.2 Set up FastAPI Backend

```bash
# Navigate to backend directory
cd e:\flutterproject\TunetoWord\CassetteNote\backend_fastapi

# Create virtual environment
python -m venv venv

# Activate virtual environment
.\venv\Scripts\activate  # Windows
# source venv/bin/activate  # Linux/Mac

# Install dependencies
pip install -r requirements.txt
```

#### 1.3 Configure Environment Variables

```bash
# Copy example env file
copy .env.example .env

# Edit .env file with your settings
```

Update `.env` with your PostgreSQL credentials:
```env
DATABASE_URL=postgresql://postgres:YOUR_POSTGRES_PASSWORD@localhost:5432/cassettenote_db
SECRET_KEY=your-super-secret-key-please-change-this
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
UPLOAD_DIR=uploads/photos
MAX_FILE_SIZE=5242880
HOST=0.0.0.0
PORT=8000
```

**To generate a secure SECRET_KEY:**
```python
import secrets
print(secrets.token_urlsafe(32))
```

#### 1.4 Start the Backend Server

```bash
python main.py
```

Or:
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**Verify backend is running:**
- Visit: http://localhost:8000
- API Docs: http://localhost:8000/docs

### Phase 2: Flutter App Migration (45 minutes)

#### 2.1 Update Dependencies

Edit `pubspec.yaml`:

```yaml
dependencies:
  # Add shared_preferences for token storage
  shared_preferences: ^2.2.2
  
  # http is already present
  http: ^1.1.2
```

Run:
```bash
flutter pub get
```

#### 2.2 Update API Base URL

Edit `lib/services/api_service_new.dart`:

```dart
// For physical device testing, use your computer's local IP
static const String baseUrl = 'http://192.168.X.X:8000/api';

// Find your IP:
// Windows: ipconfig -> look for IPv4 Address
// Linux/Mac: ifconfig -> look for inet
```

**Finding your local IP:**
```bash
# Windows
ipconfig
# Look for "IPv4 Address" under your active network adapter
# Example: 192.168.1.105

# Update api_service_new.dart:
static const String baseUrl = 'http://192.168.1.105:8000/api';
```

#### 2.3 Replace Service Imports

You have two options:

**Option A: Gradual Migration (Recommended)**
Keep old Firebase services and use new ones selectively:

```dart
// In files where you want to use new backend:
import 'package:cassettenote/services/auth_service_new.dart';
import 'package:cassettenote/services/songletter_service_new.dart';

// Update provider:
final authService = Provider.of<AuthService>(context);
```

**Option B: Complete Replacement**
Replace all imports at once:

1. **Rename old files:**
   ```bash
   cd lib/services
   mv firebase_service.dart firebase_service.old.dart
   mv songletter_service.dart songletter_service.old.dart
   ```

2. **Rename new files:**
   ```bash
   mv auth_service_new.dart auth_service.dart
   mv songletter_service_new.dart songletter_service.dart
   ```

3. **Update class names in auth_service.dart:**
   - Change `AuthService` class to match what you were using
   - Or update all imports in screens

#### 2.4 Update Main App Initialization

Edit `lib/main.dart`:

**Remove Firebase initialization:**
```dart
// Remove:
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Remove from main():
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

**Add API initialization:**
```dart
import 'package:cassettenote/services/api_service_new.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API service
  await ApiService.init();
  
  runApp(const MyApp());
}
```

**Update providers:**
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthService()),  // new auth service
    // ... other providers
  ],
  child: MyApp(),
)
```

#### 2.5 Update Individual Screens

**Example: Login Screen**

Before (Firebase):
```dart
final firebaseService = Provider.of<FirebaseService>(context, listen: false);
final result = await firebaseService.login(
  email: email,
  password: password,
);
```

After (FastAPI):
```dart
final authService = Provider.of<AuthService>(context, listen: false);
final result = await authService.login(
  email: email,
  password: password,
);
```

**Example: Create Song Letter Screen**

Before (Firebase):
```dart
// Upload photo
final photoResult = await SongLetterService.uploadPhoto(
  photoFile: _selectedPhoto!,
  userId: currentUser.uid,
);

// Create letter
final result = await SongLetterService.createSongLetter(
  senderId: currentUser.uid,
  songLink: _songLinkController.text,
  letter: _letterController.text,
  password: _passwordController.text,
  photoUrl: photoResult['url'],
);
```

After (FastAPI):
```dart
// Upload photo
final photoResult = await SongLetterServiceNew.uploadPhoto(
  photoFile: _selectedPhoto!,
);

// Create letter
final result = await SongLetterServiceNew.createSongLetter(
  senderId: authService.currentUser!['id'].toString(),
  songLink: _songLinkController.text,
  letter: _letterController.text,
  password: _passwordController.text,
  photoUrl: photoResult['url'],
);
```

#### 2.6 Update Photo URLs

**Update image rendering:**

Before (Firebase Storage URL):
```dart
CachedNetworkImage(
  imageUrl: photoUrl,  // Full Firebase Storage URL
)
```

After (FastAPI URL):
```dart
CachedNetworkImage(
  imageUrl: 'http://192.168.X.X:8000$photoUrl',  // Prepend base URL
)
```

Or better, create a helper:
```dart
String getFullPhotoUrl(String? photoUrl) {
  if (photoUrl == null) return '';
  if (photoUrl.startsWith('http')) return photoUrl;
  return 'http://192.168.X.X:8000$photoUrl';
}
```

### Phase 3: Testing (30 minutes)

#### 3.1 Test Backend Endpoints

Use the interactive API docs: http://localhost:8000/docs

1. **Test Signup:**
   - Click on `POST /api/auth/signup`
   - Try creating a user
   - Copy the access token

2. **Test Login:**
   - Click on `POST /api/auth/login`
   - Login with created user
   - Verify token is returned

3. **Test Authenticated Endpoints:**
   - Click "Authorize" button (top right)
   - Paste the token
   - Test photo upload
   - Test create song letter
   - Test get sent letters

#### 3.2 Test Flutter App

```bash
# Make sure backend is running
cd backend_fastapi
python main.py

# In another terminal, run Flutter app
cd frontend_flutter
flutter run -d R58W50GWQEE  # Your device ID
```

**Test Flow:**
1. ✅ Sign up with new account
2. ✅ Login with credentials
3. ✅ Upload a photo
4. ✅ Create a song letter with photo
5. ✅ Access song letter with code
6. ✅ View sent letters

### Phase 4: Remove Firebase Dependencies (Optional)

Once everything works, you can remove Firebase:

#### 4.1 Remove Firebase Packages

Edit `pubspec.yaml`:
```yaml
dependencies:
  # Remove these:
  # firebase_core: ^4.5.0
  # firebase_auth: ^6.2.0
  # firebase_database: ^12.1.4
  # firebase_storage: ^13.1.0
  # google_sign_in: ^6.2.1
```

Run:
```bash
flutter pub get
flutter clean
```

#### 4.2 Remove Firebase Configuration Files

```bash
# Android
rm android/app/google-services.json

# iOS
rm ios/Runner/GoogleService-Info.plist

# Firebase config
rm lib/firebase_options.dart
```

#### 4.3 Remove Firebase Initialization from Android

Edit `android/app/build.gradle`:
```gradle
// Remove this line:
// apply plugin: 'com.google.gms.google-services'
```

Edit `android/build.gradle`:
```gradle
dependencies {
    // Remove this line:
    // classpath 'com.google.gms:google-services:4.3.15'
}
```

### Phase 5: Production Deployment

#### 5.1 Deploy Backend

**Options:**
- **DigitalOcean App Platform** (easiest)
- **Heroku** (with PostgreSQL addon)
- **AWS EC2** (more control)
- **Google Cloud Run** (serverless)
- **Railway** (simple deployment)

**Example: DigitalOcean App Platform**

1. Create `Procfile`:
   ```
   web: uvicorn main:app --host 0.0.0.0 --port $PORT
   ```

2. Create `runtime.txt`:
   ```
   python-3.11
   ```

3. Push to GitHub

4. Connect to DigitalOcean App Platform

5. Add PostgreSQL database

6. Set environment variables in dashboard

#### 5.2 Update Flutter App with Production URL

```dart
// api_service_new.dart
static const String baseUrl = 'https://your-api.com/api';
```

#### 5.3 Photo Storage for Production

For production, implement cloud storage:

**Option 1: AWS S3**
```python
# Install: pip install boto3

import boto3
s3 = boto3.client('s3')
s3.upload_fileobj(file, bucket_name, file_name)
```

**Option 2: DigitalOcean Spaces**
```python
# Similar to S3, compatible API
```

**Option 3: Cloudinary**
```python
# Install: pip install cloudinary
import cloudinary.uploader
```

## Troubleshooting

### Backend Issues

**Database Connection Error:**
```
Connection refused: Could not connect to server
```
**Solution:**
- Verify PostgreSQL is running: `pg_ctl status`
- Check credentials in `.env`
- Ensure database exists: `psql -U postgres -l`

**Port Already in Use:**
```
Address already in use: 8000
```
**Solution:**
```bash
# Windows
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:8000 | xargs kill -9
```

### Flutter App Issues

**Cannot Connect to Backend:**
- Verify backend is running: `curl http://localhost:8000`
- Check firewall settings
- Use correct IP address (not localhost on physical device)
- For Android emulator, use `10.0.2.2` instead of `localhost`

**Token Not Persisting:**
- Check SharedPreferences initialization
- Verify `ApiService.init()` is called in `main()`

**Photo Upload Fails:**
- Check file size (max 5MB)
- Verify image format (JPEG/PNG)
- Check internet permissions in AndroidManifest.xml

## Benefits of This Migration

✅ **No More Firebase Costs** - Free hosting with unlimited users
✅ **Full Control** - Complete control over your data and logic
✅ **Better Performance** - PostgreSQL is faster for complex queries
✅ **Easier Testing** - API docs with Swagger UI
✅ **Scalability** - Can handle millions of users
✅ **Data Portability** - Easy to backup and migrate data
✅ **SQL Power** - Advanced queries and analytics

## Rollback Plan

If you need to rollback to Firebase:

1. Keep old service files with `.old` extension
2. Don't delete Firebase config files immediately
3. Test thoroughly before removing Firebase packages
4. Keep a backup of Firebase data

## Support

Need help? Check:
- Backend API docs: http://localhost:8000/docs
- FastAPI documentation: https://fastapi.tiangolo.com
- PostgreSQL docs: https://www.postgresql.org/docs

## Next Steps

After migration:
1. Set up automated backups for PostgreSQL
2. Implement rate limiting
3. Add logging and monitoring
4. Set up CI/CD pipeline
5. Implement caching (Redis)
6. Add analytics
