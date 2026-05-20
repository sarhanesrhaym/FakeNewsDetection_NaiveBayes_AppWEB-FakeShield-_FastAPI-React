# 📊 Analyse FakeShield AI v2.0 - Plan de développement

---

## 🎯 Vue d'ensemble du projet

**FakeShield AI** est une application web full-stack pour la détection de fake news utilisant :
- **Backend** : FastAPI + NLP (Naive Bayes + TF-IDF)
- **Frontend** : React 18 + Vite
- **ML** : Modèles entraînés sur dataset ISOT (~96% accuracy)

### Architecture actuelle

```
Frontend (React)                Backend (FastAPI)
┌──────────────────┐           ┌──────────────────┐
│  Pages:          │    API    │  Routes:         │
│  - Analysis      │◄─────────►│  - /analyze      │
│  - Dashboard     │   JSON    │  - /chat         │
│  - History       │           │  - /history      │
│  - About         │           │  - /stats        │
└──────────────────┘           └──────────────────┘
       :5173                         :8000
```

---

## 📁 Structure du projet

```
fakeshield_v1/
├── backend/
│   ├── main.py                 # Point d'entrée FastAPI
│   ├── requirements.txt         # Dépendances Python
│   └── app/
│       ├── ml/
│       │   └── classifier.py   # Scoring basique (à remplacer par .pkl)
│       ├── services/
│       │   └── chatbot_service.py  # Rule-based (prêt pour Gemini)
│       └── schemas/
│           └── models.py        # Pydantic models
├── frontend/
│   ├── package.json
│   ├── vite.config.js
│   └── src/
│       ├── App.jsx
│       ├── pages/
│       │   ├── Analysis/
│       │   ├── Dashboard/
│       │   ├── History/
│       │   └── About/
│       ├── services/
│       │   ├── api.js          # Appels backend
│       │   └── gemini.js       # Appels Gemini (frontend)
│       └── styles/
│           └── index.css
└── start.sh                    # Script de lancement (bash)
```

---

## 🚀 Comment démarrer l'application

### Option 1 : Sur Linux/macOS (avec start.sh)
```bash
bash start.sh
```

### Option 2 : Démarrage manuel (Windows/tous OS)

**Terminal 1 - Backend:**
```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

**Terminal 2 - Frontend:**
```powershell
cd frontend
npm install
npm run dev
```

Ouvrez `http://localhost:5173` dans votre navigateur.

---

## 📋 Tâches à accomplir

### ✅ Tâche 1 : Intégration Gemini API

**Objectif** : Remplacer le chatbot rule-based par Gemini pour des réponses intelligentes.

**Fichiers à modifier** :
- `backend/requirements.txt` → Ajouter `google-generativeai`
- `backend/app/services/chatbot_service.py` → Décommenter et impl. Gemini
- `backend/.env` → Ajouter `GEMINI_API_KEY=sk-...`
- `frontend/src/services/gemini.js` → Configurer client Gemini (optionnel)

**Étapes** :
1. Installer la dépendance
2. Obtenir une clé API Gemini (Google AI Studio)
3. Créer `.env` avec la clé
4. Implémenter la fonction `_gemini_reply()` async
5. Tester avec `/chat` endpoint

**Code exemple** :
```python
import google.generativeai as genai

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
model = genai.GenerativeModel("gemini-pro")

async def _gemini_reply(message: str, context: dict) -> str:
    prompt = _build_prompt(message, context)
    response = await model.generate_content_async(prompt)
    return response.text
```

---

### ✅ Tâche 2 : Intégration des modèles .pkl

**Objectif** : Remplacer le scoring basique par les vrais modèles NLP entraînés.

**Fichiers à modifier** :
- `backend/app/ml/classifier.py` → Charger `.pkl` et utiliser les modèles

