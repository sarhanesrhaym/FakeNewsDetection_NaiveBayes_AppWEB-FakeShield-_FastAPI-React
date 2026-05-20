import { Icon } from '../../components/ui/Icon'

const INFO_CARDS = [
  {
    icon: 'database',
    title: 'Dataset',
    desc: 'ISOT Fake News Dataset — ~44 000 articles (22K fake / 22K real), collectés sur Reuters et des sites de désinformation vérifiés.',
  },
  {
    icon: 'brain',
    title: 'Modèle ML',
    desc: 'Naive Bayes (MultinomialNB & ComplementNB) avec vectorisation TF-IDF. Pipeline Scikit-learn optimisé.',
  },
  {
    icon: 'trending_up',
    title: 'Performance',
    desc: 'Accuracy ~96% avec validation croisée 5-fold. Precision, Recall et F1-score équilibrés sur les deux classes.',
  },
  {
    icon: 'layers',
    title: 'Architecture',
    desc: 'React 18 (frontend) + FastAPI Python (backend) + Scikit-learn (ML). Communicants via API REST JSON.',
  },
]

const PIPELINE = [
  { step: '1', label: 'Input texte',    desc: 'React UI',         color: 'var(--accent)' },
  { step: '2', label: 'FastAPI',        desc: 'POST /analyze',    color: '#a855f7' },
  { step: '3', label: 'Prétraitement',  desc: 'Tokenisation',     color: '#f59e0b' },
  { step: '4', label: 'TF-IDF',        desc: 'Vectorisation',    color: '#06b6d4' },
  { step: '5', label: 'Naive Bayes',   desc: 'Classification',   color: 'var(--fake)' },
  { step: '6', label: 'Résultat',      desc: 'JSON → UI',        color: 'var(--real)' },
]

export default function AboutPage() {
  return (
    <div className="page-narrow">
      <h1 style={{
        fontFamily: 'var(--display)',
        fontSize: 28,
        fontWeight: 800,
        letterSpacing: '-0.8px',
        marginBottom: 32,
      }}>
        À propos de FakeShield
      </h1>

      {/* Info cards */}
      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))',
        gap: 14,
        marginBottom: 28,
      }}>
        {INFO_CARDS.map(c => (
          <div key={c.title} className="card" style={{ padding: '22px 22px 20px', borderRadius: 'var(--r-lg)' }}>
            <div style={{
              width: 36,
              height: 36,
              borderRadius: 10,
              background: 'var(--bg3)',
              border: '1px solid var(--border)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              marginBottom: 14,
            }}>
              <Icon name={c.icon} size={17} color="var(--accent)" />
            </div>
            <div style={{
              fontFamily: 'var(--display)',
              fontWeight: 700,
              fontSize: 15,
              marginBottom: 8,
            }}>
              {c.title}
            </div>
            <div style={{
              color: 'var(--text-muted)',
              fontSize: 13.5,
              lineHeight: 1.65,
            }}>
              {c.desc}
            </div>
          </div>
        ))}
      </div>

      {/* Pipeline */}
      <div className="card" style={{ padding: '22px 24px', borderRadius: 'var(--r-lg)', marginBottom: 16 }}>
        <div style={{
          fontFamily: 'var(--display)',
          fontWeight: 700,
          fontSize: 16,
          marginBottom: 24,
          display: 'flex',
          alignItems: 'center',
          gap: 8,
        }}>
          <Icon name="zap" size={15} color="var(--accent)" />
          Pipeline de traitement
        </div>

        <div style={{
          display: 'flex',
          alignItems: 'center',
          overflowX: 'auto',
          paddingBottom: 4,
          gap: 0,
        }}>
          {PIPELINE.map((s, i, arr) => (
            <div key={s.step} style={{ display: 'flex', alignItems: 'center', flexShrink: 0 }}>
              <div style={{ textAlign: 'center', minWidth: 80 }}>
                <div style={{
                  width: 40,
                  height: 40,
                  borderRadius: '50%',
                  background: s.color,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontFamily: 'var(--mono)',
                  fontWeight: 700,
                  color: '#fff',
                  fontSize: 14,
                  margin: '0 auto 8px',
                }}>
                  {s.step}
                </div>
                <div style={{ fontSize: 11, fontWeight: 600, color: 'var(--text)', marginBottom: 2 }}>
                  {s.label}
                </div>
                <div style={{ fontSize: 10, color: 'var(--text-muted)', fontFamily: 'var(--mono)' }}>
                  {s.desc}
                </div>
              </div>

              {i < arr.length - 1 && (
                <div style={{
                  width: 28,
                  height: 1,
                  background: 'var(--border-active)',
                  margin: '0 2px',
                  flexShrink: 0,
                  position: 'relative',
                  top: -14,
                }} />
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Footer card */}
      <div style={{
        padding: '16px 20px',
        background: 'var(--bg2)',
        border: '1px solid var(--border)',
        borderRadius: 'var(--r-lg)',
        textAlign: 'center',
      }}>
        <div style={{
          fontFamily: 'var(--mono)',
          fontSize: 12,
          color: 'var(--text-muted)',
        }}>
          Master 1 Intelligence Artificielle & Objets Connectés
          · Université Ibn Tofail — Kénitra · 2025–2026
        </div>
      </div>
    </div>
  )
}
