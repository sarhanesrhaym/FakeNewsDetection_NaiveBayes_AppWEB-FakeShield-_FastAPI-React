@echo off
REM FakeShield AI - Script de démarrage Windows (cmd.exe / PowerShell)
REM Utilisation: start_app.bat

setlocal enabledelayedexpansion

echo.
echo   ====================================
echo   FakeShield AI v2.0
echo   ====================================
echo.

REM Vérifier Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python n'est pas installé ou pas dans PATH
    echo Installez Python depuis https://www.python.org/
    pause
    exit /b 1
)

REM Vérifier Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js n'est pas installé ou pas dans PATH
    echo Installez Node.js depuis https://nodejs.org/
    pause
    exit /b 1
)

echo [OK] Python et Node.js détectés
echo.

REM ========== BACKEND ==========
echo [1/3] Configuration du backend...
cd backend

REM Créer venv s'il n'existe pas
if not exist ".venv" (
    echo   - Création de l'environnement virtuel...
    python -m venv .venv
    if errorlevel 1 (
        echo [ERROR] Impossible de créer venv
        pause
        exit /b 1
    )
)

REM Activer venv et installer dépendances
call .venv\Scripts\activate.bat
pip install -q -r requirements.txt
if errorlevel 1 (
    echo [ERROR] Impossible d'installer les dépendances
    pause
    exit /b 1
)

echo   - Backend configuré. Démarrage...

REM Lancer backend en arrière-plan
start "FakeShield Backend" cmd /k "cd %CD% && .venv\Scripts\activate.bat && uvicorn main:app --host 0.0.0.0 --port 8000 --reload"

echo   - Backend démarré sur http://localhost:8000
timeout /t 3 /nobreak

REM ========== FRONTEND ==========
echo.
echo [2/3] Configuration du frontend...
cd ..\frontend

if not exist "node_modules" (
    echo   - Installation des dépendances npm...
    call npm install --silent
    if errorlevel 1 (
        echo [ERROR] Impossible d'installer les dépendances npm
        pause
        exit /b 1
    )
)

echo   - Frontend configuré. Démarrage...
start "FakeShield Frontend" cmd /k "cd %CD% && npm run dev"

echo   - Frontend démarré sur http://localhost:5173
timeout /t 3 /nobreak

REM ========== SUMMARY ==========
echo.
echo [3/3] Finalisation...
echo.
echo ====================================
echo FakeShield AI est prêt !
echo ====================================
echo.
echo Frontend : http://localhost:5173
echo Backend  : http://localhost:8000
echo.
echo Appuyez sur Ctrl+C dans chaque fenêtre pour arrêter
echo.
pause

endlocal
