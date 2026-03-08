# 🚀 Deployment Checklist

## Quick Guide: FREE Hosting with Neon.tech + Render.com

### ✅ Prerequisites
- [ ] GitHub account
- [ ] Git installed on your computer
- [ ] Your backend code is working locally

---

## Part 1: Database Setup (Neon.tech) - 5 minutes

### Step 1: Create Neon Account
- [ ] Go to https://neon.tech
- [ ] Sign up (GitHub/Google)
- [ ] Create new project: "cassettenote"

### Step 2: Setup Database
- [ ] Database name: `cassettenote_db`
- [ ] Copy connection string (looks like: `postgresql://user:pass@ep-xxx.neon.tech/cassettenote_db?sslmode=require`)
- [ ] Open SQL Editor in Neon dashboard

### Step 3: Create Tables
- [ ] Copy SQL from `DEPLOY_FREE.md` (Step 1.4)
- [ ] Paste into SQL Editor
- [ ] Click "Run"
- [ ] Verify tables created: `users` and `song_letters`

**✅ Database is ready!**

---

## Part 2: Push Code to GitHub - 3 minutes

```bash
cd e:\flutterproject\TunetoWord\CassetteNote
git init
git add .
git commit -m "Initial commit"
git branch -M main
```

- [ ] Create new repo on GitHub: https://github.com/new
- [ ] Name it: `cassettenote` (or any name)
- [ ] Don't add README/gitignore (we already have files)

```bash
git remote add origin https://github.com/YOUR_USERNAME/cassettenote.git
git push -u origin main
```

**✅ Code is on GitHub!**

---

## Part 3: Deploy Backend (Render.com) - 10 minutes

### Step 1: Create Render Account
- [ ] Go to https://render.com
- [ ] Sign up with GitHub
- [ ] Authorize Render to access your repositories

### Step 2: Create Web Service
- [ ] Click "New +" → "Web Service"
- [ ] Select your repository: `cassettenote`
- [ ] Fill in settings:
  - **Name**: `cassettenote-backend` (or any name)
  - **Region**: Choose closest to you
  - **Root Directory**: `backend_nodejs`
  - **Environment**: `Node`
  - **Build Command**: `npm install`
  - **Start Command**: `node server.js`
  - **Instance Type**: `Free`

### Step 3: Add Environment Variables
Click "Advanced" and add these:

```
DATABASE_URL = <paste your Neon connection string>
JWT_SECRET = <generate below>
PORT = 10000
NODE_ENV = production
```

**Generate JWT Secret (in terminal):**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

- [ ] Environment variables added
- [ ] Click "Create Web Service"
- [ ] Wait 5-10 minutes for deployment
- [ ] Check logs for "✅ Database connected successfully!"

### Step 4: Get Your Backend URL
- [ ] Copy your URL (e.g., `https://cassettenote-backend.onrender.com`)
- [ ] Test it: Open in browser - should see JSON response

**✅ Backend is deployed!**

---

## Part 4: Update Flutter App - 5 minutes

### Step 1: Update API URL
Open: `frontend_flutter/lib/services/api_service_new.dart`

Change these lines:
```dart
static const bool isProduction = true;  // Change to true
static const String prodUrl = 'https://YOUR-RENDER-URL.onrender.com/api';  // Add /api at end
```

- [ ] Updated `isProduction = true`
- [ ] Updated `prodUrl` with your Render URL
- [ ] Made sure URL ends with `/api`

### Step 2: Build Release APK
```bash
cd frontend_flutter
flutter clean
flutter pub get
flutter build apk --release
```

- [ ] Build completed successfully
- [ ] APK location: `build/app/outputs/flutter-apk/app-release.apk`

**✅ App is ready!**

---

## Part 5: Test Everything - 5 minutes

### Test Backend
- [ ] Open your Render URL in browser
- [ ] Should see JSON with "CassetteNote API"

### Test Health Endpoint
- [ ] Open: `https://your-render-url.onrender.com/health`
- [ ] Should see: `{"status":"ok",...}`

### Install APK on Phone
- [ ] Transfer APK to phone
- [ ] Install it
- [ ] Try signing up
- [ ] Try creating a song letter
- [ ] Check if data appears in Neon.tech SQL editor

**First request might take 30 seconds (Render waking up)**

---

## Part 6: Keep Backend Awake (Optional) - 5 minutes

To prevent 30-second cold starts:

### Option 1: UptimeRobot (Recommended)
- [ ] Go to https://uptimerobot.com
- [ ] Sign up (free)
- [ ] Click "Add New Monitor"
- [ ] Type: "HTTP(s)"
- [ ] URL: `https://your-render-url.onrender.com/health`
- [ ] Interval: 5 minutes
- [ ] Click "Create Monitor"

### Option 2: Cron-job.org
- [ ] Go to https://cron-job.org
- [ ] Sign up
- [ ] Create cronjob to ping your health endpoint every 15 minutes

**✅ Backend stays awake!**

---

## 🎉 You're Done!

Your app is now:
- ✅ Using PostgreSQL (Neon.tech)
- ✅ Backend deployed (Render.com)
- ✅ Completely FREE ($0/month)
- ✅ Production-ready

---

## ⚠️ Known Limitations (Free Tier)

### Render.com:
- Backend sleeps after 15 min inactivity
- First request after sleep: ~30 seconds
- Solution: UptimeRobot pings every 5 minutes

### Neon.tech:
- Storage: 0.5 GB (enough for ~500k letters)
- Compute: 191 hours/month
- Auto-pauses when idle (wakes instantly)

### Photo Storage:
- Files on Render are ephemeral (deleted on restart)
- Solution: Use Cloudinary (25GB free)

---

## 🔧 Troubleshooting

### Backend won't connect
- Check Render logs
- Verify DATABASE_URL has `?sslmode=require`
- Check environment variables are set

### Flutter app can't reach backend
- Make sure URL uses `https://`
- Check URL ends with `/api`
- Verify `isProduction = true`

### Database errors
- Check if tables were created in Neon SQL editor
- Verify connection string is correct

### "Invalid token" errors
- Make sure JWT_SECRET is set on Render
- JWT_SECRET must be the same on all deployments

---

## 📈 When to Upgrade?

Stay FREE as long as:
- < 1000 active users
- Database < 0.5 GB
- OK with 30s cold starts

Upgrade when you need:
- No cold starts (always-on)
- More storage
- Custom domain
- Faster performance

**Paid options: $7-26/month total**

---

## 🆘 Need Help?

1. Check Render logs (Dashboard → your service → Logs)
2. Check Neon SQL Editor (test queries)
3. Test endpoints with Postman/browser
4. Check Flutter console for errors

---

**Your app is now LIVE on FREE hosting! 🚀**
