#!/usr/bin/env bash
# FakeShield AI — Start script v2.0
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
FRONTEND="$ROOT/frontend"
BACKEND="$ROOT/backend"

echo ""
echo "  FakeShield AI v2.0"
echo "  ────────────────────────────────"
echo ""

# ── Backend ──────────────────────────────────────────────────────────────────
echo "  Starting backend..."
cd "$BACKEND"

if [ ! -d ".venv" ]; then
  python3 -m venv .venv
  echo "  Virtual env created."
fi

source .venv/bin/activate
pip install -q -r requirements.txt

uvicorn main:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!
echo "  Backend running → http://localhost:8000"

# ── Frontend ─────────────────────────────────────────────────────────────────
echo "  Starting frontend..."
cd "$FRONTEND"

if [ ! -d "node_modules" ]; then
  npm install --silent
fi

npm run dev -- --open &
FRONTEND_PID=$!
echo "  Frontend running → http://localhost:5173"

echo ""
echo "  Ready. Press Ctrl+C to stop."
echo ""

trap "kill $BACKEND_PID $FRONTEND_PID 2>/dev/null" EXIT
wait
