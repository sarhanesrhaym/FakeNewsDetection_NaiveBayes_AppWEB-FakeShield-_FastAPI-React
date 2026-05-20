# 🚀 Guide de démarrage rapide - FakeShield AI v2.0

## Windows - Démarrage complet en 5 minutes

### Étape 1 : Préparer l'environnement backend
```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### Étape 2 : Configuration Gemini (optionnel pour commencer)
Créer un fichier `backend/.env` :
```env
GEMINI_API_KEY=sk-your-key-here
```
Vous pouvez l'ajouter plus tard.

### Étape 3 : Lancer le backend
```powershell
# Depuis backend/
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
# Le serveur démarre à http://localhost:8000
```

### Étape 4 : Lancer le frontend (nouvel onglet PowerShell)
```powershell
cd frontend
npm install
npm run dev
# Le frontend démarre à http://localhost:5173
```

### Étape 5 : Ouvrir l'application
Allez à **http://localhost:5173** dans votre navigateur.

---

## 🧪 Vérifier que tout fonctionne

### Test de l'API
```powershell
# Depuis PowerShell, tester le backend
$body = @{ text = "Breaking: Secret Government Conspiracy Revealed!!!" } | ConvertTo-Json
Invoke-WebRequest -Uri "http://localhost:8000/analyze" -Method Post -Body $body -ContentType "application/json"
```

Vous devriez voir une réponse JSON avec `label: "FAKE"` et un score de confiance.

### Test du frontend
1. Allez à http://localhost:5173
2. Entrez un texte dans "Analyser"
3. Cliquez "Analyser"
4. Vous devriez voir le résultat s'afficher

---

## 📦 Ajouter Gemini (optionnel)

Si vous voulez activer le chatbot Gemini :

### 1. Installer la dépendance
```powershell
cd backend
pip install google-generativeai
```

### 2. Créer une clé API
- Allez sur [Google AI Studio](https://aistudio.google.com/app/apikey)
- Cliquez "Créer une clé API gratuite"
- Copiez la clé

### 3. Ajouter à `.env`
```env
GEMINI_API_KEY=sk_paste_your_key_here
```

### 4. Décommenter dans `backend/app/services/chatbot_service.py`
Cherchez le bloc `# ── Optional Gemini integration` et décommentez-le.

### 5. Relancer le backend
```powershell
# Ctrl+C pour arrêter
# Relancer :
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

---

## 📊 Ajouter les modèles .pkl

Si vous avez des fichiers modèles `.pkl` :

1. Créez le dossier `backend/app/ml/models/`
2. Placez-y vos fichiers :
   - `naive_bayes_model.pkl`
   - `tfidf_vectorizer.pkl`
3. Le code de `classifier.py` les chargera automatiquement

---

## 🎨 Améliorer le dashboard

Pour ajouter des graphiques modernes :

```powershell
cd frontend
npm install recharts lucide-react
```

Puis mettez à jour `DashboardPage.jsx` pour ajouter des graphiques (voir ANALYSE_ET_PLAN.md).

---

## 🛑 Arrêter l'application

Appuyez sur **Ctrl+C** dans chaque terminal.

---

## ❓ Aide supplémentaire

Voir le fichier `ANALYSE_ET_PLAN.md` pour :
- Architecture complète
- Endpoints API détaillés
- Plan détaillé des tâches
- Checklist de configuration
- Dépannage courant

---

**Bon développement! 🚀**
