import { useEffect, useRef, useState } from 'react'
import {
  ArrowUpRight,
  Bell,
  BookOpen,
  Check,
  ChevronDown,
  Compass,
  GraduationCap,
  HeartHandshake,
  HelpCircle,
  LayoutDashboard,
  LifeBuoy,
  Menu,
  RotateCcw,
  ShieldCheck,
  Sprout,
  Users,
  UserRound,
  X,
  type LucideIcon,
} from 'lucide-react'
import { DemoContext } from './demo/context'
import {
  initialState,
  MAX_ACTIONS,
  MAX_STORAGE_LENGTH,
  personaIds,
  personById,
  restore,
  roles,
  STORAGE_KEY,
  transition,
  type Action,
  type DemoState,
  type Page,
  type Role,
} from './demo/model'
import { Avatar, Modal } from './components/ui'
import { Tour, tourSteps } from './components/Tour'
import { Overview } from './pages/Overview'
import { Discover } from './pages/Discover'
import { Connections } from './pages/Connections'
import { Notifications, Profile } from './pages/Personal'
import { Support } from './pages/Support'
import { Approvals, Community } from './pages/Admin'
import { About } from './pages/About'

const navigation: { page: Page; label: string; icon: LucideIcon; roles: Role[] }[] = [
  {
    page: 'overview',
    label: 'Overview',
    icon: LayoutDashboard,
    roles: ['mentee', 'mentor', 'admin'],
  },
  { page: 'discover', label: 'Find a mentor', icon: Compass, roles: ['mentee'] },
  { page: 'matches', label: 'My connections', icon: HeartHandshake, roles: ['mentee', 'mentor'] },
  { page: 'notifications', label: 'Inbox', icon: Bell, roles: ['mentee', 'mentor', 'admin'] },
  { page: 'approvals', label: 'Account approvals', icon: UserRound, roles: ['admin'] },
  { page: 'community', label: 'Accounts', icon: Users, roles: ['admin'] },
  { page: 'profile', label: 'My profile', icon: UserRound, roles: ['mentee', 'mentor'] },
  { page: 'support', label: 'Support desk', icon: LifeBuoy, roles: ['mentee', 'mentor', 'admin'] },
  {
    page: 'about',
    label: 'About the project',
    icon: BookOpen,
    roles: ['mentee', 'mentor', 'admin'],
  },
]
function readRoute(): { role: Role; page: Page } {
  const [, maybeRole, maybePage] = window.location.hash.replace('#', '').split('/')
  const role = roles.includes(maybeRole as Role) ? (maybeRole as Role) : 'mentee'
  const page =
    navigation.find((n) => n.page === maybePage && n.roles.includes(role))?.page ?? 'overview'
  return { role, page }
}
function loadSession() {
  try {
    return restore(sessionStorage.getItem(STORAGE_KEY))
  } catch {
    return restore(null)
  }
}
function safeSetRoute(role: Role, page: Page, replace = false) {
  const path = `#/${role}/${page}`
  if (replace) window.history.replaceState(null, '', path)
  else if (window.location.hash !== path) window.history.pushState(null, '', path)
}

