import { useState } from 'react'
import {
  ArrowRight,
  Check,
  Clock3,
  Globe2,
  HeartHandshake,
  LockKeyhole,
  Mail,
  Users,
} from 'lucide-react'
import { useDemo } from '../demo/context'
import {
  activeMatches,
  freePlaces,
  isAvailable,
  personById,
  visibleName,
  type Match,
  type Person,
} from '../demo/model'
import { Avatar, Badge, EmptyState, Field, Modal, PageHeading } from '../components/ui'

const labels = {
  pending: 'Awaiting a reply',
  active: 'Connected',
  declined: 'Declined',
  cancelled: 'Closed',
  completed: 'Completed',
}

function Connection({ match }: { match: Match }) {
  const { state, person, act, navigate } = useDemo()
  const [profile, setProfile] = useState(false)
  const other = personById(state, person.role === 'mentor' ? match.mentee : match.mentor)
  const active = match.status === 'active'
  return (
    <article
      className="connection-card"
      data-tour={match.mentee === 'ava' ? 'my-request' : undefined}
    >
      <div className="connection-card-heading">
        <Avatar person={other} named={active} />
        <div>
          <h3>{visibleName(state, person.id, other)}</h3>
          <p>
            Year {other.year} · {other.subject}
          </p>
        </div>
        <Badge tone={active ? 'green' : match.status === 'pending' ? 'amber' : 'neutral'}>
          {labels[match.status]}
        </Badge>
      </div>
      <div className="introduction">
        <span>{person.role === 'mentor' ? 'THEIR INTRODUCTION' : 'YOUR INTRODUCTION'}</span>
        <p>“{match.message}”</p>
      </div>
      <div className="tags">
        {other.interests.map((i) => (
          <span key={i}>{i}</span>
        ))}
      </div>
      <div className="connection-actions">
        {match.status === 'pending' && person.role === 'mentor' ? (
          <>
            <button
              className="button primary"
              disabled={!isAvailable(state, person) || !isAvailable(state, other)}
              onClick={() =>
                act(
                  { type: 'decide', actor: person.id, match: match.id, accept: true },
                  'Request accepted. The connection is now active.',
                )
              }
            >
              <Check size={16} />
              Accept request
            </button>
            <button
              className="button secondary"
              onClick={() =>
                act(
                  { type: 'decide', actor: person.id, match: match.id, accept: false },
                  'Request declined. The mentee has been notified.',
                )
              }
            >
              Decline
            </button>
          </>
        ) : active ? (
          <>
            <button className="button primary" onClick={() => setProfile(true)}>
              View full profile
              <ArrowRight size={16} />
            </button>
            <button className="button ghost" onClick={() => navigate('support')}>
              Contact support
            </button>
          </>
        ) : (
          <span className="muted">
            <Clock3 size={15} />
            {match.status === 'pending'
              ? 'The response will appear in your inbox.'
              : 'Full profiles are available only for active connections.'}
          </span>
        )}
      </div>
      {profile && <ConnectedProfile person={other} onClose={() => setProfile(false)} />}
    </article>
  )
}

function ConnectedProfile({ person, onClose }: { person: Person; onClose: () => void }) {
  return (
    <Modal title="Your connection" onClose={onClose}>
      <div className="profile-intro">
        <Avatar person={person} size="large" named />
        <div>
          <h3>{person.name}</h3>
          <p>
            Year {person.year} · {person.subject}
          </p>
        </div>
      </div>
      <p className="modal-copy">{person.bio}</p>
      <div className="tags">
        {person.interests.map((t) => (
          <span key={t}>{t}</span>
        ))}
      </div>
      <div className="profile-facts">
        <span>
          <Globe2 size={16} />
          {person.languages.join(', ')}
        </span>
        <span>
          <Mail size={16} />
          {person.id}@example.org
        </span>
        <span>
          <HeartHandshake size={16} />
          Your mentoring connection is active
        </span>
      </div>
      <div className="privacy-note">
        <LockKeyhole size={17} />
        <p>
          This fictional contact is visible because you’re matched. No email is sent from this demo.
        </p>
      </div>
    </Modal>
  )
}

