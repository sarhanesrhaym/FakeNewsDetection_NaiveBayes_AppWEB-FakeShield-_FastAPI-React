# 🤖 Guide d'intégration des modèles .pkl

## Vue d'ensemble

Ce guide explique comment intégrer vos modèles NLP entraînés (Naive Bayes + TF-IDF) dans FakeShield.

---

## Structure des modèles

Vous devez avoir **deux fichiers pickle** :

1. **naive_bayes_model.pkl** - Modèle Naive Bayes entraîné
2. **tfidf_vectorizer.pkl** - Vectorizer TF-IDF entraîné

### Format attendu des modèles

**Naive Bayes Model** :
- Type : `sklearn.naive_bayes.ComplementNB` ou `MultinomialNB`
- Doit avoir `predict()` et `predict_proba()`
- Doit être entraîné sur des documents vectorisés par TF-IDF

**TF-IDF Vectorizer** :
- Type : `sklearn.feature_extraction.text.TfidfVectorizer`
- Doit avoir `transform()` et `get_feature_names_out()`
- Doit être fitté sur le corpus d'entraînement

---

## Étape 1 : Préparer les fichiers modèles

### 1.1 Créer le dossier des modèles

```powershell
# Depuis le dossier backend/
mkdir app\ml\models
```

### 1.2 Placer les fichiers `.pkl`

Placez vos fichiers dans `backend/app/ml/models/` :

```
backend/
└── app/
    └── ml/
        ├── classifier.py
        └── models/
            ├── naive_bayes_model.pkl     ← Votre modèle
            └── tfidf_vectorizer.pkl      ← Votre vectorizer
```

---

## Étape 2 : Mettre à jour le code classifier.py

### 2.1 Méthode A : Remplacer le fichier

1. Copiez le contenu de `classifier_TEMPLATE.py`
2. Remplacez tout le contenu de `backend/app/ml/classifier.py`
3. Redémarrez le backend

### 2.2 Méthode B : Modifier manuellement

Ouvrez `backend/app/ml/classifier.py` et ajoutez en début :

```python
import pickle
from pathlib import Path

# Chemins des modèles
MODEL_DIR = Path(__file__).parent / "models"
MODEL_PATH = MODEL_DIR / "naive_bayes_model.pkl"
VECTORIZER_PATH = MODEL_DIR / "tfidf_vectorizer.pkl"

# Variables globales
_model = None
_vectorizer = None
_models_loaded = False

# Charger les modèles
def _load_models():
    global _model, _vectorizer, _models_loaded
    
    try:
        with open(MODEL_PATH, 'rb') as f:
            _model = pickle.load(f)
        with open(VECTORIZER_PATH, 'rb') as f:
            _vectorizer = pickle.load(f)
        _models_loaded = True
        print("✓ Modèles chargés avec succès")
    except FileNotFoundError:
        print("⚠ Fichiers modèles non trouvés, utilisation du fallback")

# Charger au démarrage
_load_models()
```

Puis modifiez la fonction `score_text()` :

```python
def score_text(text: str) -> dict:
    if _models_loaded:
        # Utiliser le modèle ML
        X = _vectorizer.transform([text])
        label = _model.predict(X)[0]
        proba = _model.predict_proba(X)[0]
        
        label_str = "FAKE" if label == 1 else "REAL"
        fake_prob = float(proba[1]) if len(proba) > 1 else 0.0
        real_prob = float(proba[0]) if len(proba) > 0 else 0.0
        
        return {
            "label": label_str,
            "fake_probability": round(fake_prob, 4),
            "real_probability": round(real_prob, 4),
            "confidence": round(max(fake_prob, real_prob), 4),
            "word_count": len(text.split()),
            "caps_ratio": round(sum(1 for c in text if c.isupper()) / max(len(text), 1), 3),
            "fake_indicators": [],
            "real_indicators": [],
        }
    else:
        # Utiliser le fallback basé sur les mots-clés
        return _score_text_fallback(text)
```

---

## Étape 3 : Vérifier que les modèles sont chargés

### 3.1 Consulter les logs du backend

Redémarrez le backend et cherchez le message :
```
✓ Modèles chargés avec succès
```

Ou si erreur :
```
⚠ Fichiers modèles non trouvés, utilisation du fallback
```

### 3.2 Tester via l'API

```powershell
$body = @{ text = "Breaking: Secret government conspiracy revealed!" } | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8000/analyze" `
  -Method Post `
  -Body $body `
  -ContentType "application/json" | Select-Object -ExpandProperty Content | ConvertFrom-Json
```

Vous devriez voir des valeurs comme :
```json
{
  "label": "FAKE",
  "fake_probability": 0.9823,
  "real_probability": 0.0177,
  "confidence": 0.9823,
  ...
}
```

---

## 🛠️ Dépannage

### Erreur : "FileNotFoundError: naive_bayes_model.pkl"

**Cause** : Les fichiers ne sont pas au bon endroit

**Solution** :
1. Vérifiez le chemin exact : `backend/app/ml/models/`
2. Vérifiez les noms de fichiers (case-sensitive sur Linux/Mac)
3. Vérifiez que ce ne sont pas des dossiers au lieu de fichiers

```powershell
# Vérifier sur Windows
ls backend\app\ml\models\
```

### Erreur : "AttributeError: 'NoneType' object has no attribute 'transform'"

**Cause** : Le modèle ou vectorizer n'a pas été chargé correctement

**Solution** :
1. Vérifiez que les fichiers `.pkl` ne sont pas corrompus
2. Vérifiez qu'ils ont été créés avec scikit-learn compatible
3. Essayez de recharger les fichiers : `pickle.load(open(...))`

```python
# Test manuel
import pickle
with open('backend/app/ml/models/naive_bayes_model.pkl', 'rb') as f:
    model = pickle.load(f)
