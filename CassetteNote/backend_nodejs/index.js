const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const songLetterRoutes = require('./routes/songletter');
const replyRoutes = require('./routes/reply');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/songletter', songLetterRoutes);
app.use('/api/reply', replyRoutes);

// Health check
app.get('/', (req, res) => {
  res.json({ message: 'CassetteNote API is running 📼' });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

app.listen(PORT, () => {
  console.log(`🎵 CassetteNote server running on port ${PORT}`);
});