**Étapes** :
1. Créer un dossier `backend/app/ml/models/` avec les fichiers `.pkl`
   - `naive_bayes_model.pkl` (Naive Bayes classifier)
   - `tfidf_vectorizer.pkl` (TF-IDF)
2. Mettre à jour `classifier.py` pour charger et utiliser les modèles
3. Implémenter `score_text()` avec les vrais prédictions

**Code exemple** :
```python
import pickle
from pathlib import Path

MODEL_DIR = Path(__file__).parent / "models"

with open(MODEL_DIR / "naive_bayes_model.pkl", "rb") as f:
    _model = pickle.load(f)

with open(MODEL_DIR / "tfidf_vectorizer.pkl", "rb") as f:
    _vectorizer = pickle.load(f)

def score_text(text: str) -> dict:
    X = _vectorizer.transform([text])
    pred = _model.predict(X)[0]
    proba = _model.predict_proba(X)[0]
    
    return {
        "label": "FAKE" if pred == 1 else "REAL",
        "fake_probability": float(proba[1]),
        "real_probability": float(proba[0]),
        "confidence": float(max(proba)),
        ...
    }
```

---

### ✅ Tâche 3 : Amélioration du dashboard

**Objectif** : Dashboard avancé avec graphiques et métriques en temps réel.

**Fichiers à modifier** :
- `frontend/src/pages/Dashboard/DashboardPage.jsx` → Nouveau design
- `frontend/package.json` → Ajouter Recharts/Chart.js
- `frontend/src/styles/index.css` → Styling avancé

**Dépendances à ajouter** :
```json
"recharts": "^2.10.0",
"lucide-react": "^0.294.0"
```

**Fonctionnalités à ajouter** :
1. **Graphiques** :
   - Pie chart : Fake vs Real (%)
   - Line chart : Tendance (temps réel)
   - Bar chart : Top indicateurs

2. **Métriques** :
   - Total analyses
   - Taux fake/real
   - Confiance moyenne
   - Dernière mise à jour

3. **Design** :
   - Cards modernes
   - Responsive layout
   - Animations fluides
   - Thème sombre/clair (optionnel)

**Exemple de composant** :
```jsx
import { PieChart, Pie, ResponsiveContainer } from 'recharts';
import { BarChart, Bar, XAxis, YAxis } from 'recharts';

export default function DashboardPage() {
  const [stats, setStats] = useState(null);
  
  useEffect(() => {
    fetch('http://localhost:8000/stats')
      .then(r => r.json())
      .then(setStats);
  }, []);
  
  if (!stats) return <div>Chargement...</div>;
  
  return (
    <div className="dashboard">
      <PieChart data={[
        { name: 'Fake', value: stats.fake_count },
        { name: 'Real', value: stats.real_count }
      ]} />
    </div>
  );
}
```

---

### ✅ Tâche 4 : Tests et vérifications

**Objectif** : Assurer la qualité et la fiabilité de l'application.

**Catégories de tests** :

1. **Backend - Tests unitaires** (pytest)
   - Test `/analyze` endpoint
   - Test `/chat` avec Gemini
   - Test `/history` et `/stats`
   - Mock Gemini API
   ```bash
   pip install pytest pytest-asyncio httpx
   pytest backend/tests/ -v
   ```

2. **Backend - Tests d'intégration**
   - Test pipeline complet
   - Test chargement modèles .pkl
   - Test erreurs API

3. **Frontend - Tests**
   - Test components React
   - Test appels API
   - Test UI/UX navigation
   ```bash
   npm install --save-dev vitest @testing-library/react
   npm run test
   ```

4. **Vérifications manuelles**
   - Test analyse texte (fake/real)
   - Test chatbot Gemini
   - Test historique & stats
   - Performance & latence
   - Responsive design (mobile/tablet)

**Fichiers à créer** :
```
backend/tests/
├── test_analyze.py
├── test_chat.py
├── test_classifier.py
└── test_integration.py

frontend/src/__tests__/
├── AnalysisPage.test.jsx
├── Dashboard.test.jsx
└── api.test.js
```

