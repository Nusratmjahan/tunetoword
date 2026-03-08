# Quick Setup Script for Windows

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CassetteNote Backend Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Python is installed
Write-Host "[1/6] Checking Python installation..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version
    Write-Host "✓ Python found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Python not found. Please install Python 3.8+ from python.org" -ForegroundColor Red
    exit 1
}

# Check if PostgreSQL is running
Write-Host "`n[2/6] Checking PostgreSQL..." -ForegroundColor Yellow
$pgService = Get-Service -Name "postgresql*" -ErrorAction SilentlyContinue
if ($pgService) {
    Write-Host "✓ PostgreSQL service found" -ForegroundColor Green
    if ($pgService.Status -ne "Running") {
        Write-Host "  Starting PostgreSQL service..." -ForegroundColor Yellow
        Start-Service $pgService.Name
    }
} else {
    Write-Host "! PostgreSQL not found. Please ensure it's installed on C: drive" -ForegroundColor Yellow
}

# Navigate to backend directory
Write-Host "`n[3/6] Setting up virtual environment..." -ForegroundColor Yellow
cd backend_fastapi

# Create virtual environment if it doesn't exist
if (!(Test-Path "venv")) {
    python -m venv venv
    Write-Host "✓ Virtual environment created" -ForegroundColor Green
} else {
    Write-Host "✓ Virtual environment already exists" -ForegroundColor Green
}

# Activate virtual environment
Write-Host "`n[4/6] Activating virtual environment..." -ForegroundColor Yellow
& .\venv\Scripts\Activate.ps1
Write-Host "✓ Virtual environment activated" -ForegroundColor Green

# Install dependencies
Write-Host "`n[5/6] Installing dependencies..." -ForegroundColor Yellow
pip install -r requirements.txt --quiet
Write-Host "✓ Dependencies installed" -ForegroundColor Green

# Setup .env file
Write-Host "`n[6/6] Setting up environment file..." -ForegroundColor Yellow
if (!(Test-Path ".env")) {
    Copy-Item .env.example .env
    Write-Host "✓ .env file created from .env.example" -ForegroundColor Green
    Write-Host ""
    Write-Host "⚠ IMPORTANT: Edit .env file and update:" -ForegroundColor Yellow
    Write-Host "  - DATABASE_URL with your PostgreSQL password" -ForegroundColor Yellow
    Write-Host "  - SECRET_KEY with a secure random key" -ForegroundColor Yellow
} else {
    Write-Host "✓ .env file already exists" -ForegroundColor Green
}

# Display next steps
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Edit .env file with your PostgreSQL credentials"
Write-Host "2. Create database: psql -U postgres -c 'CREATE DATABASE cassettenote_db;'"
Write-Host "3. Generate SECRET_KEY: python -c 'import secrets; print(secrets.token_urlsafe(32))'"
Write-Host "4. Start server: python main.py"
Write-Host "5. Visit: http://localhost:8000/docs"
Write-Host ""
Write-Host "To start the server now, run:" -ForegroundColor Cyan
Write-Host "  python main.py" -ForegroundColor White
Write-Host ""
