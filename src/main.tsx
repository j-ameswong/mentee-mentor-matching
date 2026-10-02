import { Component, StrictMode, type ReactNode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'
import { STORAGE_KEY } from './demo/model'
import '@fontsource-variable/dm-sans'
import './styles.css'
import './responsive.css'

class ErrorBoundary extends Component<{ children: ReactNode }, { failed: boolean }> {
  state = { failed: false }
  static getDerivedStateFromError() {
    return { failed: true }
  }
  render() {
    if (this.state.failed)
      return (
        <main className="recovery">
          <h1>Unable to load the demo</h1>
          <p>Reset the demo data to try again. Changes made in this tab will be lost.</p>
          <button
            className="button primary"
            onClick={() => {
              try {
                sessionStorage.removeItem(STORAGE_KEY)
              } catch {
                /* Storage may be blocked. */
              }
              window.location.assign('/')
              window.location.reload()
            }}
          >
            Reset demo
          </button>
        </main>
      )
    return this.props.children
  }
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ErrorBoundary>
      <App />
    </ErrorBoundary>
  </StrictMode>,
)
