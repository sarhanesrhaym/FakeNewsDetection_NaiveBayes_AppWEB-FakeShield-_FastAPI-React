# 🧪 Guide de Tests et Vérifications

## 1️⃣ Tests Unitaires Backend

### Installation de pytest

```powershell
cd backend
pip install pytest pytest-asyncio httpx
```

### Créer `backend/tests/test_analyze.py`

```python
"""
Test de l'endpoint /analyze
"""
from fastapi.testclient import TestClient
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from main import app

client = TestClient(app)


def test_analyze_fake_news():
    """Test que le modèle détecte les fake news"""
    response = client.post("/analyze", json={
        "text": "BREAKING: Secret government conspiracy revealed!!! Urgent!!! Share before deleted!!!"
    })
    assert response.status_code == 200
    data = response.json()
    assert data["label"] in ["FAKE", "REAL"]
    assert 0 <= data["confidence"] <= 1
    assert data["fake_probability"] + data["real_probability"] == pytest.approx(1.0, abs=0.01)


def test_analyze_real_news():
    """Test que le modèle détecte les vraies nouvelles"""
    response = client.post("/analyze", json={
        "text": "According to official statement from government spokesperson, new policy announced today. Reuters reported..."
    })
    assert response.status_code == 200
    data = response.json()
    assert data["label"] in ["FAKE", "REAL"]
    assert 0 <= data["confidence"] <= 1


def test_analyze_short_text():
    """Test que le texte court est rejeté"""
    response = client.post("/analyze", json={
        "text": "Short text"
    })
    assert response.status_code == 422  # Validation error


def test_analyze_empty_text():
    """Test que le texte vide est rejeté"""
    response = client.post("/analyze", json={
        "text": ""
    })
    assert response.status_code == 422


def test_analyze_fields():
    """Test que tous les champs requis sont retournés"""
    response = client.post("/analyze", json={
        "text": "This is a normal text with enough content to be analyzed properly. It should pass validation."
    })
    assert response.status_code == 200
    data = response.json()
    
    required_fields = [
        "label",
        "fake_probability",
        "real_probability",
        "confidence",
        "word_count",
        "caps_ratio",
        "fake_indicators",
        "real_indicators"
    ]
    
    for field in required_fields:
        assert field in data, f"Missing field: {field}"
```

### Créer `backend/tests/test_chat.py`

```python
"""
Test de l'endpoint /chat
"""
from fastapi.testclient import TestClient
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from main import app

client = TestClient(app)


def test_chat_without_context():
    """Test que le chatbot répond sans contexte"""
    response = client.post("/chat", json={
        "message": "Hello",
        "context": {}
    })
    assert response.status_code == 200
    data = response.json()
    assert "reply" in data
    assert len(data["reply"]) > 0


def test_chat_with_context():
    """Test que le chatbot répond avec contexte"""
    response = client.post("/chat", json={
        "message": "Pourquoi fake?",
        "context": {
            "label": "FAKE",
            "confidence": 0.95,
            "fake_indicators": ["breaking", "secret"],
            "real_indicators": []
        }
    })
    assert response.status_code == 200
    data = response.json()
    assert "reply" in data
    assert "FAKE" in data["reply"] or "fake" in data["reply"].lower()


def test_chat_why_question():
    """Test que le chatbot répond aux questions 'Pourquoi'"""
    response = client.post("/chat", json={
        "message": "Pourquoi c'est classé RÉEL?",
        "context": {
            "label": "REAL",
            "confidence": 0.88,
            "fake_indicators": [],
            "real_indicators": ["selon", "officiel"]
        }
    })
    assert response.status_code == 200
    data = response.json()
    assert len(data["reply"]) > 0


def test_chat_model_question():
    """Test que le chatbot répond aux questions sur le modèle"""
    response = client.post("/chat", json={
        "message": "Comment fonctionne le modèle?",
        "context": {}
    })
    assert response.status_code == 200
    data = response.json()
    assert "Naive Bayes" in data["reply"] or "TF-IDF" in data["reply"] or "NLP" in data["reply"]
```

### Créer `backend/tests/test_history.py`

