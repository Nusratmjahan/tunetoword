import random
import string
import hashlib
from sqlalchemy.orm import Session
from models import SongLetter

def generate_unique_code(db: Session) -> str:
    """Generate unique 8-character code (no confusing characters)"""
    chars = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ'
    
    while True:
        code = ''.join(random.choice(chars) for _ in range(8))
        # Check if code already exists
        existing = db.query(SongLetter).filter(SongLetter.code == code).first()
        if not existing:
            return code

def hash_password_sha256(password: str) -> str:
    """Hash password using SHA-256 (for song letter passwords)"""
    return hashlib.sha256(password.encode()).hexdigest()

def verify_password_sha256(password: str, hashed: str) -> bool:
    """Verify SHA-256 hashed password"""
    return hash_password_sha256(password) == hashed
