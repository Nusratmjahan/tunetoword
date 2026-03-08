-- CassetteNote Database Setup Script
-- Run this after creating the database

-- Create database (run as postgres user)
-- CREATE DATABASE cassettenote_db;

-- Connect to the database
\c cassettenote_db;

-- Enable UUID extension (optional, for future use)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Create index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Song letters table
CREATE TABLE IF NOT EXISTS song_letters (
    id SERIAL PRIMARY KEY,
    code VARCHAR(8) UNIQUE NOT NULL,
    sender_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    receiver_email VARCHAR(255),
    song_link VARCHAR(500) NOT NULL,
    letter TEXT NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    color_theme VARCHAR(50) DEFAULT 'amber-deep',
    emotion_tag VARCHAR(50) DEFAULT 'nostalgia',
    photo_url VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_song_letters_code ON song_letters(code);
CREATE INDEX IF NOT EXISTS idx_song_letters_sender ON song_letters(sender_id);
CREATE INDEX IF NOT EXISTS idx_song_letters_created ON song_letters(created_at DESC);

-- Display table information
\dt

-- Display column information
\d users
\d song_letters

-- Sample data (optional - for testing)
-- INSERT INTO users (email, name, password_hash) 
-- VALUES ('test@example.com', 'Test User', 'hashed_password_here');

NOTIFY success 'Database setup complete!';
