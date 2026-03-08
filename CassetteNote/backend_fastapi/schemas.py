from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional

# User Schemas
class UserCreate(BaseModel):
    email: EmailStr
    password: str
    name: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: int
    email: str
    name: str
    created_at: datetime
    
    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str
    user: UserResponse

# Song Letter Schemas
class SongLetterCreate(BaseModel):
    song_link: str
    letter: str
    password: str
    receiver_email: Optional[str] = None
    color_theme: Optional[str] = "amber-deep"
    emotion_tag: Optional[str] = "nostalgia"
    photo_url: Optional[str] = None

class SongLetterAccess(BaseModel):
    code: str
    password: str

class SongLetterResponse(BaseModel):
    id: int
    code: str
    sender_id: int
    receiver_email: Optional[str]
    song_link: str
    letter: str
    color_theme: str
    emotion_tag: str
    photo_url: Optional[str]
    created_at: datetime
    
    class Config:
        from_attributes = True

class SongLetterCreateResponse(BaseModel):
    success: bool
    message: str
    data: dict
