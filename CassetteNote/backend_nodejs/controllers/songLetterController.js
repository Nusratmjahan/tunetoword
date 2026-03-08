const { db, storage } = require('../utils/firebase_admin');
const { hashPassword, comparePassword } = require('../utils/hashPassword');
const { generateCode } = require('../utils/generateCode');

// Create song letter
exports.createSongLetter = async (req, res) => {
  try {
    const { 
      sender_id, 
      receiver_email, 
      song_link, 
      letter, 
      password,
      color_theme,
      emotion_tag 
    } = req.body;

    // Generate unique code
    const code = generateCode();

    // Hash password
    const password_hash = await hashPassword(password);

    const songLetterData = {
      code,
      sender_id,
      receiver_email: receiver_email || null,
      song_link,
      letter,
      password_hash,
      color_theme: color_theme || 'amber-deep',
      emotion_tag: emotion_tag || 'nostalgia',
      photo_url: null,
      created_at: new Date().toISOString(),
    };

    // Save to Firestore
    const docRef = await db.collection('songLetters').add(songLetterData);

    res.status(201).json({
      success: true,
      message: 'Song letter created successfully',
      data: {
        id: docRef.id,
        code,
        link: `/memory/${code}`,
      },
    });
  } catch (error) {
    console.error('Create song letter error:', error);
    res.status(400).json({ 
      success: false, 
      error: error.message 
    });
  }
};

// Get song letter by code (with password verification)
exports.getSongLetter = async (req, res) => {
  try {
    const { code } = req.params;
    const { password } = req.body;

    // Find song letter by code
    const snapshot = await db.collection('songLetters')
      .where('code', '==', code)
      .limit(1)
      .get();

    if (snapshot.empty) {
      return res.status(404).json({ 
        success: false, 
        error: 'Song letter not found' 
      });
    }

    const songLetterDoc = snapshot.docs[0];
    const songLetter = songLetterDoc.data();

    // Verify password
    const isPasswordValid = await comparePassword(password, songLetter.password_hash);

    if (!isPasswordValid) {
      return res.status(401).json({ 
        success: false, 
        error: 'Invalid password' 
      });
    }

    // Remove password_hash from response
    delete songLetter.password_hash;

    res.status(200).json({
      success: true,
      data: {
        id: songLetterDoc.id,
        ...songLetter,
      },
    });
  } catch (error) {
    console.error('Get song letter error:', error);
    res.status(400).json({ 
      success: false, 
      error: error.message 
    });
  }
};

// Get all song letters by sender
exports.getSentLetters = async (req, res) => {
  try {
    const { sender_id } = req.params;

    const snapshot = await db.collection('songLetters')
      .where('sender_id', '==', sender_id)
      .orderBy('created_at', 'desc')
      .get();

    const letters = [];
    snapshot.forEach(doc => {
      const data = doc.data();
      delete data.password_hash;
      letters.push({
        id: doc.id,
        ...data,
      });
    });

    res.status(200).json({
      success: true,
      data: letters,
    });
  } catch (error) {
    console.error('Get sent letters error:', error);
    res.status(400).json({ 
      success: false, 
      error: error.message 
    });
  }
};

// Upload photo for song letter
exports.uploadPhoto = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ 
        success: false, 
        error: 'No file uploaded' 
      });
    }

    const { letter_id } = req.body;
    const file = req.file;
    
    // Create unique filename
    const filename = `songletters/${letter_id}_${Date.now()}_${file.originalname}`;
    const fileUpload = storage.file(filename);

    // Upload to Firebase Storage
    await fileUpload.save(file.buffer, {
      metadata: {
        contentType: file.mimetype,
      },
    });

    // Make file public
    await fileUpload.makePublic();

    const photoUrl = `https://storage.googleapis.com/${storage.name}/${filename}`;

    // Update Firestore document
    await db.collection('songLetters').doc(letter_id).update({
      photo_url: photoUrl,
    });

    res.status(200).json({
      success: true,
      photo_url: photoUrl,
    });
  } catch (error) {
    console.error('Upload photo error:', error);
    res.status(400).json({ 
      success: false, 
      error: error.message 
    });
  }
};
