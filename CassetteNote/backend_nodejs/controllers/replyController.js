const { db, storage } = require('../utils/firebase_admin');

// Create reply
exports.createReply = async (req, res) => {
  try {
    const { song_letter_id, sender_id, message, song_link } = req.body;

    const replyData = {
      song_letter_id,
      sender_id,
      message,
      song_link: song_link || null,
      photo_url: null,
      created_at: new Date().toISOString(),
    };

    const docRef = await db.collection('replies').add(replyData);

    res.status(201).json({
      success: true,
      message: 'Reply sent successfully',
      data: {
        id: docRef.id,
        ...replyData,
      },
    });
  } catch (error) {
    console.error('Create reply error:', error);
    res.status(400).json({ 
      success: false, 
      error: error.message 
    });
  }
};

// Get replies for a song letter
exports.getReplies = async (req, res) => {
  try {
    const { song_letter_id } = req.params;

    const snapshot = await db.collection('replies')
      .where('song_letter_id', '==', song_letter_id)
      .orderBy('created_at', 'asc')
      .get();

    const replies = [];
    snapshot.forEach(doc => {
      replies.push({
        id: doc.id,
        ...doc.data(),
      });
    });

    res.status(200).json({
      success: true,
      data: replies,
    });
  } catch (error) {
    console.error('Get replies error:', error);
    res.status(400).json({ 
      success: false, 
      error: error.message 
    });
  }
};

// Upload photo for reply
exports.uploadReplyPhoto = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ 
        success: false, 
        error: 'No file uploaded' 
      });
    }

    const { reply_id } = req.body;
    const file = req.file;
    
    const filename = `replies/${reply_id}_${Date.now()}_${file.originalname}`;
    const fileUpload = storage.file(filename);

    await fileUpload.save(file.buffer, {
      metadata: {
        contentType: file.mimetype,
      },
    });

    await fileUpload.makePublic();

    const photoUrl = `https://storage.googleapis.com/${storage.name}/${filename}`;

    await db.collection('replies').doc(reply_id).update({
      photo_url: photoUrl,
    });

    res.status(200).json({
      success: true,
      photo_url: photoUrl,
    });
  } catch (error) {
    console.error('Upload reply photo error:', error);
    res.status(400).json({ 
      success: false, 
      error: error.message 
    });
  }
};
