# 🆓 FREE Deployment Guide - Neon.tech + Render.com

**Total Cost: $0/month forever!**

## Architecture:
- **Database**: Neon.tech (Free PostgreSQL)
- **Backend**: Render.com (Free Node.js hosting)
- **Cost**: $0

---

## Step 1: Setup Database on Neon.tech (5 minutes)

### 1.1 Create Account
1. Go to https://neon.tech
2. Sign up with GitHub/Google
3. Click "Create a project"

### 1.2 Create Database
1. Project name: `cassettenote`
2. Database name: `cassettenote_db`
3. Region: Choose closest to you
4. Click "Create Project"

### 1.3 Get Connection String
You'll see something like:
```
postgresql://username:password@ep-xxx.region.aws.neon.tech/cassettenote_db?sslmode=require
```

**Save this!** You'll need it for Render.

### 1.4 Create Tables
1. Click "SQL Editor" in Neon dashboard
2. Copy and paste this SQL:

```sql
-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Song letters table
CREATE TABLE song_letters (
    id SERIAL PRIMARY KEY,
    code VARCHAR(8) UNIQUE NOT NULL,
    sender_id INTEGER REFERENCES users(id),
    receiver_email VARCHAR(255),
    song_link TEXT,
    letter TEXT,
    password_hash VARCHAR(64),
    color_theme VARCHAR(50),
    emotion_tag VARCHAR(50),
    photo_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_song_letters_code ON song_letters(code);
CREATE INDEX idx_song_letters_sender ON song_letters(sender_id);
CREATE INDEX idx_song_letters_created ON song_letters(created_at);
```

3. Click "Run" ✅

---

## Step 2: Deploy Backend on Render.com (10 minutes)

### 2.1 Prepare Your Code

**Update `backend_nodejs/server.js`** to use `DATABASE_URL`:

Find this section:
```javascript
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT || 5432,
});
```

Replace with:
```javascript
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});
```

### 2.2 Push to GitHub (if not already)

```bash
cd e:\flutterproject\TunetoWord\CassetteNote
git init
git add .
git commit -m "Backend with PostgreSQL"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/cassettenote.git
git push -u origin main
```

*(Skip if already on GitHub)*

### 2.3 Deploy on Render

1. Go to https://render.com
2. Sign up with GitHub
3. Click "New +" → "Web Service"
4. Connect your repository
5. Fill in:
   - **Name**: `cassettenote-backend`
   - **Region**: Choose closest to you
   - **Root Directory**: `backend_nodejs`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `node server.js`
   - **Instance Type**: `Free`

6. Click "Advanced" → Add Environment Variables:

```
DATABASE_URL = postgresql://username:password@ep-xxx.neon.tech/cassettenote_db?sslmode=require
JWT_SECRET = <generate random secret - see below>
PORT = 10000
NODE_ENV = production
```

**Generate JWT Secret:**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

7. Click "Create Web Service"
8. Wait 5-10 minutes for deployment
9. You'll get a URL like: `https://cassettenote-backend.onrender.com`

---

## Step 3: Update Flutter App (5 minutes)

### 3.1 Update API URL

**Edit:** `frontend_flutter/lib/services/api_service_new.dart`

```dart
static const bool isProduction = true;  // Change to true
static const String prodUrl = 'https://cassettenote-backend.onrender.com/api';  // Your Render URL
```

### 3.2 Build Release APK

```bash
cd frontend_flutter
flutter clean
flutter pub get
flutter build apk --release
```

APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🎉 You're Live!

**Your app is now running on completely FREE hosting!**

- Database: Neon.tech ✅
- Backend: Render.com ✅
- Cost: $0/month ✅

---

## ⚠️ Important Notes

### 1. Render Free Tier Limitation
**Your backend sleeps after 15 minutes of inactivity**

- First request after sleep: ~30 seconds to wake up
- Subsequent requests: Fast
- **Solution**: Use a free uptime monitor like:
  - UptimeRobot (https://uptimerobot.com) - ping every 5 minutes
  - Cron-job.org (https://cron-job.org) - ping every 15 minutes

Add this GET endpoint to your `server.js` for health checks:
```javascript
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});
```

Then ping: `https://cassettenote-backend.onrender.com/health`

### 2. Photo Storage on Render
**Render's free tier has ephemeral storage** - uploaded photos will be deleted when the service restarts.

**Solutions:**
1. **Use Cloudinary (Free tier - 25 GB)**
   - Sign up: https://cloudinary.com
   - 25 GB storage + 25 GB bandwidth/month
   - Easy integration

2. **Use ImgBB (Free)**
   - API: https://api.imgbb.com
   - Free image hosting

3. **Use Neon.tech to store base64** (not recommended for many photos)

**I can help integrate Cloudinary if you want!**

### 3. Database Limits (Neon.tech Free Tier)
- Storage: 0.5 GB (enough for ~500,000 song letters without photos)
- Compute: 191 hours/month (auto-pauses when not in use)
- If you exceed: Upgrade to Pro ($19/month)

---

## 🔧 Troubleshooting

### Backend won't start on Render
- Check logs in Render dashboard
- Verify `DATABASE_URL` is set correctly
- Make sure `PORT` is set to `10000`

### Can't connect from Flutter
- Make sure URL ends with `/api`
- Check `isProduction = true`
- Use `https://` (not `http://`)

### Database connection error
- Verify Neon connection string has `?sslmode=require`
- Check if database tables were created
- Test connection in Neon SQL Editor

### App takes 30+ seconds on first request
- Normal! Render free tier sleeps after 15 min
- Set up UptimeRobot to ping every 5 minutes

---

## 📈 When to Upgrade?

**Stay on free tier as long as:**
- You have < 1000 active users
- Database < 0.5 GB
- You're okay with 30s cold starts

**Upgrade when:**
- Need faster response (no cold starts)
- Storage > 0.5 GB
- Want custom domain
- Need proper photo storage

**Upgrade costs:**
- Render Web Service: $7/month (always-on)
- Neon Pro: $19/month (3 GB storage)
- **Total: $26/month for production**

---

## 🚀 Next Steps

1. ✅ Database on Neon.tech
2. ✅ Backend on Render.com
3. ✅ Flutter app updated
4. ✅ Release APK built
5. 🔄 Set up UptimeRobot to prevent sleeping
6. 📸 Consider Cloudinary for photos
7. 🌐 Add custom domain (optional - $12/year)

---

**You now have a production-ready backend costing $0! 🎉**
