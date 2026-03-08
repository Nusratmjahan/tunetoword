from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
import os
import random
import string
import hashlib
from datetime import datetime, timedelta
from PIL import Image
import io

from database import get_db, init_db

app = Flask(__name__)
app.config['SECRET_KEY'] = 'CHANGE_THIS_TO_A_SECURE_SECRET_KEY'
app.config['JWT_SECRET_KEY'] = 'CHANGE_THIS_JWT_SECRET_KEY'
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(days=1)
app.config['UPLOAD_FOLDER'] = 'uploads/photos'
app.config['MAX_CONTENT_LENGTH'] = 5 * 1024 * 1024  # 5MB max

CORS(app)
jwt = JWTManager(app)

# Create upload directory
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# Initialize database
init_db()

def generate_code():
    """Generate unique 8-character code"""
    chars = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ'
    return ''.join(random.choice(chars) for _ in range(8))

def hash_password_sha256(password):
    """Hash password with SHA-256 for song letters"""
    return hashlib.sha256(password.encode()).hexdigest()

@app.route('/')
def home():
    return jsonify({
        'message': 'CassetteNote API (Flask)',
        'version': '1.0.0',
        'docs': '/docs'
    })

# ==================== AUTH ROUTES ====================

@app.route('/api/auth/signup', methods=['POST'])
def signup():
    data = request.json
    email = data.get('email')
    password = data.get('password')
    name = data.get('name')
    
    if not email or not password or not name:
        return jsonify({'detail': 'All fields required'}), 400
    
    db = get_db()
    
    # Check if user exists
    existing = db.execute('SELECT id FROM users WHERE email = ?', (email,)).fetchone()
    if existing:
        return jsonify({'detail': 'Email already registered'}), 400
    
    # Create user
    password_hash = generate_password_hash(password)
    cursor = db.execute(
        'INSERT INTO users (email, name, password_hash) VALUES (?, ?, ?)',
        (email, name, password_hash)
    )
    db.commit()
    
    user_id = cursor.lastrowid
    user = db.execute('SELECT id, email, name, created_at FROM users WHERE id = ?', (user_id,)).fetchone()
    
    # Create token
    access_token = create_access_token(identity=user_id)
    
    return jsonify({
        'access_token': access_token,
        'token_type': 'bearer',
        'user': dict(user)
    })

@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')
    
    if not email or not password:
        return jsonify({'detail': 'Email and password required'}), 400
    
    db = get_db()
    user = db.execute('SELECT * FROM users WHERE email = ?', (email,)).fetchone()
    
    if not user or not check_password_hash(user['password_hash'], password):
        return jsonify({'detail': 'Invalid email or password'}), 401
    
    # Create token
    access_token = create_access_token(identity=user['id'])
    
    return jsonify({
        'access_token': access_token,
        'token_type': 'bearer',
        'user': {
            'id': user['id'],
            'email': user['email'],
            'name': user['name'],
            'created_at': user['created_at']
        }
    })

@app.route('/api/auth/me', methods=['GET'])
@jwt_required()
def get_current_user():
    user_id = get_jwt_identity()
    db = get_db()
    user = db.execute('SELECT id, email, name, created_at FROM users WHERE id = ?', (user_id,)).fetchone()
    
    if not user:
        return jsonify({'detail': 'User not found'}), 404
    
    return jsonify(dict(user))

# ==================== PHOTO ROUTES ====================

@app.route('/api/photos/upload', methods=['POST'])
@jwt_required()
def upload_photo():
    user_id = get_jwt_identity()
    
    if 'photo' not in request.files:
        return jsonify({'detail': 'No photo file provided'}), 400
    
    file = request.files['photo']
    
    if file.filename == '':
        return jsonify({'detail': 'No file selected'}), 400
    
    if not file.content_type.startswith('image/'):
        return jsonify({'detail': 'File must be an image'}), 400
    
    try:
        # Open and compress image
        image = Image.open(file.stream)
        
        # Resize
        max_size = (1920, 1080)
        image.thumbnail(max_size, Image.Resampling.LANCZOS)
        
        # Convert to RGB if needed
        if image.mode in ('RGBA', 'LA', 'P'):
            image = image.convert('RGB')
        
        # Generate filename
        filename = f"{int(datetime.now().timestamp() * 1000)}_{user_id}.jpg"
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        
        # Save
        image.save(filepath, 'JPEG', quality=85, optimize=True)
        
        photo_url = f"/uploads/photos/{filename}"
        
        return jsonify({
            'success': True,
            'data': {'url': photo_url}
        })
    
    except Exception as e:
        return jsonify({'detail': f'Failed to process image: {str(e)}'}), 500

