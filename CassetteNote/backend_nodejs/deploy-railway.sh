#!/bin/bash
# Quick deployment script for Railway

echo "🚀 Deploying CassetteNote Backend to Railway..."
echo ""

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null
then
    echo "📦 Installing Railway CLI..."
    npm install -g @railway/cli
fi

# Login to Railway
echo "🔐 Please login to Railway..."
railway login

# Initialize project
echo "📝 Initializing Railway project..."
railway init

# Link PostgreSQL
echo "🐘 Adding PostgreSQL database..."
railway add --database postgres

# Deploy
echo "🚀 Deploying..."
railway up

# Get domain
echo "✅ Deployment complete!"
echo ""
echo "📋 Next steps:"
echo "1. Go to Railway dashboard: https://railway.app/dashboard"
echo "2. Copy your app URL (e.g., https://yourapp.railway.app)"
echo "3. Update Flutter app:"
echo "   - Open: lib/services/api_service_new.dart"
echo "   - Change: prodUrl = 'https://your-railway-url.railway.app/api'"
echo "   - Change: isProduction = true"
echo "4. Build release APK: flutter build apk --release"
echo ""
echo "🎉 Your backend is now live!"
