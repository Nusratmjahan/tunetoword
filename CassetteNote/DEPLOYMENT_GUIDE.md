# Deployment Guide - CassetteNote Backend

## Hosting Options for Your Backend

### Option 1: **Railway** (Easiest - Free Tier)

**Cost**: Free for hobby projects  
**Setup Time**: 10 minutes  

1. **Create account**: https://railway.app
2. **Install Railway CLI** (optional):
   ```bash
   npm install -g @railway/cli
   ```

3. **Deploy**:
   ```bash
   cd backend_nodejs
   railway login
   railway init
   railway add  # Add PostgreSQL database
   railway up
   ```

4. **Set environment variables** in Railway dashboard:
   ```
   DB_USER=<from railway>
   DB_PASSWORD=<from railway>
   DB_HOST=<from railway>
   DB_NAME=<from railway>
   DB_PORT=5432
   JWT_SECRET=your-secure-secret-key
   PORT=8000
   ```

5. **Get your URL**: Railway will give you a URL like `https://your-app.railway.app`

---

### Option 2: **Render** (Easy - Free Tier)

**Cost**: Free tier available  
**Setup Time**: 15 minutes  

1. **Create account**: https://render.com
2. **Create PostgreSQL Database**:
   - Click "New +" → "PostgreSQL"
   - Note down the connection string

3. **Create Web Service**:
   - Click "New +" → "Web Service"
   - Connect your GitHub repo (or manual deploy)
   - Build Command: `npm install`
   - Start Command: `node server.js`

4. **Environment Variables**:
   ```
   DATABASE_URL=<postgres connection string from step 2>
   JWT_SECRET=your-secure-secret-key
   PORT=10000
   ```

5. **Your URL**: `https://your-app-name.onrender.com`

---

### Option 3: **Heroku** (Popular)

**Cost**: $5/month minimum (no free tier anymore)  
**Setup Time**: 20 minutes  

1. **Install Heroku CLI**: https://devcenter.heroku.com/articles/heroku-cli

2. **Create app**:
   ```bash
   cd backend_nodejs
   heroku login
   heroku create your-app-name
   heroku addons:create heroku-postgresql:essential-0
   ```

3. **Set environment variables**:
   ```bash
   heroku config:set JWT_SECRET=your-secure-secret-key
   ```

4. **Deploy**:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git push heroku main
   ```

5. **Your URL**: `https://your-app-name.herokuapp.com`

---

### Option 4: **DigitalOcean App Platform** (Reliable)

**Cost**: $5/month for app + $15/month for database  
**Setup Time**: 25 minutes  

1. **Create account**: https://www.digitalocean.com
2. **Create App**:
   - Apps → Create App
   - Connect GitHub or upload code
   - Select Node.js runtime

3. **Add PostgreSQL Database**:
   - Add Database Component
   - Choose PostgreSQL
   - Note connection details

4. **Environment Variables**:
   ```
   DB_USER=${db.USERNAME}
   DB_PASSWORD=${db.PASSWORD}
   DB_HOST=${db.HOSTNAME}
   DB_NAME=${db.DATABASE}
   DB_PORT=${db.PORT}
   JWT_SECRET=your-secure-secret-key
   ```

5. **Your URL**: `https://your-app-name.ondigitalocean.app`

---

### Option 5: **VPS (Cheapest - Full Control)**

**Cost**: $4-6/month  
**Providers**: Contabo, Hetzner, Vultr, Linode  
**Setup Time**: 1-2 hours  

**One-time setup on Ubuntu VPS:**

```bash
# 1. Connect to your VPS
ssh root@your-server-ip

# 2. Install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# 3. Install PostgreSQL
apt-get update
apt-get install -y postgresql postgresql-contrib
sudo -u postgres psql -c "CREATE DATABASE cassettenote_db;"
sudo -u postgres psql -c "CREATE USER cassettenote WITH PASSWORD 'your-password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE cassettenote_db TO cassettenote;"

# 4. Upload your code
# (Use FileZilla or scp to transfer backend_nodejs folder)

# 5. Install dependencies
cd cassettenote/backend_nodejs
npm install

# 6. Install PM2 (keeps server running)
npm install -g pm2

# 7. Create .env file
nano .env
# Add your configuration

# 8. Run database creation SQL (from pgAdmin or psql)

# 9. Start server
pm2 start server.js --name cassettenote
pm2 startup
pm2 save

# 10. Install Nginx (reverse proxy)
apt-get install -y nginx

# 11. Configure Nginx
nano /etc/nginx/sites-available/cassettenote
```

**Nginx configuration:**
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Enable site
ln -s /etc/nginx/sites-available/cassettenote /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx

# 12. Install SSL (free)
apt-get install -y certbot python3-certbot-nginx
certbot --nginx -d your-domain.com
```

**Your URL**: `https://your-domain.com`

---

## 📱 Update Flutter App for Production

### Step 1: Update API URL

**Edit:** `lib/services/api_service_new.dart`

```dart
static const bool isProduction = true;  // Change to true
static const String prodUrl = 'https://your-actual-domain.com/api';
```

### Step 2: Build Release APK

```bash
cd frontend_flutter
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🎯 Recommended for Beginners: **Railway**

**Why?**
- ✅ Free tier
- ✅ Automatic HTTPS
- ✅ Built-in PostgreSQL
- ✅ GitHub integration
- ✅ No server management
- ✅ Easy scaling

**Quick Railway Deploy:**

1. Push your code to GitHub
2. Go to https://railway.app
3. "New Project" → "Deploy from GitHub"
4. Select `backend_nodejs` folder
5. Add PostgreSQL database (one click)
6. Done! Get your URL and update Flutter app

---

## 📋 Pre-Deployment Checklist

- [ ] Change `JWT_SECRET` in `.env` to a secure random string
- [ ] Run SQL schema in production database (create tables)
- [ ] Test all endpoints with production URL
- [ ] Update Flutter app `prodUrl` with your actual domain
- [ ] Set `isProduction = true` in Flutter
- [ ] Build release APK
- [ ] Test on physical device

---

## 🔐 Security Tips for Production

1. **Change JWT_SECRET**:
   ```bash
   node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
   ```

2. **Enable CORS only for your domain**:
   ```javascript
   // In server.js
   app.use(cors({
     origin: 'https://your-app-domain.com'
   }));
   ```

3. **Use environment variables** - never hardcode passwords

4. **Enable HTTPS** - most hosting platforms do this automatically

5. **Set up database backups** - most platforms offer automatic backups

---

## 💰 Cost Comparison

| Provider | Cost/Month | Free Tier | Database Included |
|----------|------------|-----------|-------------------|
| Railway | $0-5 | Yes (500h) | Yes |
| Render | $0-7 | Yes (limited) | $7/month |
| Heroku | $5-7 | No | $5/month |
| DigitalOcean | $5-20 | $200 credit | $15/month |
| VPS | $4-6 | No | Included |

---

## 🆘 Need Help?

1. **Railway Issues**: https://railway.app/discord
2. **Database connection errors**: Check environment variables
3. **Can't access API**: Check firewall/security groups
4. **Flutter can't connect**: Make sure URL uses `https://` in production

---

**Bottom line**: Start with **Railway** (free + easiest), then upgrade to VPS when you grow! 🚀
