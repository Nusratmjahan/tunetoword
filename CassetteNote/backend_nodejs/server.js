const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const sharp = require('sharp');
const path = require('path');
const fs = require('fs');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 8000;

// Middleware
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads'));

// PostgreSQL connection
// Support both DATABASE_URL (for Neon.tech/Render) and individual vars (for local)
const pool = process.env.DATABASE_URL
  ? new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: {
        rejectUnauthorized: false
      }
    })
  : new Pool({
      user: process.env.DB_USER || 'postgres',
      host: process.env.DB_HOST || 'localhost',
      database: process.env.DB_NAME || 'cassettenote_db',
      password: process.env.DB_PASSWORD || 'devmim2001',
      port: process.env.DB_PORT || 5432,
    });

// Test database connection
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('❌ Database connection failed:', err.message);
  } else {
    console.log('✅ Database connected successfully!');
  }
});

// Create uploads directory
const uploadsDir = path.join(__dirname, 'uploads', 'photos');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Multer configuration for file uploads
const storage = multer.memoryStorage();
const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only images are allowed'));
    }
  }
});

// JWT middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ detail: 'No token provided' });
  }

  jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key', (err, user) => {
    if (err) {
      return res.status(403).json({ detail: 'Invalid token' });
    }
    req.userId = user.id;
    next();
  });
};

// Helper function to generate unique code
function generateCode() {
  const chars = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
  let code = '';
  for (let i = 0; i < 8; i++) {
    code += chars[Math.floor(Math.random() * chars.length)];
  }
  return code;
}

// Helper function to hash password with SHA-256
function hashPasswordSHA256(password) {
  const crypto = require('crypto');
  return crypto.createHash('sha256').update(password).digest('hex');
}

// ==================== ROUTES ====================

// Root route
app.get('/', (req, res) => {
  res.json({
    message: 'CassetteNote API (Node.js + PostgreSQL)',
    version: '1.0.0',
    database: 'PostgreSQL',
    endpoints: {
      auth: '/api/auth/*',
      photos: '/api/photos/*',
      songletters: '/api/songletters/*'
    }
  });
});

// Health check endpoint (for uptime monitoring)
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// ==================== AUTH ROUTES ====================

// Signup
app.post('/api/auth/signup', async (req, res) => {
  try {
    const { email, password, name } = req.body;

    if (!email || !password || !name) {
      return res.status(400).json({ detail: 'All fields required' });
    }

    // Check if user exists
    const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (existing.rows.length > 0) {
      return res.status(400).json({ detail: 'Email already registered' });
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // Create user
    const result = await pool.query(
      'INSERT INTO users (email, name, password_hash) VALUES ($1, $2, $3) RETURNING id, email, name, created_at',
      [email, name, passwordHash]
    );

    const user = result.rows[0];

    // Create token
    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET || 'your-secret-key', {
      expiresIn: '24h'
    });

    res.json({
      access_token: token,
      token_type: 'bearer',
      user: user
    });
  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({ detail: error.message });
  }
});

// Login
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ detail: 'Email and password required' });
    }

    // Find user
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    
    if (result.rows.length === 0) {
      return res.status(401).json({ detail: 'Invalid email or password' });
    }

    const user = result.rows[0];

    // Verify password
    const isValid = await bcrypt.compare(password, user.password_hash);
    if (!isValid) {
      return res.status(401).json({ detail: 'Invalid email or password' });
    }

    // Create token
    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET || 'your-secret-key', {
      expiresIn: '24h'
    });

    res.json({
      access_token: token,
      token_type: 'bearer',
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        created_at: user.created_at
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ detail: error.message });
  }
});

// Get current user
app.get('/api/auth/me', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, email, name, created_at FROM users WHERE id = $1',
      [req.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ detail: 'User not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ detail: error.message });
  }
});

// ==================== PHOTO ROUTES ====================

