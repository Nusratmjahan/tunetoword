# CassetteNote Backend - FastAPI + PostgreSQL

## Setup Instructions

### 1. Database Setup

First, create the PostgreSQL database. Open pgAdmin or psql:

```sql
CREATE DATABASE cassettenote_db;
```

Or using psql command:
```bash
psql -U postgres
CREATE DATABASE cassettenote_db;
\q
```

### 2. Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd e:\flutterproject\TunetoWord\CassetteNote\backend_fastapi
   ```

2. **Create virtual environment:**
   ```bash
   python -m venv venv
   .\venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment:**
   - Copy `.env.example` to `.env`
   - Update PostgreSQL credentials:
   ```
   DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/cassettenote_db
   SECRET_KEY=generate-a-random-secret-key-here
   ```

5. **Run the server:**
   ```bash
   python main.py
   ```
   
   Or with uvicorn directly:
   ```bash
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```

The API will be available at:
- API: http://localhost:8000
- Interactive docs: http://localhost:8000/docs
- Alternative docs: http://localhost:8000/redoc

### 3. Database Tables

The following tables will be created automatically on first run:

**users**
- id (Primary Key)
- email (Unique)
- name
- password_hash (bcrypt)
- created_at
- updated_at

**song_letters**
- id (Primary Key)
- code (Unique, 8 characters)
- sender_id (Foreign Key to users)
- receiver_email
- song_link
- letter (Text)
- password_hash (SHA-256)
- color_theme
- emotion_tag
- photo_url
- created_at

### 4. API Endpoints

**Authentication:**
- POST `/api/auth/signup` - Create new user account
- POST `/api/auth/login` - Login and get JWT token
- GET `/api/auth/me` - Get current user info

**Photos:**
- POST `/api/photos/upload` - Upload photo (requires auth)

**Song Letters:**
- POST `/api/songletters/create` - Create song letter (requires auth)
- POST `/api/songletters/access` - Access song letter with code & password
- GET `/api/songletters/sent` - Get all sent letters (requires auth)

### 5. Flutter Integration

Update your Flutter app to use the new backend:

1. **Update pubspec.yaml** - Add http package:
   ```yaml
   dependencies:
     http: ^1.1.0
   ```

2. **Replace Firebase services** with API calls to:
   ```
   http://localhost:8000/api/
   ```

3. **For production**, deploy to a server and update the base URL.

### 6. Photo Storage

Photos are stored locally in the `uploads/photos/` directory and served via FastAPI's StaticFiles at `/uploads/photos/{filename}`.

For production, consider:
- Using cloud storage (AWS S3, DigitalOcean Spaces)
- Adding CDN for better performance
- Implementing proper backup strategy

### 7. Testing

Test the API using the interactive docs:
1. Go to http://localhost:8000/docs
2. Try the signup endpoint
3. Try the login endpoint (copy the token)
4. Click "Authorize" button and paste the token
5. Test protected endpoints

### 8. Migration from Firebase

**Data Migration Steps:**
1. Export data from Firebase (if you have existing data)
2. Transform the data to match PostgreSQL schema
3. Import using provided migration script (optional)

**Flutter App Changes:**
- Replace Firebase SDK calls with HTTP requests
- Store JWT token for authentication
- Update photo URLs to point to FastAPI server

