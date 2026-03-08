const { auth, db } = require('../utils/firebase_admin');

// Signup
exports.signup = async (req, res) => {
  try {
    const { email, password, name, photoUrl } = req.body;

    // Create user in Firebase Auth
    const userRecord = await auth.createUser({
      email,
      password,
      displayName: name,
      photoURL: photoUrl || null,
    });

    // Store user data in Firestore
    await db.collection('users').doc(userRecord.uid).set({
      uid: userRecord.uid,
      email,
      name,
      photo_url: photoUrl || null,
      created_at: new Date().toISOString(),
    });

    res.status(201).json({
      success: true,
      message: 'User created successfully',
      user: {
        uid: userRecord.uid,
        email,
        name,
        photo_url: photoUrl || null,
      },
    });
  } catch (error) {
    console.error('Signup error:', error);
    res.status(400).json({ 
      success: false, 
      error: error.message 
    });
  }
};

// Login (Firebase handles authentication, this endpoint is for additional checks)
exports.login = async (req, res) => {
  try {
    const { uid } = req.body;

    // Get user data from Firestore
    const userDoc = await db.collection('users').doc(uid).get();

    if (!userDoc.exists) {
      return res.status(404).json({ 
        success: false, 
        error: 'User not found' 
      });
    }

    res.status(200).json({
      success: true,
      user: userDoc.data(),
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(400).json({ 
      success: false, 
      error: error.message 
    });
  }
};

// Get user profile
exports.getProfile = async (req, res) => {
  try {
    const { uid } = req.params;

    const userDoc = await db.collection('users').doc(uid).get();

    if (!userDoc.exists) {
      return res.status(404).json({ 
        success: false, 
        error: 'User not found' 
      });
    }

    res.status(200).json({
      success: true,
      user: userDoc.data(),
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(400).json({ 
      success: false, 
      error: error.message 
    });
  }
};
