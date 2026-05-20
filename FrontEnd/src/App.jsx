import { useState } from 'react'
import { Header } from './components/layout/Header'
import AnalysisPage from './pages/Analysis/AnalysisPage'
import DashboardPage from './pages/Dashboard/DashboardPage'
import HistoryPage from './pages/History/HistoryPage'
import AboutPage from './pages/About/AboutPage'
import './styles/index.css'

const PAGES = {
  'Analyser':   AnalysisPage,
  'Dashboard':  DashboardPage,
  'Historique': HistoryPage,
  'À propos':   AboutPage,
}

export default function App() {
  const [activeTab, setActiveTab] = useState('Analyser')
  const Page = PAGES[activeTab]

  return (
    <div>
      <Header activeTab={activeTab} setActiveTab={setActiveTab} />
      <main>
        <Page key={activeTab} />
      </main>
    </div>
  )
}
