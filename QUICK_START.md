# 🎯 QUICK START - FakeShield AI en 30 secondes

## 📌 Pour les pressés

### Option A : Démarrage automatique (Recommandé)

**Windows (PowerShell)** :
```powershell
.\start_app.ps1
```

**Windows (CMD)** :
```cmd
start_app.bat
```

**Linux/Mac** :
```bash
bash start.sh
```

✅ L'app démarre toute seule en 2 terminaux

---

### Option B : Démarrage manuel (3 minutes)

**Terminal 1 - Backend** :
```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

**Terminal 2 - Frontend** :
```powershell
cd frontend
npm install
npm run dev
```

✅ Allez à **http://localhost:5173**

---

## 🎨 Fichiers créés (14 au total)

### 📚 Guides (Lisez ces fichiers)
- `README_COMPLET.md` ← **Commencez ici**
- `DEMARRAGE_RAPIDE.md` ← Démarrage 5 min
- `ANALYSE_ET_PLAN.md` ← Détails techniques
- `GEMINI_INTEGRATION.md` ← Tâche 1 (Chatbot)
- `MODELS_INTEGRATION.md` ← Tâche 2 (ML)
- `TESTING_GUIDE.md` ← Tâche 4 (Tests)
- `INDEX.md` ← Navigation complète

### 🛠️ Templates (Copier-coller ces fichiers)
- `chatbot_service_GEMINI_TEMPLATE.py` ← Backend (Tâche 1)
- `classifier_TEMPLATE.py` ← Backend (Tâche 2)
- `DashboardPage_TEMPLATE.jsx` ← Frontend (Tâche 3)
- `DashboardPage.css` ← Styles (Tâche 3)

### 🚀 Scripts (Exécuter ces fichiers)
- `start_app.ps1` ← Démarrage PowerShell
- `start_app.bat` ← Démarrage CMD

---

## ⚡ Les 4 tâches expliquées simplement

```
┌─────────────────────────────────────────────────────────┐
│ TÂCHE 1: Gemini API (1-2h)                              │
├─────────────────────────────────────────────────────────┤
│ 1. Obtenir clé API (Google AI Studio)                   │
│ 2. pip install google-generativeai                      │
│ 3. Créer backend/.env avec clé                          │
│ 4. Copier chatbot_service_GEMINI_TEMPLATE.py            │
│ 5. Redémarrer backend                                   │
│ → Chatbot répond intelligemment ✓                       │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ TÂCHE 2: Modèles .pkl (1-2h)                            │
├─────────────────────────────────────────────────────────┤
│ 1. Créer backend/app/ml/models/                         │
│ 2. Placer vos fichiers .pkl dedans                      │
│ 3. Copier classifier_TEMPLATE.py                        │
│ 4. Redémarrer backend                                   │
│ 5. Vérifier logs "✓ Modèles chargés"                    │
│ → Utilise vrais modèles ML (96% accuracy) ✓             │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ TÂCHE 3: Dashboard amélioré (2-4h)                      │
├─────────────────────────────────────────────────────────┤
│ 1. npm install recharts lucide-react                    │
│ 2. Copier DashboardPage_TEMPLATE.jsx                    │
│ 3. Copier DashboardPage.css                             │
│ 4. Redémarrer frontend                                  │
│ 5. Tester page Dashboard                                │
│ → Graphiques + statistiques temps réel ✓                │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ TÂCHE 4: Tests (2-4h)                                   │
├─────────────────────────────────────────────────────────┤
│ 1. pip install pytest pytest-asyncio                    │
│ 2. Créer backend/tests/ avec fichiers tests             │
│ 3. pytest tests/ -v                                     │
│ 4. Tester manuellement via UI                           │
│ 5. Valider checklist complète                           │
│ → Qualité assurée ✓                                     │
└─────────────────────────────────────────────────────────┘
```

---

## 🔍 Où trouver quoi

```
Je veux → Je consulte
───────────────────────────────────────
Démarrer      → DEMARRAGE_RAPIDE.md
Comprendre    → README_COMPLET.md ou ANALYSE_ET_PLAN.md
Gemini (T1)   → GEMINI_INTEGRATION.md
Modèles (T2)  → MODELS_INTEGRATION.md
Dashboard(T3) → DashboardPage_TEMPLATE.jsx
Tests (T4)    → TESTING_GUIDE.md
Fichiers      → INDEX.md
Aide rapide   → Ce fichier
```

---

## 💾 Configuration environnement

**Fichier : `backend/.env`** (À créer)
```env
GEMINI_API_KEY=sk_your_key_here
```

**Fichier : `backend/requirements.txt`** (À mettre à jour)
```
fastapi>=0.111.0
uvicorn[standard]>=0.30.0
google-generativeai>=0.5.0
```

**Fichier : `frontend/package.json`** (À mettre à jour)
```json
"recharts": "^2.10.0",
"lucide-react": "^0.294.0"
```

---

## 🎯 État du projet

```
Frontend (React)     ✅ Fonctionnel
Backend (FastAPI)    ✅ Fonctionnel
Modèles ML           ⏳ À intégrer
Gemini API           ⏳ À intégrer
Dashboard avancé     ⏳ À intégrer
Tests complets       ⏳ À écrire
```

---

## 📊 Timeline

```
Démarrage           → 5 min
Tâche 1 (Gemini)    → 1-2h
Tâche 2 (Modèles)   → 1-2h
Tâche 3 (Dashboard) → 2-4h
Tâche 4 (Tests)     → 2-4h
─────────────────────────
TOTAL               → 6-12h
```

---

## ✅ Avant de commencer

- [ ] Python 3.8+ installé
- [ ] Node.js 16+ installé
- [ ] Clé Gemini obtenue (optionnel pour start)
- [ ] Modèles .pkl disponibles (optionnel pour start)
- [ ] Git configuré (optionnel)

---

## 🚀 Let's Go !

1. **Dès maintenant** :
   ```powershell
   .\start_app.ps1
   ```

2. **Puis lire** :
   - `README_COMPLET.md` (5 min)
   - `DEMARRAGE_RAPIDE.md` (5 min)

3. **Ensuite** :
   - Choisir Tâche 1, 2, 3 ou 4
   - Lire le guide correspondant
   - Utiliser le template
   - Tester

4. **Finalement** :
   - Suivre `TESTING_GUIDE.md`
   - Valider checklist
   - Déployer !

---

## 🆘 Aide rapide

**Backend ne démarre pas ?**
- Vérifier Python 3.8+ : `python --version`
- Vérifier venv : `.\.venv\Scripts\Activate.ps1`
- Vérifier pip : `pip install -r requirements.txt`

**Frontend ne se charge pas ?**
- Vérifier Node.js 16+ : `node --version`
- Vérifier npm : `npm install`
- Vérifier port 5173 libre

**Erreur CORS ?**
- Backend a déjà CORSMiddleware
- Redémarrer backend si persistant

**Plus d'aide ?**
- Consulter fichier correspondant
- Consulter `ANALYSE_ET_PLAN.md` section dépannage

---

## 📞 Ressources

- [FastAPI](https://fastapi.tiangolo.com/)
- [Google Generative AI](https://ai.google.dev/)
- [React](https://react.dev/)
- [Recharts](https://recharts.org/)
- [Pytest](https://docs.pytest.org/)

---

**C'est parti ! 🚀**

Exécutez `start_app.ps1` maintenant et bon développement !

---

*FakeShield AI v2.0 | GitHub Copilot*