print(f"Type: {type(model)}")
print(f"Méthodes: {[m for m in dir(model) if not m.startswith('_')]}")
```

### Erreur : "ValueError: shape mismatch"

**Cause** : Le texte d'entrée a une forme différente de ce que le modèle attend

**Solution** :
1. Vérifiez que le vocabulaire du vectorizer correspond
2. Assurez-vous que le prétraitement du texte est le même qu'à l'entraînement
3. Utilisez le même vectorizer qui a servi à l'entraînement

### Le modèle retourne des probabilités nulles

**Cause** : Le modèle est peut-être mal entraîné ou ne converge pas

**Solution** :
1. Vérifiez les accuracy du modèle en développement
2. Assurez-vous qu'il y a assez de données d'entraînement
3. Vérifiez les hyperparamètres (alpha, fit_prior, etc.)

---

## 📊 Créer vos propres modèles

Si vous n'avez pas encore de modèles, voici un exemple pour les créer :

### Créer `backend/train_models.py`

```python
"""
Script pour créer et sauvegarder les modèles NLP
"""
import pickle
from pathlib import Path
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import ComplementNB
from sklearn.model_selection import train_test_split

# Données d'entraînement (remplacez par vos données réelles)
texts = ["...", "...", ...]  # Vos textes
labels = [0, 1, 0, ...]      # 0 = REAL, 1 = FAKE

# 1. Vectorizer TF-IDF
vectorizer = TfidfVectorizer(max_features=5000, stop_words='english')
X = vectorizer.fit_transform(texts)

# 2. Entraîner Naive Bayes
model = ComplementNB()
model.fit(X, labels)

# 3. Sauvegarder
MODEL_DIR = Path(__file__).parent / "app" / "ml" / "models"
MODEL_DIR.mkdir(exist_ok=True)

with open(MODEL_DIR / "naive_bayes_model.pkl", "wb") as f:
    pickle.dump(model, f)

with open(MODEL_DIR / "tfidf_vectorizer.pkl", "wb") as f:
    pickle.dump(vectorizer, f)

print("✓ Modèles sauvegardés")

# 4. Tester
from sklearn.metrics import accuracy_score
X_test = vectorizer.transform(texts[:10])
predictions = model.predict(X_test)
print(f"Accuracy: {accuracy_score(labels[:10], predictions):.2%}")
```

Exécutez-le :
```powershell
cd backend
python train_models.py
```

---

## 📁 Exemple de structure finale

```
backend/
├── main.py
├── requirements.txt
├── train_models.py           # (optionnel) Script d'entraînement
├── app/
│   ├── __init__.py
│   ├── ml/
│   │   ├── __init__.py
│   │   ├── classifier.py     # Modifié pour charger les .pkl
│   │   └── models/
│   │       ├── naive_bayes_model.pkl
│   │       └── tfidf_vectorizer.pkl
│   ├── services/
│   │   └── chatbot_service.py
│   └── schemas/
│       └── models.py
└── .venv/
```

---

## ✅ Checklist

- [ ] Dossier `models/` créé dans `backend/app/ml/`
- [ ] Fichiers `.pkl` placés dans le dossier
- [ ] classifier.py modifié pour charger les modèles
- [ ] Backend redémarré
- [ ] Message "✓ Modèles chargés" visible dans les logs
- [ ] Test API réussi
- [ ] Probabilités raisonnables (0-1)
- [ ] Confiance > 60% pour les prédictions nettes

---

## 💡 Tips

### Optimisation de la taille
```python
# Si vos fichiers sont énormes, compressez-les
import gzip
with gzip.open("model.pkl.gz", "wb") as f:
    pickle.dump(model, f)
```

### Versionning des modèles
```python
# Nommez vos modèles avec une version
# naive_bayes_model_v2.pkl
# tfidf_vectorizer_v2.pkl

MODEL_PATH = MODEL_DIR / "naive_bayes_model_v2.pkl"
```

### Validation des modèles au démarrage
```python
def _validate_models():
    if not _models_loaded:
        raise RuntimeError("Models failed to load on startup")
    
    # Test rapide
    test_text = "This is a test"
    try:
        X = _vectorizer.transform([test_text])
        _model.predict(X)
    except Exception as e:
        raise RuntimeError(f"Model validation failed: {e}")
```

---

## 📚 Ressources

- [Scikit-learn Naive Bayes](https://scikit-learn.org/stable/modules/naive_bayes.html)
- [TF-IDF Vectorizer](https://scikit-learn.org/stable/modules/generated/sklearn.feature_extraction.text.TfidfVectorizer.html)
- [Pickle Documentation](https://docs.python.org/3/library/pickle.html)

---

**Bon entraînement ! 🚀**
