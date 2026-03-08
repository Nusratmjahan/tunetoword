import sqlite3
import os

DATABASE = 'cassettenote.db'

def get_db():
    db = sqlite3.connect(DATABASE)
    db.row_factory = sqlite3.Row
    return db

def init_db():
    db = get_db()
    
    # Create users table
    db.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            name TEXT NOT NULL,
            password_hash TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # Create song_letters table
    db.execute('''
        CREATE TABLE IF NOT EXISTS song_letters (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            code TEXT UNIQUE NOT NULL,
            sender_id INTEGER NOT NULL,
            receiver_email TEXT,
            song_link TEXT NOT NULL,
            letter TEXT NOT NULL,
            password_hash TEXT NOT NULL,
            color_theme TEXT DEFAULT 'amber-deep',
            emotion_tag TEXT DEFAULT 'nostalgia',
            photo_url TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (sender_id) REFERENCES users (id)
        )
    ''')
    
    db.commit()
    db.close()
    print("✅ Database initialized successfully!")

if __name__ == '__main__':
    init_db()
