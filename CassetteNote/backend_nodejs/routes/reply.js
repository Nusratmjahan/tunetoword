const express = require('express');
const router = express.Router();
const multer = require('multer');
const replyController = require('../controllers/replyController');

const upload = multer({ 
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024,
  },
});

// POST /api/reply/create
router.post('/create', replyController.createReply);

// GET /api/reply/:song_letter_id
router.get('/:song_letter_id', replyController.getReplies);

// POST /api/reply/upload-photo
router.post('/upload-photo', upload.single('photo'), replyController.uploadReplyPhoto);

module.exports = router;