```python
"""
Test des endpoints /history et /stats
"""
from fastapi.testclient import TestClient
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from main import app

client = TestClient(app)


def test_health():
    """Test que l'API répond"""
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_history_empty():
    """Test l'historique (vide au départ)"""
    response = client.get("/history")
    assert response.status_code == 200
    data = response.json()
    assert "history" in data
    assert "stats" in data
    assert isinstance(data["history"], list)


def test_stats():
    """Test les statistiques"""
    response = client.get("/stats")
    assert response.status_code == 200
    data = response.json()
    
    required_fields = ["total", "fake_count", "real_count", "fake_rate"]
    for field in required_fields:
        assert field in data, f"Missing field: {field}"


def test_stats_consistency():
    """Test que les stats sont cohérentes"""
    response = client.get("/stats")
    assert response.status_code == 200
    data = response.json()
    
    assert data["total"] == data["fake_count"] + data["real_count"]
    assert 0 <= data["fake_rate"] <= 100
```

### Exécuter les tests

```powershell
cd backend
pytest tests/ -v
```

Ou tester un fichier spécifique :
```powershell
pytest tests/test_analyze.py -v
```

---

## 2️⃣ Tests d'Intégration

### Créer `backend/tests/test_integration.py`

```python
"""
Tests d'intégration du pipeline complet
"""
from fastapi.testclient import TestClient
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from main import app

client = TestClient(app)


def test_full_pipeline():
    """Test le pipeline complet: analyze -> chat -> history"""
    # 1. Analyser un texte
    analyze_response = client.post("/analyze", json={
        "text": "BREAKING NEWS!!! Secret government cover-up revealed today! "
                "This shocking discovery exposes the truth they don't want you to know!"
    })
    assert analyze_response.status_code == 200
    analysis = analyze_response.json()
    
    # 2. Poser une question au chatbot
    chat_response = client.post("/chat", json={
        "message": "Pourquoi ce texte est classé comme fake?",
        "context": analysis
    })
    assert chat_response.status_code == 200
    chat_data = chat_response.json()
    assert len(chat_data["reply"]) > 0
    
    # 3. Vérifier l'historique
    history_response = client.get("/history")
    assert history_response.status_code == 200
    history_data = history_response.json()
    assert len(history_data["history"]) > 0
    assert history_data["stats"]["total"] >= 1


def test_multiple_analyses_stats():
    """Test que les stats sont mises à jour correctement"""
    initial_stats = client.get("/stats").json()
    initial_total = initial_stats["total"]
    
    # Analyser 3 textes
    for i in range(3):
        client.post("/analyze", json={
            "text": f"This is test text number {i} with enough content to be analyzed properly"
        })
    
    updated_stats = client.get("/stats").json()
    assert updated_stats["total"] == initial_total + 3


def test_models_loading():
    """Test que les modèles sont bien chargés"""
    from app.ml.classifier import _models_loaded
    # Ce test vérifie qu'on ne plante pas au démarrage
    response = client.get("/")
    assert response.status_code == 200
```

### Exécuter les tests d'intégration

```powershell
pytest tests/test_integration.py -v
```

---

## 3️⃣ Tests Frontend (optionnel avec Vitest)

### Installation

```powershell
cd frontend
npm install --save-dev vitest @testing-library/react jsdom
```

### Créer `frontend/src/__tests__/api.test.js`

```javascript
import { describe, it, expect, beforeAll } from 'vitest'

const API_URL = 'http://localhost:8000'

describe('API Integration Tests', () => {
  it('should fetch stats from backend', async () => {
    const response = await fetch(`${API_URL}/stats`)
    expect(response.ok).toBe(true)
    const data = await response.json()
    expect(data).toHaveProperty('total')
    expect(data).toHaveProperty('fake_count')
    expect(data).toHaveProperty('real_count')
  })

  it('should analyze text', async () => {
    const response = await fetch(`${API_URL}/analyze`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text: 'This is a test text with enough content to be analyzed' })
    })
    expect(response.ok).toBe(true)
    const data = await response.json()
    expect(data).toHaveProperty('label')
    expect(['FAKE', 'REAL']).toContain(data.label)
  })

  it('should chat with context', async () => {
    const response = await fetch(`${API_URL}/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message: 'Why is this fake?',
        context: { label: 'FAKE', confidence: 0.9 }
      })
    })
    expect(response.ok).toBe(true)
    const data = await response.json()
    expect(data).toHaveProperty('reply')
  })
})
```

### Exécuter les tests

```powershell
npm run test
```

---

## 4️⃣ Tests Manuels - Checklist

### Backend

- [ ] GET `/` retourne status "ok"
- [ ] POST `/analyze` avec texte fake retourne FAKE avec confiance > 60%
- [ ] POST `/analyze` avec texte réel retourne REAL
- [ ] POST `/analyze` avec texte court retourne erreur 422
- [ ] GET `/history` retourne une liste
- [ ] GET `/stats` retourne des chiffres cohérents
- [ ] POST `/chat` retourne une réponse valide
- [ ] POST `/chat` avec contexte FAKE explique bien
- [ ] POST `/chat` avec contexte REAL explique bien

### Frontend

- [ ] Page "Analyser" s'affiche correctement
- [ ] Analyse un texte et affiche le résultat
- [ ] Affiche le label (FAKE/REAL) en couleur
- [ ] Affiche la confiance en pourcentage
- [ ] Chatbot répond aux questions
- [ ] Page "Historique" affiche les dernières analyses
- [ ] Page "Dashboard" affiche les graphiques
- [ ] Dashboard se met à jour automatiquement
- [ ] Les statistiques sont correctes
- [ ] Design responsive sur mobile/tablet/desktop
- [ ] Pas d'erreurs dans la console

### Intégration

- [ ] Backend + Frontend communiquent
- [ ] Pas d'erreurs CORS
- [ ] Historique persiste
- [ ] Statistiques se mettent à jour
- [ ] Chatbot utilise Gemini (si activé)
- [ ] Modèles .pkl sont chargés (si fournis)

---

## 5️⃣ Test de Performance

### Load test simple

```python
"""
backend/tests/test_performance.py
"""
import time
from fastapi.testclient import TestClient
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from main import app