// Upload photo
app.post('/api/photos/upload', authenticateToken, upload.single('photo'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ detail: 'No photo file provided' });
    }

    const filename = `${Date.now()}_${req.userId}.jpg`;
    const filepath = path.join(uploadsDir, filename);

    // Compress and resize image
    await sharp(req.file.buffer)
      .resize(1920, 1080, { fit: 'inside', withoutEnlargement: true })
      .jpeg({ quality: 85 })
      .toFile(filepath);

    const photoUrl = `/uploads/photos/${filename}`;

    res.json({
      success: true,
      data: { url: photoUrl }
    });
  } catch (error) {
    console.error('Photo upload error:', error);
    res.status(500).json({ detail: error.message });
  }
});

// ==================== SONG LETTER ROUTES ====================

// Create song letter
app.post('/api/songletters/create', authenticateToken, async (req, res) => {
  try {
    const { song_link, letter, password, receiver_email, color_theme, emotion_tag, photo_url } = req.body;

    if (!song_link || !letter || !password) {
      return res.status(400).json({ detail: 'Missing required fields' });
    }

    // Generate unique code
    let code;
    let exists = true;
    while (exists) {
      code = generateCode();
      const result = await pool.query('SELECT id FROM song_letters WHERE code = $1', [code]);
      exists = result.rows.length > 0;
    }

    // Hash password
    const passwordHash = hashPasswordSHA256(password);

    // Insert song letter
    const result = await pool.query(
      `INSERT INTO song_letters 
      (code, sender_id, receiver_email, song_link, letter, password_hash, color_theme, emotion_tag, photo_url)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING id`,
      [code, req.userId, receiver_email, song_link, letter, passwordHash, 
       color_theme || 'amber-deep', emotion_tag || 'nostalgia', photo_url]
    );

    res.json({
      success: true,
      message: 'Song letter created successfully',
      data: {
        id: result.rows[0].id,
        code: code,
        link: `/memory/${code}`
      }
    });
  } catch (error) {
    console.error('Create song letter error:', error);
    res.status(500).json({ detail: error.message });
  }
});

// Access song letter
app.post('/api/songletters/access', async (req, res) => {
  try {
    const { code, password } = req.body;

    if (!code || !password) {
      return res.json({ success: false, error: 'Code and password required' });
    }

    // Find song letter
    const result = await pool.query('SELECT * FROM song_letters WHERE code = $1', [code]);

    if (result.rows.length === 0) {
      return res.json({ success: false, error: 'Song letter not found' });
    }

    const letter = result.rows[0];

    // Verify password
    const passwordHash = hashPasswordSHA256(password);
    if (passwordHash !== letter.password_hash) {
      return res.json({ success: false, error: 'Invalid password' });
    }

    res.json({
      success: true,
      data: {
        id: letter.id,
        code: letter.code,
        sender_id: letter.sender_id,
        receiver_email: letter.receiver_email,
        song_link: letter.song_link,
        letter: letter.letter,
        color_theme: letter.color_theme,
        emotion_tag: letter.emotion_tag,
        photo_url: letter.photo_url,
        created_at: letter.created_at
      }
    });
  } catch (error) {
    console.error('Access song letter error:', error);
    res.json({ success: false, error: error.message });
  }
});

// Get sent letters
app.get('/api/songletters/sent', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM song_letters WHERE sender_id = $1 ORDER BY created_at DESC',
      [req.userId]
    );

    const letters = result.rows.map(letter => ({
      id: letter.id,
      code: letter.code,
      sender_id: letter.sender_id,
      receiver_email: letter.receiver_email,
      song_link: letter.song_link,
      letter: letter.letter,
      color_theme: letter.color_theme,
      emotion_tag: letter.emotion_tag,
      photo_url: letter.photo_url,
      created_at: letter.created_at
    }));

    res.json({
      success: true,
      data: letters
    });
  } catch (error) {
    console.error('Get sent letters error:', error);
    res.status(500).json({ detail: error.message });
  }
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log('\n' + '='.repeat(50));
  console.log('  CassetteNote Backend (Node.js + PostgreSQL)');
  console.log('='.repeat(50));
  console.log(`  📡 Server: http://localhost:${PORT}`);
  console.log(`  🐘 Database: PostgreSQL (${pool.options.database})`);
  console.log(`  📸 Photos: uploads/photos/`);
  console.log('='.repeat(50) + '\n');
});

// Handle shutdown gracefully
process.on('SIGINT', async () => {
  console.log('\n👋 Shutting down gracefully...');
  await pool.end();
  process.exit(0);
});