@app.route('/uploads/photos/<filename>')
def serve_photo(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

# ==================== SONG LETTER ROUTES ====================

@app.route('/api/songletters/create', methods=['POST'])
@jwt_required()
def create_song_letter():
    user_id = get_jwt_identity()
    data = request.json
    
    song_link = data.get('song_link')
    letter = data.get('letter')
    password = data.get('password')
    
    if not song_link or not letter or not password:
        return jsonify({'detail': 'Missing required fields'}), 400
    
    db = get_db()
    
    # Generate unique code
    while True:
        code = generate_code()
        existing = db.execute('SELECT id FROM song_letters WHERE code = ?', (code,)).fetchone()
        if not existing:
            break
    
    # Hash password
    password_hash = hash_password_sha256(password)
    
    # Insert
    cursor = db.execute('''
        INSERT INTO song_letters 
        (code, sender_id, receiver_email, song_link, letter, password_hash, color_theme, emotion_tag, photo_url)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', (
        code,
        user_id,
        data.get('receiver_email'),
        song_link,
        letter,
        password_hash,
        data.get('color_theme', 'amber-deep'),
        data.get('emotion_tag', 'nostalgia'),
        data.get('photo_url')
    ))
    db.commit()
    
    return jsonify({
        'success': True,
        'message': 'Song letter created successfully',
        'data': {
            'id': cursor.lastrowid,
            'code': code,
            'link': f'/memory/{code}'
        }
    })

@app.route('/api/songletters/access', methods=['POST'])
def access_song_letter():
    data = request.json
    code = data.get('code')
    password = data.get('password')
    
    if not code or not password:
        return jsonify({'success': False, 'error': 'Code and password required'}), 400
    
    db = get_db()
    letter = db.execute('SELECT * FROM song_letters WHERE code = ?', (code,)).fetchone()
    
    if not letter:
        return jsonify({'success': False, 'error': 'Song letter not found'})
    
    # Verify password
    password_hash = hash_password_sha256(password)
    if password_hash != letter['password_hash']:
        return jsonify({'success': False, 'error': 'Invalid password'})
    
    return jsonify({
        'success': True,
        'data': {
            'id': letter['id'],
            'code': letter['code'],
            'sender_id': letter['sender_id'],
            'receiver_email': letter['receiver_email'],
            'song_link': letter['song_link'],
            'letter': letter['letter'],
            'color_theme': letter['color_theme'],
            'emotion_tag': letter['emotion_tag'],
            'photo_url': letter['photo_url'],
            'created_at': letter['created_at']
        }
    })

@app.route('/api/songletters/sent', methods=['GET'])
@jwt_required()
def get_sent_letters():
    user_id = get_jwt_identity()
    db = get_db()
    
    letters = db.execute(
        'SELECT * FROM song_letters WHERE sender_id = ? ORDER BY created_at DESC',
        (user_id,)
    ).fetchall()
    
    letters_data = [
        {
            'id': letter['id'],
            'code': letter['code'],
            'sender_id': letter['sender_id'],
            'receiver_email': letter['receiver_email'],
            'song_link': letter['song_link'],
            'letter': letter['letter'],
            'color_theme': letter['color_theme'],
            'emotion_tag': letter['emotion_tag'],
            'photo_url': letter['photo_url'],
            'created_at': letter['created_at']
        }
        for letter in letters
    ]
    
    return jsonify({
        'success': True,
        'data': letters_data
    })

if __name__ == '__main__':
    print("\n" + "="*50)
    print("  CassetteNote Backend (Flask + SQLite)")
    print("="*50)
    print(f"  📡 Server: http://localhost:8000")
    print(f"  📁 Database: cassettenote.db (SQLite)")
    print(f"  📸 Photos: uploads/photos/")
    print("="*50 + "\n")
    
    app.run(host='0.0.0.0', port=8000, debug=True)
