const express = require('express');
const router = express.Router();
const multer = require('multer');
const songLetterController = require('../controllers/songLetterController');

// Configure multer for memory storage
const upload = multer({ 
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
  },
});

// POST /api/songletter/create
router.post('/create', songLetterController.createSongLetter);

// POST /api/songletter/:code (verify password and get letter)
router.post('/:code', songLetterController.getSongLetter);

// GET /api/songletter/sent/:sender_id
router.get('/sent/:sender_id', songLetterController.getSentLetters);

// POST /api/songletter/upload-photo
router.post('/upload-photo', upload.single('photo'), songLetterController.uploadPhoto);

module.exports = router;
