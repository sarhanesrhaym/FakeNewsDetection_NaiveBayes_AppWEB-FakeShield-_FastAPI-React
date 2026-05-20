#!/usr/bin/env pwsh
<#
FakeShield AI v2.0 - Script de démarrage PowerShell (Windows)
Usage: .\start_app.ps1

Note: Si vous avez une erreur d'exécution "cannot be loaded because running scripts 
is disabled on this system", exécutez:
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
#>

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "FakeShield AI v2.0" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier Python
Write-Host "[1/4] Vérification des prérequis..."
$pythonExists = python --version 2>$null
if (-not $pythonExists) {
    Write-Host "[ERROR] Python n'est pas installé ou pas dans PATH" -ForegroundColor Red
    Write-Host "Installez Python depuis https://www.python.org/" -ForegroundColor Yellow
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}
Write-Host "  ✓ Python détecté" -ForegroundColor Green

# Vérifier Node.js
$nodeExists = node --version 2>$null
if (-not $nodeExists) {
    Write-Host "[ERROR] Node.js n'est pas installé ou pas dans PATH" -ForegroundColor Red
    Write-Host "Installez Node.js depuis https://nodejs.org/" -ForegroundColor Yellow
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}
Write-Host "  ✓ Node.js détecté" -ForegroundColor Green
Write-Host ""

# ========== BACKEND ==========
Write-Host "[2/4] Configuration du backend..." -ForegroundColor Cyan
Set-Location backend

# Créer venv s'il n'existe pas
if (-not (Test-Path ".venv")) {
    Write-Host "  - Création de l'environnement virtuel..."
    python -m venv .venv
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Impossible de créer venv" -ForegroundColor Red
        Read-Host "Appuyez sur Entrée pour quitter"
        exit 1
    }
}

# Activer venv
Write-Host "  - Activation de l'environnement virtuel..."
& ".\.venv\Scripts\Activate.ps1"

# Installer dépendances
Write-Host "  - Installation des dépendances Python..."
pip install -q -r requirements.txt
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Impossible d'installer les dépendances" -ForegroundColor Red
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}

Write-Host "  ✓ Backend configuré" -ForegroundColor Green
Write-Host "  - Démarrage du backend..." -ForegroundColor Yellow

# Lancer backend en arrière-plan
$backendProcess = Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd '$PWD'; & '.\.venv\Scripts\Activate.ps1'; uvicorn main:app --host 0.0.0.0 --port 8000 --reload"
) -PassThru

Write-Host "  ✓ Backend démarré (PID: $($backendProcess.Id))" -ForegroundColor Green
Write-Host "    URL: http://localhost:8000" -ForegroundColor Yellow

Start-Sleep -Seconds 2

# ========== FRONTEND ==========
Write-Host ""
Write-Host "[3/4] Configuration du frontend..." -ForegroundColor Cyan
Set-Location ..\frontend

if (-not (Test-Path "node_modules")) {
    Write-Host "  - Installation des dépendances npm..."
    npm install --silent
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Impossible d'installer les dépendances npm" -ForegroundColor Red
        Read-Host "Appuyez sur Entrée pour quitter"
        exit 1
    }
}

Write-Host "  ✓ Frontend configuré" -ForegroundColor Green
Write-Host "  - Démarrage du frontend..." -ForegroundColor Yellow

# Lancer frontend en arrière-plan
$frontendProcess = Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd '$PWD'; npm run dev"
) -PassThru

Write-Host "  ✓ Frontend démarré (PID: $($frontendProcess.Id))" -ForegroundColor Green
Write-Host "    URL: http://localhost:5173" -ForegroundColor Yellow

Start-Sleep -Seconds 2

# ========== SUMMARY ==========
Write-Host ""
Write-Host "[4/4] Finalisation..." -ForegroundColor Cyan
Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "FakeShield AI est prêt !" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Frontend : " -NoNewline
Write-Host "http://localhost:5173" -ForegroundColor Cyan
Write-Host "  Backend  : " -NoNewline
Write-Host "http://localhost:8000" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Backend PID  : $($backendProcess.Id)"
Write-Host "  Frontend PID : $($frontendProcess.Id)"
Write-Host ""
Write-Host "Options:" -ForegroundColor Yellow
Write-Host "  - Ouvrir frontend dans le navigateur automatiquement? (En général ouvert)"
Write-Host "  - Appuyez sur Ctrl+C dans chaque fenêtre pour arrêter"
Write-Host "  - Les processus seront tués à la fermeture"
Write-Host ""

# Attendre
Write-Host "L'application est en cours d'exécution. Appuyez sur Ctrl+C pour arrêter." -ForegroundColor Yellow
Write-Host ""

# Attend l'arrêt ou Ctrl+C
try {
    while ($true) {
        Start-Sleep -Seconds 1
        
        # Vérifier si les processus sont toujours actifs
        if (-not (Get-Process -Id $backendProcess.Id -ErrorAction SilentlyContinue)) {
            Write-Host "[WARNING] Backend process s'est arrêté" -ForegroundColor Yellow
        }
        
        if (-not (Get-Process -Id $frontendProcess.Id -ErrorAction SilentlyContinue)) {
            Write-Host "[WARNING] Frontend process s'est arrêté" -ForegroundColor Yellow
        }
    }
}
catch [System.OperationCanceledException] {
    Write-Host ""
    Write-Host "Arrêt en cours..." -ForegroundColor Yellow
}
finally {
    Write-Host "Fermeture des processus..." -ForegroundColor Yellow
    
    # Tuer les processus
    try {
        Stop-Process -Id $backendProcess.Id -ErrorAction SilentlyContinue
        Stop-Process -Id $frontendProcess.Id -ErrorAction SilentlyContinue
    }
    catch {}
    
    Write-Host "Arrêt complet." -ForegroundColor Green
}
