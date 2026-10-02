import { useState } from 'react'
import { ArrowRight, Check, Heart, LifeBuoy } from 'lucide-react'
import { useDemo } from '../demo/context'
import { activeMatches, personById, visibleName, type Ticket } from '../demo/model'
import { Badge, EmptyState, Field, PageHeading } from '../components/ui'

export function Support() {
  const { state, person, act, role } = useDemo()
  const [kind, setKind] = useState<Ticket['type']>('question')
  const [target, setTarget] = useState('')
  const [detail, setDetail] = useState('')
  const [showResolved, setShowResolved] = useState(false)
  const candidates = state.people.filter(
    (p) =>
      p.id !== person.id &&
      p.role !== 'admin' &&
      p.approved &&
      (kind !== 'withdrawal' ||
        activeMatches(state, person.id).some((m) => m.mentor === p.id || m.mentee === p.id)),
  )
  const tickets = state.tickets.filter(
    (t) => (role === 'admin' || t.author === person.id) && (showResolved || !t.resolved),
  )
  return (
    <>
      <PageHeading
        title="Support desk"
        description={
          role === 'admin'
            ? 'Review questions, account reports and withdrawal requests.'
            : 'Ask a question, report an account, or request to end a connection.'
        }
      />
      <div className={`support-layout ${role === 'admin' ? 'admin-support' : ''}`}>
        <div>
          {role !== 'admin' && (
            <form
              className="panel support-form"
              data-tour="support-form"
              onSubmit={(e) => {
                e.preventDefault()
                if (
                  act(
                    {
                      type: 'ticket',
                      actor: person.id,
                      target: kind === 'question' ? '' : target,
                      kind,
                      detail,
                    },
                    'Support request submitted.',
                  )
                ) {
                  setDetail('')
                  setTarget('')
                }
              }}
            >
              <h2>Submit a request</h2>
              <p className="muted">Requests stay in this demo. Use fictional details.</p>
              <Field label="Request type">
                <select
                  value={kind}
                  onChange={(e) => {
                    setKind(e.target.value as Ticket['type'])
                    setTarget('')
                  }}
                >
                  <option value="question">General question</option>
                  <option value="report">Report an account</option>
                  <option value="withdrawal">End a connection</option>
                </select>
              </Field>
              {kind !== 'question' && (
                <Field label={kind === 'withdrawal' ? 'Your connection' : 'Account to report'}>
                  <select required value={target} onChange={(e) => setTarget(e.target.value)}>
                    <option value="">Choose a person</option>
                    {candidates.map((p) => (
                      <option key={p.id} value={p.id}>
                        {visibleName(state, person.id, p)}
                      </option>
                    ))}
                  </select>
                </Field>
              )}
              {kind === 'withdrawal' && !candidates.length && (
                <p className="notice-panel">
                  You’ll need an active connection before you can request a withdrawal.
                </p>
              )}
              <Field label="Request details" hint={`${detail.length} / 1000 characters`}>
                <textarea
                  required
                  rows={5}
                  value={detail}
                  maxLength={1000}
                  onChange={(e) => setDetail(e.target.value)}
                  placeholder="Describe your question or the reason for this request."
                />
              </Field>
              <button
                className="button primary"
                disabled={!detail.trim() || (kind !== 'question' && !target)}
              >
                Send demo request
                <ArrowRight size={16} />
              </button>
            </form>
          )}
          <div className="section-heading">
            <h2>{role === 'admin' ? 'Support requests' : 'Your requests'}</h2>
            <label className="checkbox-label">
              <input
                type="checkbox"
                checked={showResolved}
                onChange={(e) => setShowResolved(e.target.checked)}
              />
              Include resolved
            </label>
          </div>
          <div className="ticket-list" data-tour="tickets">
            {tickets.map((t) => (
              <article className="ticket-card" key={t.id}>
                <div className="ticket-heading">
                  <Badge tone={t.resolved ? 'green' : 'amber'}>
                    {t.resolved ? 'Resolved' : 'Open'}
                  </Badge>
                  <span className="ticket-type">{t.type}</span>
                  <small>#{t.id.replace('ticket-', '').toUpperCase()}</small>
                </div>
                {role === 'admin' && (
                  <p className="ticket-people">
                    From <strong>{personById(state, t.author).name}</strong>
                    {t.target && (
                      <>
                        {' '}
                        · About <strong>{personById(state, t.target).name}</strong>
                      </>
                    )}
                  </p>
                )}
                <p>{t.detail}</p>
                {t.outcome && (
                  <div className="ticket-outcome">
                    <Check size={16} />
                    {t.outcome}
                  </div>
                )}
                {role === 'admin' && !t.resolved && (
                  <div className="connection-actions">
                    {t.type === 'question' && (
                      <button
                        className="button primary"
                        onClick={() =>
                          act(
                            {
                              type: 'resolve',
                              actor: person.id,
                              ticket: t.id,
                              decision: 'resolve',
                            },
                            'Request resolved. The member has been notified.',
                          )
                        }
                      >
                        Share guidance & resolve
                        <Check size={16} />
                      </button>
                    )}
                    {t.type === 'withdrawal' && (
                      <button
                        className="button primary"
                        onClick={() =>
                          act(
                            {
                              type: 'resolve',
                              actor: person.id,
                              ticket: t.id,
                              decision: 'approve-withdrawal',
                            },
                            'Withdrawal approved. Both people have been notified.',
                          )
                        }
                      >
                        Approve withdrawal
                      </button>
                    )}
                    {t.type === 'report' && (
                      <button
                        className="button danger"
                        onClick={() =>
                          act(
                            { type: 'resolve', actor: person.id, ticket: t.id, decision: 'flag' },
                            'Account flagged for review.',
                          )
                        }
                      >
                        Flag account
                      </button>
                    )}
                    {t.type !== 'question' && (
                      <button
                        className="button secondary"
                        onClick={() =>
                          act(
                            {
                              type: 'resolve',
                              actor: person.id,
                              ticket: t.id,
                              decision: 'dismiss',
                            },
                            'Request dismissed. The member has been notified.',
                          )
                        }
                      >
                        Dismiss request
                      </button>
                    )}
                  </div>
                )}
              </article>
            ))}
            {!tickets.length && (
              <EmptyState title={showResolved ? 'No requests' : 'No open requests'}>
                {role === 'admin'
                  ? 'New support requests will appear here.'
                  : 'Your open requests will appear here when you send one.'}
              </EmptyState>
            )}
          </div>
        </div>
        <aside className="support-aside">
          <span className="empty-icon">
            <LifeBuoy />
          </span>
          <h2>How requests are reviewed</h2>
          <p>
            Switch to the administrator view to review a submitted request and apply a decision.
          </p>
          <div>
            <Heart size={18} />
            <p>
              <strong>Withdrawals</strong>An administrator must approve the request before the
              connection ends.
            </p>
          </div>
          <div>
            <Check size={18} />
            <p>
              <strong>Account reports</strong>An administrator can flag an account to pause its
              activity, or dismiss the report.
            </p>
          </div>
          <p className="small">
            Portfolio demonstration only. This desk is not monitored and cannot provide real
            support.
          </p>
        </aside>
      </div>
    </>
  )
}