client = TestClient(app)


def test_analyze_performance():
    """Test que l'analyse prend < 100ms"""
    start = time.time()
    response = client.post("/analyze", json={
        "text": "This is a normal text with enough content to test the analyze endpoint performance"
    })
    elapsed = time.time() - start
    
    assert response.status_code == 200
    assert elapsed < 0.1, f"Analysis took {elapsed:.2f}s, expected < 0.1s"


def test_chat_performance():
    """Test que le chat prend < 200ms"""
    start = time.time()
    response = client.post("/chat", json={
        "message": "Hello",
        "context": {"label": "FAKE", "confidence": 0.9}
    })
    elapsed = time.time() - start
    
    assert response.status_code == 200
    assert elapsed < 0.2, f"Chat took {elapsed:.2f}s, expected < 0.2s"


def test_concurrent_analyses():
    """Test 10 analyses simultanées"""
    import concurrent.futures
    
    def analyze():
        return client.post("/analyze", json={
            "text": "This is a test text for concurrent performance testing with enough content"
        })
    
    start = time.time()
    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
        futures = [executor.submit(analyze) for _ in range(10)]
        responses = [f.result() for f in concurrent.futures.as_completed(futures)]
    elapsed = time.time() - start
    
    assert all(r.status_code == 200 for r in responses)
    assert elapsed < 2.0, f"10 analyses took {elapsed:.2f}s, expected < 2s"
```

Exécuter :
```powershell
pytest tests/test_performance.py -v
```

---

## 6️⃣ Dépannage des tests

### Erreur: "Connection refused"
Le backend n'est pas lancé. Assurez-vous que `uvicorn` tourne.

### Erreur: "ModuleNotFoundError"
Assurez-vous que vous êtes dans le bon dossier `backend/` et qu'il y a un `__init__.py` dans `app/`.

### Les tests échouent aléatoirement
Mettez à jour les paths absolus ou utilisez `sys.path.insert()`.

### Fixture needed
Pour réinitialiser l'état entre les tests :
```python
@pytest.fixture(autouse=True)
def reset_history():
    from main import _history, _stats
    _history.clear()
    _stats.clear()
    yield
```

---

## ✅ Checklist finale

- [ ] Tous les tests unitaires passent
- [ ] Tests d'intégration réussissent
- [ ] Tests de performance sont OK
- [ ] Aucune erreur dans les logs
- [ ] Frontend et Backend communiquent
- [ ] Gemini API fonctionne (si activé)
- [ ] Modèles .pkl chargent bien (si fournis)
- [ ] Dashboard affiche les données
- [ ] Historique se met à jour
- [ ] Pas d'erreurs CORS
- [ ] Design responsive validé

---

## 📚 Ressources

- [Pytest Documentation](https://docs.pytest.org/)
- [FastAPI Testing](https://fastapi.tiangolo.com/tutorial/testing/)
- [Vitest Guide](https://vitest.dev/)
- [React Testing Library](https://testing-library.com/react)

---

**Bon testing ! 🚀**