export function Connections() {
  const { state, person, role, act, navigate } = useDemo()
  const [tab, setTab] = useState('All connections')
  const [capacityOpen, setCapacityOpen] = useState(false)
  const [capacity, setCapacity] = useState(person.capacity)
  const matches = state.matches.filter((m) => m.mentee === person.id || m.mentor === person.id)
  const filtered = matches.filter(
    (m) =>
      tab === 'All connections' ||
      (tab === 'Active'
        ? m.status === 'active'
        : tab === 'Pending'
          ? m.status === 'pending'
          : !['active', 'pending'].includes(m.status)),
  )
  const waitlist = state.people.filter(
    (p) => p.role === 'mentee' && p.waitingDays >= 7 && isAvailable(state, p),
  )
  return (
    <>
      <PageHeading
        title="My connections"
        description={
          role === 'mentor'
            ? 'Review requests, manage active connections, and offer places to waitlisted students.'
            : 'Check request statuses and view your mentor’s profile after acceptance.'
        }
        action={
          role === 'mentee' ? (
            <button className="button secondary" onClick={() => navigate('discover')}>
              Find a mentor
              <ArrowRight size={16} />
            </button>
          ) : (
            <button
              className="button secondary"
              onClick={() => {
                setCapacity(Math.min(person.capacity, state.maxCapacity))
                setCapacityOpen(true)
              }}
            >
              <Users size={16} />
              Set availability
            </button>
          )
        }
      />
      {role === 'mentor' && (
        <div className="availability-strip" data-tour="capacity">
          <HeartHandshake size={20} />
          <p>
            Active mentees: <strong>{activeMatches(state, person.id).length}</strong> of{' '}
            <strong>{Math.min(person.capacity, state.maxCapacity)}</strong> places.
            <span>
              {freePlaces(state, person)} place{freePlaces(state, person) === 1 ? '' : 's'}{' '}
              available.
            </span>
          </p>
          <Badge tone={freePlaces(state, person) ? 'green' : 'neutral'}>
            {freePlaces(state, person) ? 'Places available' : 'At capacity'}
          </Badge>
        </div>
      )}
      <div className="filter-tabs" aria-label="Filter connections">
        {['All connections', 'Active', 'Pending', 'Past'].map((t) => (
          <button
            key={t}
            aria-pressed={tab === t}
            className={tab === t ? 'selected' : ''}
            onClick={() => setTab(t)}
          >
            {t}
          </button>
        ))}
      </div>
      {filtered.length ? (
        <div className="connection-grid">
          {filtered.map((m) => (
            <Connection key={m.id} match={m} />
          ))}
        </div>
      ) : (
        <EmptyState
          title={
            tab === 'All connections' ? 'No connections yet' : `No ${tab.toLowerCase()} connections`
          }
          action={
            role === 'mentee' && (
              <button className="button primary" onClick={() => navigate('discover')}>
                Find a mentor
                <ArrowRight size={16} />
              </button>
            )
          }
        >
          {tab === 'All connections'
            ? role === 'mentee'
              ? 'Browse available mentors and send a request with a short introduction.'
              : 'Requests from mentees will appear here. You can also offer a place from the waitlist.'
            : 'No connections match this filter.'}
        </EmptyState>
      )}
      {role === 'mentor' && (
        <section className="waitlist-section">
          <div className="section-heading">
            <div>
              <h2>Mentee waitlist</h2>
            </div>
            <Badge>{waitlist.length} on the waitlist</Badge>
          </div>
          <p className="muted">
            Students waiting seven days or more can be connected directly by an available mentor.
          </p>
          {waitlist.map((p) => (
            <article className="waitlist-card" key={p.id}>
              <Avatar person={p} />
              <div>
                <h3>{p.alias}</h3>
                <p>
                  {p.subject} · Waiting {p.waitingDays} days
                </p>
                <p>{p.bio}</p>
              </div>
              <button
                className="button secondary"
                disabled={!isAvailable(state, person)}
                onClick={() =>
                  act(
                    { type: 'waitlist', actor: person.id, mentee: p.id },
                    'Waitlisted student added to your active connections.',
                  )
                }
              >
                Offer a place
                <ArrowRight size={16} />
              </button>
            </article>
          ))}
          {!waitlist.length && (
            <p className="notice-panel">No students are currently eligible for the waitlist.</p>
          )}
        </section>
      )}
      {capacityOpen && (
        <Modal title="Set availability" onClose={() => setCapacityOpen(false)}>
          <p className="modal-copy">
            Set the maximum number of mentees you can accept, up to {state.maxCapacity}. The limit
            cannot be lower than your current number of active connections.
          </p>
          <form
            onSubmit={(e) => {
              e.preventDefault()
              if (
                act(
                  { type: 'capacity', actor: person.id, capacity },
                  'Your availability has been updated.',
                )
              )
                setCapacityOpen(false)
            }}
          >
            <Field label="Number of mentees">
              <select value={capacity} onChange={(e) => setCapacity(Number(e.target.value))}>
                {Array.from({ length: state.maxCapacity }, (_, i) => i + 1).map((n) => (
                  <option key={n} value={n} disabled={n < activeMatches(state, person.id).length}>
                    {n} mentee{n === 1 ? '' : 's'}
                  </option>
                ))}
              </select>
            </Field>
            <button className="button primary">
              Save availability
              <Check size={16} />
            </button>
          </form>
        </Modal>
      )}
    </>
  )
}
