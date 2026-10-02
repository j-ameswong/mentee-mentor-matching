import { ArrowLeft, ArrowRight, Check, Play, X } from 'lucide-react'
import type { DemoState, Page, Role } from '../demo/model'

export const tourSteps: {
  role: Role
  page: Page
  target: string
  title: string
  description: string
  task?: string
  complete?: (state: DemoState) => boolean
}[] = [
  {
    role: 'mentee',
    page: 'overview',
    target: 'welcome',
    title: 'How the demo works',
    description:
      'Follow a mentoring request as a mentee and mentor, then review accounts and support as an administrator. The tour uses separate data. Your previous changes are restored when you exit.',
  },
  {
    role: 'mentee',
    page: 'discover',
    target: 'mentor-card',
    title: 'Send a mentoring request',
    description:
      'You are Ava, a first-year mentee. Mentors are sorted by shared interests and listed by alias. Open campus.coder’s profile using the arrow on their card and write a short introduction.',
    task: 'Send a request to campus.coder.',
    complete: (s) =>
      s.matches.some(
        (m) =>
          m.mentee === 'ava' && m.mentor === 'maya' && ['pending', 'active'].includes(m.status),
      ),
  },
  {
    role: 'mentor',
    page: 'matches',
    target: 'my-request',
    title: 'Accept a request as a mentor',
    description:
      'You are now Maya, the mentor using the alias campus.coder. Ava’s request appears under cs.student. Accept it to create an active connection.',
    task: 'Accept the request from cs.student.',
    complete: (s) =>
      s.matches.some((m) => m.mentee === 'ava' && m.mentor === 'maya' && m.status === 'active'),
  },
  {
    role: 'mentee',
    page: 'matches',
    target: 'my-request',
    title: 'View the accepted connection',
    description:
      'Back in Ava’s view, Maya’s full name is now visible. Open her profile to see the contact details. Acceptance also closes Ava’s other pending requests and uses one of Maya’s available places.',
  },
  {
    role: 'mentee',
    page: 'notifications',
    target: 'inbox',
    title: 'Check notifications',
    description:
      'The inbox records requests, responses, account changes and support decisions. You can mark individual notifications as read or use Mark all as read.',
  },
  {
    role: 'admin',
    page: 'approvals',
    target: 'approvals',
    title: 'Approve an account',
    description:
      'You are now Robin, the administrator. New accounts need approval before they can send or accept requests. Approve Lily’s account to enable matching for her.',
    task: 'Approve Lily’s account.',
    complete: (s) => !!s.people.find((p) => p.id === 'lily')?.approved,
  },
  {
    role: 'admin',
    page: 'support',
    target: 'tickets',
    title: 'Resolve a support request',
    description:
      'Luca has asked what to discuss at a first mentoring meeting. Select Share guidance & resolve to send the example response. Administrators also review reports and withdrawal requests here.',
    task: 'Resolve Luca’s support request.',
    complete: (s) => !!s.tickets.find((t) => t.id === 'ticket-luca')?.resolved,
  },
  {
    role: 'mentee',
    page: 'overview',
    target: 'welcome',
    title: 'Tour complete',
    description:
      'You have tried matching, notifications, account approval and support. Select Finish tour to restore your previous changes. You can then try profile editing, waitlists, mentor capacity and semester management.',
  },
]

export function Tour({
  step,
  state,
  onStep,
  onClose,
}: {
  step: number
  state: DemoState
  onStep: (step: number) => void
  onClose: () => void
}) {
  const current = tourSteps[step]
  const completed = !current.complete || current.complete(state)
  return (
    <aside className="tour-panel" aria-label="Guided tour">
      <div className="tour-top">
        <span>
          <Play size={13} fill="currentColor" />
          GUIDED TOUR
        </span>
        <button className="icon-button" onClick={onClose} aria-label="Exit guided tour">
          <X size={18} />
        </button>
      </div>
      <div className="tour-dots" role="img" aria-label={`Step ${step + 1} of ${tourSteps.length}`}>
        {tourSteps.map((_, i) => (
          <span key={i} className={i <= step ? 'filled' : ''} />
        ))}
      </div>
      <div aria-live="polite">
        <p className="tour-perspective">
          {current.role === 'admin' ? 'Administrator' : current.role} view · {step + 1} of{' '}
          {tourSteps.length}
        </p>
        <h2>{current.title}</h2>
        <p>{current.description}</p>
        {current.task && (
          <div className={`tour-task ${completed ? 'done' : ''}`}>
            {completed ? <Check size={16} /> : <span className="task-circle" />}
            <span>{completed ? 'Step complete. Select Continue.' : current.task}</span>
          </div>
        )}
      </div>
      <div className="tour-actions">
        <button className="button ghost" disabled={step === 0} onClick={() => onStep(step - 1)}>
          <ArrowLeft size={15} />
          Back
        </button>
        <button
          className="button primary"
          onClick={() => (step === tourSteps.length - 1 ? onClose() : onStep(step + 1))}
        >
          {step === tourSteps.length - 1
            ? 'Finish tour'
            : completed
              ? 'Continue'
              : 'Show me & continue'}
          <ArrowRight size={15} />
        </button>
      </div>
    </aside>
  )
}
