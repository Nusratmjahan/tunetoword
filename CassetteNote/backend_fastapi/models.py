from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from database import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    name = Column(String(255), nullable=False)
    password_hash = Column(String(255), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    song_letters = relationship("SongLetter", back_populates="sender")

class SongLetter(Base):
    __tablename__ = "song_letters"
    
    id = Column(Integer, primary_key=True, index=True)
    code = Column(String(8), unique=True, index=True, nullable=False)
    sender_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    receiver_email = Column(String(255))
    song_link = Column(String(500), nullable=False)
    letter = Column(Text, nullable=False)
    password_hash = Column(String(255), nullable=False)
    color_theme = Column(String(50), default="amber-deep")
    emotion_tag = Column(String(50), default="nostalgia")
    photo_url = Column(String(500))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    sender = relationship("User", back_populates="song_letters")
