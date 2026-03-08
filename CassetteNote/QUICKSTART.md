# CassetteNote - Quick Start Guide

## What is CassetteNote?

A nostalgic app to send songs with personal letters, like the old days of mixtapes and handwritten notes. 📼

## Quick Setup (5 minutes)

### 1. Prerequisites
- Node.js installed
- Flutter SDK installed
- Firebase account (free)

### 2. Backend
```bash
cd backend_nodejs
npm install
cp .env.example .env
# Edit .env with your Firebase credentials
npm start
```

### 3. Frontend
```bash
cd frontend_flutter
flutter pub get
flutterfire configure  # Link to your Firebase project
flutter run
```

### 4. Firebase
- Create project at console.firebase.google.com
- Enable: Authentication (Email/Password), Firestore, Storage
- Get credentials and add to backend `.env`

## That's it! 🎉

Open the app and create your first song letter!

## Full Documentation
- [README.md](README.md) - Complete project overview
- [SETUP.md](SETUP.md) - Detailed setup instructions

## Features
✅ Send songs with letters  
✅ Password-protected memories  
✅ Reply with songs  
✅ Personal library  

## Need Help?
Check SETUP.md or create an issue.