export default function App() {
  const [session, setSession] = useState(loadSession)
  const [route, setRoute] = useState(readRoute)
  const [tour, setTour] = useState<number | null>(null)
  const [tourState, setTourState] = useState<DemoState>(initialState)
  const originalRoute = useRef(route)
  const [menuOpen, setMenuOpen] = useState(false)
  const [resetOpen, setResetOpen] = useState(false)
  const [toast, setToast] = useState<{ text: string; error: boolean } | null>(null)
  const [storageUnavailable, setStorageUnavailable] = useState(false)
  const menuButton = useRef<HTMLButtonElement>(null)
  const sidebar = useRef<HTMLElement>(null)
  const state = tour === null ? session.state : tourState
  const { role, page } = route
  const person = personById(state, personaIds[role])
  const unread = state.notices.filter((n) => n.recipient === person.id && !n.read).length

  useEffect(() => {
    try {
      sessionStorage.setItem(STORAGE_KEY, JSON.stringify({ version: 1, actions: session.actions }))
    } catch {
      setStorageUnavailable(true)
    }
  }, [session])
  useEffect(() => {
    const changed = () => {
      if (tour !== null) {
        safeSetRoute(tourSteps[tour].role, tourSteps[tour].page, true)
        return
      }
      setRoute(readRoute())
      setMenuOpen(false)
    }
    window.addEventListener('popstate', changed)
    window.addEventListener('hashchange', changed)
    return () => {
      window.removeEventListener('popstate', changed)
      window.removeEventListener('hashchange', changed)
    }
  }, [tour])
  useEffect(() => {
    document.title = `${navigation.find((n) => n.page === page)?.label ?? 'Overview'} · UniConnect`
    window.scrollTo({ top: 0, behavior: 'instant' })
    const frame = requestAnimationFrame(() =>
      document.querySelector<HTMLElement>('main h1')?.focus({ preventScroll: true }),
    )
    return () => cancelAnimationFrame(frame)
  }, [page, role])
  useEffect(() => {
    if (!toast) return
    const timer = setTimeout(() => setToast(null), 6500)
    return () => clearTimeout(timer)
  }, [toast])
  useEffect(() => {
    if (tour === null) return
    const el = document.querySelector<HTMLElement>(`[data-tour="${tourSteps[tour].target}"]`)
    el?.classList.add('tour-highlight')
    return () => el?.classList.remove('tour-highlight')
  }, [tour, route, state])
  useEffect(() => {
    if (!menuOpen) return
    const previous = document.activeElement as HTMLElement
    sidebar.current?.querySelector<HTMLElement>('button:not([disabled])')?.focus()
    const handle = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        setMenuOpen(false)
        menuButton.current?.focus()
      }
      if (e.key === 'Tab') {
        const nodes = [
          ...(sidebar.current?.querySelectorAll<HTMLElement>('button:not([disabled]), a[href]') ??
            []),
        ].filter((n) => n.offsetParent !== null)
        const first = nodes[0],
          last = nodes[nodes.length - 1]
        if (e.shiftKey && document.activeElement === first) {
          e.preventDefault()
          last?.focus()
        }
        if (!e.shiftKey && document.activeElement === last) {
          e.preventDefault()
          first?.focus()
        }
      }
    }
    document.addEventListener('keydown', handle)
    return () => {
      document.removeEventListener('keydown', handle)
      previous?.focus()
    }
  }, [menuOpen])

  function navigate(page: Page) {
    if (tour !== null) return
    setRoute({ role, page })
    safeSetRoute(role, page)
    setMenuOpen(false)
  }
  function setRole(next: Role, page: Page = 'overview') {
    if (tour !== null) return
    setRoute({ role: next, page })
    safeSetRoute(next, page)
    setMenuOpen(false)
    setToast(null)
  }
  function act(action: Action, success?: string): boolean {
    // All personas are public demo characters. The UI actor still follows the current perspective.
    if (action.actor !== person.id) return false
    const actions = [...session.actions, action]
    if (
      tour === null &&
      (actions.length > MAX_ACTIONS ||
        JSON.stringify({ version: 1, actions }).length > MAX_STORAGE_LENGTH)
    ) {
      setToast({ text: 'Demo limit reached. Reset the demo to continue.', error: true })
      return false
    }
    const result = transition(state, action)
    if (result.error) {
      setToast({ text: result.error, error: true })
      return false
    }
    if (tour !== null) setTourState(result.state)
    else setSession({ state: result.state, actions })
    if (success) setToast({ text: success, error: false })
    return true
  }
  function startTour() {
    if (tour !== null) return
    originalRoute.current = route
    setTourState(initialState())
    setTour(0)
    setRoute({ role: 'mentee', page: 'overview' })
    safeSetRoute('mentee', 'overview', true)
    setToast(null)
    setMenuOpen(false)
  }
  function closeTour() {
    setTour(null)
    setRoute(originalRoute.current)
    safeSetRoute(originalRoute.current.role, originalRoute.current.page, true)
    setToast({ text: 'Tour closed. Your previous changes have been restored.', error: false })
  }
  function moveTour(next: number) {
    if (tour === null) return
    if (next > tour) {
      let updated = tourState
      const perform = (action: Action) => {
        updated = transition(updated, action).state
      }
      // The walkthrough can also demonstrate an action for visitors who prefer to watch.
      if (
        tour === 1 &&
        !updated.matches.some(
          (m) =>
            m.mentee === 'ava' && m.mentor === 'maya' && ['pending', 'active'].includes(m.status),
        )
      )
        perform({
          type: 'apply',
          actor: 'ava',
          mentor: 'maya',
          message:
            'Hi, could you help me with first-year coding projects and planning my study schedule?',
        })
      if (
        tour === 2 &&
        !updated.matches.some(
          (m) => m.mentee === 'ava' && m.mentor === 'maya' && m.status === 'active',
        )
      ) {
        perform({ type: 'capacity', actor: 'maya', capacity: 4 })
        if (
          !updated.matches.some(
            (m) => m.mentee === 'ava' && m.mentor === 'maya' && m.status === 'pending',
          )
        )
          perform({
            type: 'apply',
            actor: 'ava',
            mentor: 'maya',
            message: 'Could you help me with coding projects and planning my study schedule?',
          })
        const match = updated.matches.find(
          (m) => m.mentee === 'ava' && m.mentor === 'maya' && m.status === 'pending',
        )
        if (match) perform({ type: 'decide', actor: 'maya', match: match.id, accept: true })
      }
      if (tour === 5 && !personById(updated, 'lily').approved)
        perform({ type: 'approve', actor: 'robin', person: 'lily' })
      if (tour === 6 && !updated.tickets.find((t) => t.id === 'ticket-luca')?.resolved)
        perform({ type: 'resolve', actor: 'robin', ticket: 'ticket-luca', decision: 'resolve' })
      setTourState(updated)
    }
    setTour(next)
    setRoute({ role: tourSteps[next].role, page: tourSteps[next].page })
    safeSetRoute(tourSteps[next].role, tourSteps[next].page, true)
    setToast(null)
  }
  const renderPage = () => {
    switch (page) {
      case 'overview':
        return <Overview />
      case 'discover':
        return <Discover />
      case 'matches':
        return <Connections />
      case 'notifications':
        return <Notifications />
      case 'profile':
        return <Profile />
      case 'support':
        return <Support />
      case 'approvals':
        return <Approvals />
      case 'community':
        return <Community />
      case 'about':
        return <About />
    }
  }
  return (
    <DemoContext value={{ state, person, role, act, navigate, setRole, startTour }}>
      <a
        className="skip-link"
        href="#main-content"
        onClick={(e) => {
          e.preventDefault()
          document.getElementById('main-content')?.focus()
        }}
      >
        Skip to content
      </a>
      <div className={`app-shell ${tour !== null ? 'tour-active' : ''}`}>
        <aside
          ref={sidebar}
          tabIndex={0}
          className={`sidebar ${menuOpen ? 'is-open' : ''}`}
          aria-label="Main navigation"
        >
          <div className="brand-row">
            <button
              className="brand"
              onClick={() => navigate('overview')}
              disabled={tour !== null}
              aria-label="UniConnect home"
            >
              <span className="brand-mark">
                <Sprout size={27} />
              </span>
              <span>
                uni<span className="brand-light">connect</span>
                <small>STUDENT MENTORING</small>
              </span>
            </button>
            <button
              className="icon-button mobile-close"
              aria-label="Close navigation"
              onClick={() => setMenuOpen(false)}
            >
              <X size={21} />
            </button>
          </div>
          <div className="sidebar-label">
            {role === 'admin' ? 'ADMINISTRATOR' : role.toUpperCase()} VIEW
          </div>
          <nav>
            {navigation
              .filter((n) => n.roles.includes(role))
              .map(({ page: target, label, icon: Icon }) => (
                <button
                  key={target}
                  aria-current={page === target ? 'page' : undefined}
                  className={`nav-item ${target === 'support' ? 'nav-divider' : ''}`}
                  onClick={() => navigate(target)}
                  disabled={tour !== null}
                >
                  <Icon size={19} strokeWidth={1.6} />
                  <span>{label}</span>
                  {target === 'notifications' && unread > 0 && (
                    <span className="nav-count" aria-hidden="true">
                      {unread}
                    </span>
                  )}
                  {target === 'approvals' && state.people.some((p) => !p.approved) && (
                    <span className="nav-count" aria-hidden="true">
                      {state.people.filter((p) => !p.approved).length}
                    </span>
                  )}
                </button>
              ))}
          </nav>
          <div className="sidebar-bottom">
            <div className="tour-invite">
              <span className="tour-invite-icon">
                <Compass size={22} strokeWidth={1.4} />
              </span>
              <h3>Guided tour</h3>
              <p>Try matching, account approval and support in eight steps.</p>
              <button onClick={startTour} disabled={tour !== null}>
                Start guided tour
                <ArrowUpRight size={16} />
              </button>
            </div>
            <div className="sidebar-campus">
              <GraduationCap size={21} />
              <span>
                University of Sheffield<small>COM1001 · Team 17 · 2024–25</small>
              </span>
            </div>
          </div>
        </aside>
        {menuOpen && (
          <button
            className="menu-scrim"
            aria-label="Close navigation overlay"
            onClick={() => setMenuOpen(false)}
          />
        )}
        <div className="workspace" inert={menuOpen || undefined}>
          <header className="topbar">
            <div className="breadcrumb">
              <button
                ref={menuButton}
                className="icon-button mobile-menu"
                onClick={() => setMenuOpen(true)}
                aria-label="Open navigation"
                aria-expanded={menuOpen}
              >
                <Menu size={23} />
              </button>
              <span className="desktop-breadcrumb">
                {role === 'admin' ? 'Administrator' : role === 'mentor' ? 'Mentor' : 'Mentee'}
                <span className="breadcrumb-slash">/</span>
              </span>
              <strong>{navigation.find((n) => n.page === page)?.label}</strong>
            </div>
            <div className="topbar-actions">
              <span className="demo-pill">
                <span />
                INTERACTIVE DEMO
              </span>
              <button
                className="icon-button header-bell"
                aria-label={`Inbox, ${unread} unread updates`}
                disabled={tour !== null}
                onClick={() => navigate('notifications')}
              >
                <Bell size={19} />
                {unread > 0 && <i />}
              </button>
              <Avatar person={person} size="small" named />
            </div>
          </header>
          <div className="demo-toolbar">
            <p>
              <span className="demo-toolbar-icon">
                <ShieldCheck size={15} />
              </span>
              {tour !== null
                ? 'Guided tour · Your previous changes are saved'
                : 'Portfolio demo · All data is fictional'}
            </p>
            <div>
              <label className="role-picker">
                <span>View as</span>
                <select
                  aria-label="Demo role"
                  value={role}
                  disabled={tour !== null}
                  onChange={(e) => setRole(e.target.value as Role)}
                >
                  <option value="mentee">Mentee</option>
                  <option value="mentor">Mentor</option>
                  <option value="admin">Administrator</option>
                </select>
                <ChevronDown size={13} />
              </label>
              <button
                className="reset-button"
                disabled={tour !== null}
                onClick={() => setResetOpen(true)}
              >
                <RotateCcw size={13} />
                <span>Reset</span>
              </button>
            </div>
          </div>
          {storageUnavailable && (
            <div className="storage-notice" role="status">
              Browser storage is unavailable. Changes will reset on refresh.
            </div>
          )}
          {person.flagged && (
            <div className="storage-notice" role="status">
              This demo account is flagged. Switch to Administrator → Accounts to clear its flag and
              resume activity.
            </div>
          )}
          <main id="main-content" key={role + page} tabIndex={-1}>
            {renderPage()}
          </main>
          <footer className="footer">
            <span>
              <Sprout size={14} />
              UniConnect · Independent student project
            </span>
            <span>
              Fictional data ·{' '}
              {storageUnavailable ? 'Changes reset on refresh' : 'Changes saved in this tab'}
            </span>
          </footer>
        </div>
      </div>
      {tour !== null && <Tour step={tour} state={state} onStep={moveTour} onClose={closeTour} />}
      <div className="toast-region" role="status" aria-live="polite">
        {toast && (
          <div className={`toast ${toast.error ? 'error' : ''}`}>
            {toast.error ? <HelpCircle size={19} /> : <Check size={19} />}
            <span>{toast.text}</span>
            <button
              className="icon-button"
              onClick={() => setToast(null)}
              aria-label="Dismiss notification"
            >
              <X size={16} />
            </button>
          </div>
        )}
      </div>
      {resetOpen && (
        <Modal title="Reset demo?" onClose={() => setResetOpen(false)}>
          <p className="modal-copy">
            Restore the starting profiles, requests and settings. Changes made in this tab will be
            discarded.
          </p>
          <div className="form-footer">
            <button className="button secondary" onClick={() => setResetOpen(false)}>
              Cancel
            </button>
            <button
              className="button primary"
              onClick={() => {
                setSession({ state: initialState(), actions: [] })
                setRole('mentee')
                setResetOpen(false)
                setToast({ text: 'Demo reset.', error: false })
              }}
            >
              <RotateCcw size={16} />
              Reset demo
            </button>
          </div>
        </Modal>
      )}
    </DemoContext>
  )
}