---

## 📌 Checklist de configuration

### Avant de démarrer

- [ ] Python 3.8+ installé
- [ ] Node.js 16+ installé
- [ ] Git configuré
- [ ] Clé API Gemini disponible (Google AI Studio)
- [ ] Modèles `.pkl` en place (`backend/app/ml/models/`)

### Backend

- [ ] `requirements.txt` à jour (google-generativeai ajouté)
- [ ] `.env` créé avec `GEMINI_API_KEY`
- [ ] `classifier.py` charge les modèles `.pkl`
- [ ] `chatbot_service.py` utilise Gemini
- [ ] Virtual env activé
- [ ] Dépendances installées : `pip install -r requirements.txt`

### Frontend

- [ ] `package.json` à jour (recharts, lucide-react)
- [ ] `npm install` exécuté
- [ ] Composants dashboard créés/améliorés
- [ ] Styles appliqués

### Tests

- [ ] Tests unitaires écrits et passants
- [ ] Tests d'intégration exécutés
- [ ] Tests frontend (optionnel mais recommandé)
- [ ] Vérifications manuelles complètes

---

## 🔗 Endpoints API

```
POST /analyze
  Body: { "text": "..." }
  Response: { "label": "FAKE|REAL", "confidence": 0.95, ... }

POST /chat
  Body: { "message": "Pourquoi fake?", "context": { "label": "FAKE", ... } }
  Response: { "reply": "..." }

GET /history
  Response: { "history": [...], "stats": {...} }

GET /stats
  Response: { "total": 100, "fake_count": 30, "fake_rate": 30.0, ... }

GET /
  Response: { "status": "ok", "version": "2.0.0" }
```

---

## 💡 Conseils d'implémentation

### Gemini API
- Utilisez le modèle `gemini-pro` (gratuit)
- Mettez en cache les prompts système pour réduire les coûts
- Gérez les erreurs (quota dépassé, clé invalide)
- Testez avec des messages courts d'abord

### Modèles .pkl
- Sauvegardez aussi `pickle.pkl` avec version
- Vérifiez la shape et le type des inputs
- Ajoutez des logs pour déboguer le chargement
- Considérez un warm-up à startup (facultatif)

### Dashboard
- Utilisez React.memo pour optimiser les rerenders
- Laissez les données en cache côté client pendant 30s
- Ajoutez une indication "temps réel" avec timestamp
- Testez sur mobile (responsiveness)

---

## 📊 Progression estimée

| Tâche | Durée | Dépendances |
|-------|-------|-------------|
| Gemini API | 1–2h | Aucune |
| Modèles .pkl | 1–2h | Gemini optionnel |
| Dashboard amélioration | 2–4h | Modèles .pkl recommandés |
| Tests & vérifications | 2–4h | Tout le reste |

**Total estimé** : 6–12 heures

---

## 🐛 Dépannage courant

### "ModuleNotFoundError: No module named 'google'"
→ `pip install google-generativeai`

### "GEMINI_API_KEY not found"
→ Créer `backend/.env` avec clé valide, redémarrer backend

### "FileNotFoundError: models/naive_bayes_model.pkl"
→ Vérifier que le fichier existe dans `backend/app/ml/models/`

### "CORS error" au frontend
→ Backend a déjà `CORSMiddleware` → redémarrer si problème persiste

### "npm ERR! 404 recharts"
→ `npm install recharts` exécuté correctement? Vérifier connexion internet

---

## 📚 Ressources utiles

- [FastAPI Docs](https://fastapi.tiangolo.com/)
- [Google Generative AI](https://ai.google.dev/)
- [React Docs](https://react.dev/)
- [Recharts Examples](https://recharts.org/examples)
- [Pytest Guide](https://docs.pytest.org/)

---

**Dernière mise à jour** : 18 mai 2026
**Auteur** : GitHub Copilot
