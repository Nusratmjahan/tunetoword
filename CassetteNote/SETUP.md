# CassetteNote Setup Guide

## Step-by-Step Setup Instructions

### 1. Clone or Download the Project

Make sure you have the CassetteNote folder structure ready.

### 2. Firebase Project Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Enter project name: `CassetteNote` (or your choice)
4. Disable Google Analytics (optional for MVP)
5. Click "Create project"

#### Enable Firebase Services

**Authentication:**
1. Go to Build → Authentication
2. Click "Get started"
3. Enable "Email/Password" sign-in method

**Firestore Database:**
1. Go to Build → Firestore Database
2. Click "Create database"
3. Start in **test mode** (we'll add rules later)
4. Choose a location closest to your users
5. Click "Enable"

**Storage:**
1. Go to Build → Storage
2. Click "Get started"
3. Start in **test mode**
4. Click "Next" and "Done"

#### Get Firebase Configuration

**For Backend (Node.js):**
1. Go to Project Settings (⚙️ icon) → Service accounts
2. Click "Generate new private key"
3. Download the JSON file
4. Open the JSON file and copy these values:
   - `project_id`
   - `private_key`
   - `client_email`

**For Frontend (Flutter):**
1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Navigate to Flutter project:
   ```bash
   cd frontend_flutter
   ```

3. Run FlutterFire configuration:
   ```bash
   flutterfire configure
   ```

4. Select your Firebase project
5. Select platforms (iOS, Android, Web)

### 3. Backend Setup

#### Install Dependencies
```bash
cd backend_nodejs
npm install
```

#### Configure Environment Variables
1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` file:
   ```env
   PORT=3000
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
   FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
   NODE_ENV=development
   ```

   **Note:** For `FIREBASE_PRIVATE_KEY`, keep the newlines as `\n` in the string.

#### Test Backend
```bash
npm start
```

You should see:
```
🎵 CassetteNote server running on port 3000
```

Test the API:
```bash
curl http://localhost:3000
```

Expected response:
```json
{"message":"CassetteNote API is running 📼"}
```

### 4. Frontend Setup

#### Install Flutter Dependencies
```bash
cd frontend_flutter
flutter pub get
```

#### Update API Endpoint
1. Open `lib/services/api_service.dart`
2. Update the `baseUrl`:
   ```dart
   static const String baseUrl = 'http://localhost:3000/api';
   ```

   **For Android Emulator:** Use `http://10.0.2.2:3000/api`  
   **For iOS Simulator:** Use `http://localhost:3000/api`  
   **For Physical Device:** Use your computer's local IP (e.g., `http://192.168.1.5:3000/api`)

#### Run Flutter App
```bash
flutter run
```

Select your device/emulator when prompted.

### 5. Deploy Firebase Rules

#### Firestore Rules
```bash
cd firebase
firebase deploy --only firestore:rules
```

#### Storage Rules
```bash
firebase deploy --only storage:rules
```

### 6. Testing the App

#### Test Flow:
1. **Sign Up**: Create a new account
2. **Login**: Sign in with your credentials
3. **Create Song Letter**:
   - Paste a YouTube link
   - Write a letter
   - Set a password
   - Choose color and emotion
   - Click "Create"
4. **Share the Code**: Copy the generated code
5. **Open Memory** (test as receiver):
   - Use the code to access the letter
   - Enter the password
   - View cassette, letter, and song
6. **Reply**: Send a reply to the song letter
7. **View Library**: Check your sent letters

### 7. Common Issues & Solutions

#### Backend Issues

**Port already in use:**
```bash
# Change PORT in .env file to 3001 or another port
PORT=3001
```

**Firebase Admin SDK error:**
- Verify your credentials in `.env`
- Make sure `FIREBASE_PRIVATE_KEY` has proper newlines (`\n`)
- Check that serviceAccountKey JSON is valid

#### Frontend Issues

**API connection failed:**
- Make sure backend is running
- Update `baseUrl` with correct IP/port
- Check firewall settings

**Firebase initialization error:**
- Run `flutterfire configure` again
- Check `firebase_options.dart` exists
- Verify Firebase project is active

**Build errors:**
- Run `flutter clean`
- Run `flutter pub get`
- Run `flutter run` again

### 8. Development Tips

#### Hot Reload (Flutter)
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

#### Backend Auto-restart
Use nodemon for development:
```bash
npm run dev
```

#### Debugging
- Flutter: Use VS Code debugger or Android Studio
- Backend: Add `console.log()` statements

### 9. Next Steps

Once basic MVP works:
- [ ] Add scheduled songs feature
- [ ] Implement calendar view
- [ ] Add push notifications
- [ ] Integrate YouTube/Spotify search API
- [ ] Create public cassette feed
- [ ] Design premium themes

### 10. Production Deployment

#### Backend
- Deploy to services like:
  - Railway.app (easy)
  - Heroku
  - Google Cloud Run
  - AWS Elastic Beanstalk

#### Frontend
- Build release APK/IPA:
  ```bash
  flutter build apk --release
  flutter build ios --release
  ```

- Publish to:
  - Google Play Store
  - Apple App Store

#### Firebase
- Upgrade to Blaze plan for production
- Update CORS settings
- Enable monitoring

---

**Need help?** Create an issue in the repository or check the documentation.

Happy building! 📼🎵
