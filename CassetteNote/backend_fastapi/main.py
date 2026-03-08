from fastapi import FastAPI, Depends, HTTPException, status, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session
from datetime import timedelta
import os
import shutil
from pathlib import Path
from PIL import Image
import io
from dotenv import load_dotenv

from database import get_db, init_db
from models import User, SongLetter
from schemas import (
    UserCreate, UserLogin, UserResponse, Token,
    SongLetterCreate, SongLetterAccess, SongLetterResponse,
    SongLetterCreateResponse
)
from auth import (
    get_password_hash, verify_password, create_access_token,
    get_current_user, ACCESS_TOKEN_EXPIRE_MINUTES
)
from utils import generate_unique_code, hash_password_sha256, verify_password_sha256

load_dotenv()

app = FastAPI(title="CassetteNote API", version="1.0.0")

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this based on your needs
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create upload directory if it doesn't exist
UPLOAD_DIR = Path(os.getenv("UPLOAD_DIR", "uploads/photos"))
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

# Mount static files for photo access
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# Initialize database on startup
@app.on_event("startup")
def on_startup():
    init_db()

@app.get("/")
def read_root():
    return {
        "message": "CassetteNote API",
        "version": "1.0.0",
        "docs": "/docs"
    }

# ========== AUTH ENDPOINTS ==========

@app.post("/api/auth/signup", response_model=Token)
def signup(user_data: UserCreate, db: Session = Depends(get_db)):
    # Check if user already exists
    existing_user = db.query(User).filter(User.email == user_data.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create new user
    hashed_password = get_password_hash(user_data.password)
    new_user = User(
        email=user_data.email,
        name=user_data.name,
        password_hash=hashed_password
    )
    
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    # Create access token
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": new_user.id}, expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": new_user
    }

@app.post("/api/auth/login", response_model=Token)
def login(credentials: UserLogin, db: Session = Depends(get_db)):
    # Find user
    user = db.query(User).filter(User.email == credentials.email).first()
    if not user or not verify_password(credentials.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )
    
    # Create access token
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.id}, expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": user
    }

@app.get("/api/auth/me", response_model=UserResponse)
def get_current_user_info(current_user: User = Depends(get_current_user)):
    return current_user

# ========== PHOTO UPLOAD ENDPOINT ==========

@app.post("/api/photos/upload")
async def upload_photo(
    photo: UploadFile = File(...),
    current_user: User = Depends(get_current_user)
):
    # Validate file type
    if not photo.content_type.startswith("image/"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File must be an image"
        )
    
    # Validate file size (5MB max)
    MAX_FILE_SIZE = int(os.getenv("MAX_FILE_SIZE", "5242880"))  # 5MB
    contents = await photo.read()
    if len(contents) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File size exceeds 5MB limit"
        )
    
    # Reset file pointer
    await photo.seek(0)
    
    # Compress and save image
    try:
        image = Image.open(io.BytesIO(contents))
        
        # Resize if needed (max 1920x1080)
        max_size = (1920, 1080)
        image.thumbnail(max_size, Image.Resampling.LANCZOS)
        
        # Generate unique filename
        import time
        filename = f"{int(time.time() * 1000)}_{current_user.id}.jpg"
        file_path = UPLOAD_DIR / filename
        
        # Save as JPEG with compression
        if image.mode in ('RGBA', 'LA', 'P'):
            image = image.convert('RGB')
        image.save(file_path, "JPEG", quality=85, optimize=True)
        
        # Return URL
        photo_url = f"/uploads/photos/{filename}"
        
        return {
            "success": True,
            "data": {
                "url": photo_url
            }
        }
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to process image: {str(e)}"
        )

# ========== SONG LETTER ENDPOINTS ==========

@app.post("/api/songletters/create", response_model=SongLetterCreateResponse)
def create_song_letter(
    letter_data: SongLetterCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    try:
        # Generate unique code
        code = generate_unique_code(db)
        
        # Hash password
        password_hash = hash_password_sha256(letter_data.password)
        
        # Create song letter
        new_letter = SongLetter(
            code=code,
            sender_id=current_user.id,
            receiver_email=letter_data.receiver_email,
            song_link=letter_data.song_link,
            letter=letter_data.letter,
            password_hash=password_hash,
            color_theme=letter_data.color_theme,
            emotion_tag=letter_data.emotion_tag,
            photo_url=letter_data.photo_url
        )
        
        db.add(new_letter)
        db.commit()
        db.refresh(new_letter)
        
        return {
            "success": True,
            "message": "Song letter created successfully",
            "data": {
                "id": new_letter.id,
                "code": code,
                "link": f"/memory/{code}"
            }
        }
    
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create song letter: {str(e)}"
        )

@app.post("/api/songletters/access")
def access_song_letter(
    access_data: SongLetterAccess,
    db: Session = Depends(get_db)
):
    # Find song letter by code
    letter = db.query(SongLetter).filter(SongLetter.code == access_data.code).first()
    
    if not letter:
        return {
            "success": False,
            "error": "Song letter not found"
        }
    
    # Verify password
    if not verify_password_sha256(access_data.password, letter.password_hash):
        return {
            "success": False,
            "error": "Invalid password"
        }
    
    # Return letter data (without password hash)
    return {
        "success": True,
        "data": {
            "id": letter.id,
            "code": letter.code,
            "sender_id": letter.sender_id,
            "receiver_email": letter.receiver_email,
            "song_link": letter.song_link,
            "letter": letter.letter,
            "color_theme": letter.color_theme,
            "emotion_tag": letter.emotion_tag,
            "photo_url": letter.photo_url,
            "created_at": letter.created_at.isoformat()
        }
    }

@app.get("/api/songletters/sent")
def get_sent_letters(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    try:
        # Get all letters sent by current user
        letters = db.query(SongLetter).filter(
            SongLetter.sender_id == current_user.id
        ).order_by(SongLetter.created_at.desc()).all()
        
        # Format response (without password hashes)
        letters_data = [
            {
                "id": letter.id,
                "code": letter.code,
                "sender_id": letter.sender_id,
                "receiver_email": letter.receiver_email,
                "song_link": letter.song_link,
                "letter": letter.letter,
                "color_theme": letter.color_theme,
                "emotion_tag": letter.emotion_tag,
                "photo_url": letter.photo_url,
                "created_at": letter.created_at.isoformat()
            }
            for letter in letters
        ]
        
        return {
            "success": True,
            "data": letters_data
        }
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get sent letters: {str(e)}"
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=os.getenv("HOST", "0.0.0.0"),
        port=int(os.getenv("PORT", "8000")),
        reload=True
    )
