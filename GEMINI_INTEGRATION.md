# 🔧 Guide d'intégration Gemini API

## Étape 1 : Obtenir une clé API Gemini

### 1.1 Allez sur Google AI Studio
- URL : https://aistudio.google.com/app/apikey
- Connectez-vous avec votre compte Google

### 1.2 Créer une clé API
- Cliquez sur **"Create API key"** ou **"+ Create new API key"**
- Sélectionnez le projet Google Cloud (ou créez-en un nouveau)
- Copiez la clé générée

⚠️ **Important** : Gardez cette clé secrète !

---

## Étape 2 : Installer la dépendance

```powershell
cd backend
pip install google-generativeai
```

Ou ajoutez-la à `requirements.txt` :
```
google-generativeai>=0.5.0
```

Puis :
```powershell
pip install -r requirements.txt
```

---

## Étape 3 : Configurer la clé API

### 3.1 Créer un fichier `.env`

Dans le dossier `backend/`, créez un fichier `.env` avec :
```env
GEMINI_API_KEY=sk_your_actual_key_here
```

**Exemple** (remplacez par votre vraie clé) :
```env
GEMINI_API_KEY=AIzaSyABCD1234XYZ...
```

### 3.2 Ajouter `.env` à `.gitignore`

Si vous utilisez Git, assurez-vous que `.env` est dans `.gitignore` :
```
.env
.env.local
__pycache__/
.venv/
```

---

## Étape 4 : Mettre à jour le code

### 4.1 Méthode A : Remplacer le fichier existant

1. Copiez le contenu de `chatbot_service_GEMINI_TEMPLATE.py`
2. Remplacez tout le contenu de `backend/app/services/chatbot_service.py`
3. Redémarrez le backend

### 4.2 Méthode B : Décommenter le code existant

Ouvrez `backend/app/services/chatbot_service.py` et :

1. Décommentez l'import Gemini (lignes ~8-9) :
```python
import os
import google.generativeai as genai
```

2. Décommentez la configuration (lignes ~11-14) :
```python
_gemini_key = os.getenv("GEMINI_API_KEY")
if _gemini_key:
    genai.configure(api_key=_gemini_key)
    _model = genai.GenerativeModel("gemini-pro")
```

3. Décommentez les fonctions Gemini (lignes ~16-25)

4. Modifiez `get_reply()` pour appeler `_gemini_reply()` :
```python
def get_reply(message: str, context: dict) -> str:
    # Essayer Gemini d'abord
    if _gemini_key:
        reply = _gemini_reply(message, context)
        return reply
    # Sinon utiliser le fallback rule-based
    return _fallback_reply(message, context)
```

---

## Étape 5 : Tester l'intégration

### 5.1 Redémarrer le backend

```powershell
# Dans le terminal du backend
# Appuyez sur Ctrl+C pour arrêter
# Puis redémarrez :
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### 5.2 Tester via l'interface web

1. Allez à http://localhost:5173
2. Analysez un texte (ex: "Breaking news: Secret government conspiracy!")
3. Allez au tab **Analyser** → attendez le résultat
4. Posez une question au chatbot : "Pourquoi c'est fake?"
5. Vous devriez voir une réponse détaillée de Gemini

### 5.3 Tester via cURL (PowerShell)

```powershell
$body = @{
    message = "Pourquoi ce texte est classé comme fake?"
    context = @{
        label = "FAKE"
        confidence = 0.95
        fake_indicators = @("breaking", "secret", "conspiracy")
        real_indicators = @()
    }
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8000/chat" `
  -Method Post `
  -Body $body `
  -ContentType "application/json"
```

---

## 🐛 Dépannage

### Erreur : "GEMINI_API_KEY not found"
- Vérifiez que `.env` existe dans le dossier `backend/`
- Vérifiez que la clé est correctement écrite
- Redémarrez le serveur backend

### Erreur : "API key not valid"
- Vérifiez que la clé est complète et sans espaces
- Essayez de générer une nouvelle clé sur Google AI Studio
- Mettez à jour dans `.env`

### Erreur : "429 Too Many Requests"
- Vous avez dépassé le quota gratuit
- Attendez quelques minutes avant de réessayer
- Vous pouvez ajouter une limite de requêtes dans le code

### Erreur : "ModuleNotFoundError: No module named 'google'"
```powershell
pip install google-generativeai
```

### Le chatbot ne répond pas
- Vérifiez que le backend a bien démarré (message `Uvicorn running...`)
- Vérifiez que `.env` contient la clé API
- Regardez les logs du backend pour voir l'erreur exacte

---

## 💡 Optimisations (avancé)

### Mise en cache des réponses Gemini

```python
from functools import lru_cache

@lru_cache(maxsize=100)
def get_gemini_reply_cached(message: str, label: str, confidence: float) -> str:
    # Évite les appels redondants à Gemini
    context = {"label": label, "confidence": confidence}
    return _gemini_reply(message, context)
```

### Limite de requêtes

```python
from datetime import datetime, timedelta

_last_gemini_call = {}

def _rate_limit_gemini(user_id: str) -> bool:
    now = datetime.now()
    if user_id in _last_gemini_call:
        if now - _last_gemini_call[user_id] < timedelta(seconds=1):
            return False  # Trop rapide
    _last_gemini_call[user_id] = now
    return True
```

### Gestion des erreurs améliorée

```python
async def _gemini_reply(message: str, context: dict) -> str:
    try:
        # ... votre code
    except Exception as e:
        logger.error(f"Gemini API error: {e}")
        # Retourner une réponse de fallback
        return _fallback_reply(message, context)
```

---

## ✅ Checklist

- [ ] Clé API Gemini obtenue
- [ ] google-generativeai installé
- [ ] `.env` créé avec la clé
- [ ] `.env` ajouté à `.gitignore`
- [ ] Code Gemini intégré dans chatbot_service.py
- [ ] Backend redémarré
- [ ] Test manuel réussi
- [ ] Erreurs d'API gérées correctement

---

## 📚 Ressources

- [Google Generative AI Documentation](https://ai.google.dev/docs)
- [Gemini API Reference](https://ai.google.dev/api/)
- [Python SDK Guide](https://ai.google.dev/tutorials/python_quickstart)
- [Rate Limits & Quotas](https://ai.google.dev/quotas)

---

**Besoin d'aide ?** Consultez les logs du backend pour les détails d'erreur.
