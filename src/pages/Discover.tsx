import { useState } from 'react'
import {
  ArrowRight,
  Check,
  Globe2,
  GraduationCap,
  LockKeyhole,
  Search,
  SlidersHorizontal,
  Sparkles,
  Users,
} from 'lucide-react'
import { useDemo } from '../demo/context'
import {
  activeMatches,
  freePlaces,
  isAvailable,
  topics,
  visibleName,
  wordCount,
  type Person,
} from '../demo/model'
import { Avatar, Badge, EmptyState, Field, Modal, PageHeading } from '../components/ui'

export function MentorCard({ mentor, featured = false }: { mentor: Person; featured?: boolean }) {
  const { state, person } = useDemo()
  const [open, setOpen] = useState(false)
  const pending = state.matches.some(
    (m) => m.mentor === mentor.id && m.mentee === person.id && m.status === 'pending',
  )
  const active = activeMatches(state, person.id).some((m) => m.mentor === mentor.id)
  const shared = mentor.interests.filter((t) => person.interests.includes(t))
  return (
    <>
      <article className="mentor-card" data-tour={featured ? 'mentor-card' : undefined}>
        <div className="mentor-card-top">
          <Avatar person={mentor} size="large" named={active} />
          <Badge tone={freePlaces(state, mentor) ? 'green' : 'neutral'}>
            <span className="status-dot" />
            {freePlaces(state, mentor) ? 'Available' : 'At capacity'}
          </Badge>
        </div>
        <h3>{visibleName(state, person.id, mentor)}</h3>
        <p className="mentor-course">
          Year {mentor.year}
          <span>·</span>
          {mentor.subject}
        </p>
        <p className="mentor-bio">{mentor.bio}</p>
        <div className="tags">
          {mentor.interests.slice(0, 3).map((t) => (
            <span key={t}>{t}</span>
          ))}
        </div>
        <div className="mentor-card-footer">
          <span>
            <Sparkles size={14} />
            {shared.length} shared interest{shared.length === 1 ? '' : 's'}
          </span>
          <button
            className="round-button"
            aria-label={`View ${mentor.alias}'s profile`}
            onClick={() => setOpen(true)}
          >
            <ArrowRight size={18} />
          </button>
        </div>
        {pending && (
          <div className="card-note">
            <Check size={14} />
            Request sent · awaiting a reply
          </div>
        )}
      </article>
      {open && <MentorProfile mentor={mentor} onClose={() => setOpen(false)} />}
    </>
  )
}

function MentorProfile({ mentor, onClose }: { mentor: Person; onClose: () => void }) {
  const { state, person, act, navigate } = useDemo()
  const [message, setMessage] = useState('')
  const pending = state.matches.some(
    (m) => m.mentor === mentor.id && m.mentee === person.id && m.status === 'pending',
  )
  const active = activeMatches(state, person.id).length > 0
  const available =
    person.role === 'mentee' &&
    isAvailable(state, person) &&
    isAvailable(state, mentor) &&
    !pending &&
    !active
  return (
    <Modal title="Mentor profile" onClose={onClose}>
      <div className="profile-intro">
        <Avatar person={mentor} size="large" />
        <div>
          <h3>{visibleName(state, person.id, mentor)}</h3>
          <p>
            Year {mentor.year} · {mentor.subject}
          </p>
        </div>
      </div>
      <p className="modal-copy">{mentor.bio}</p>
      <div className="tags">
        {mentor.interests.map((t) => (
          <span key={t}>{t}</span>
        ))}
      </div>
      <div className="profile-facts">
        <span>
          <Globe2 size={16} />
          {mentor.languages.join(', ')}
        </span>
        <span>
          <Users size={16} />
          {freePlaces(state, mentor)} available place{freePlaces(state, mentor) === 1 ? '' : 's'}
        </span>
        <span>
          <GraduationCap size={16} />
          Year {mentor.year} student
        </span>
      </div>
      <div className="privacy-note">
        <LockKeyhole size={17} />
        <p>Full names and contact details are shown in the demo after a request is accepted.</p>
      </div>
      {available ? (
        <form
          onSubmit={(e) => {
            e.preventDefault()
            if (
              act({ type: 'apply', actor: person.id, mentor: mentor.id, message }, 'Request sent.')
            )
              onClose()
          }}
        >
          <Field
            label="Introduction"
            hint="Describe what you want help with. Use fictional details. Maximum 100 words."
          >
            <textarea
              required
              autoFocus
              rows={4}
              maxLength={1000}
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              placeholder="For example: I’m looking for help planning my first coding project."
            />
          </Field>
          <div className="form-footer">
            <span className={wordCount(message) > 100 ? 'error-text' : 'muted'}>
              {wordCount(message)} / 100 words
            </span>
            <button
              className="button primary"
              disabled={!message.trim() || wordCount(message) > 100}
            >
              Send request
              <ArrowRight size={16} />
            </button>
          </div>
        </form>
      ) : (
        <div className="notice-panel">
          <p>
            {pending
              ? 'Your request is pending. Check its status in My connections.'
              : active
                ? 'You already have a mentor. View their profile in My connections.'
                : state.semesterEnded
                  ? 'The semester has ended. Reset the demo to send new requests.'
                  : 'This mentor is currently unavailable.'}
          </p>
          <button
            className="button secondary"
            onClick={() => {
              onClose()
              navigate('matches')
            }}
          >
            View my connections
            <ArrowRight size={16} />
          </button>
        </div>
      )}
    </Modal>
  )
}

export function Discover() {
  const { state, person } = useDemo()
  const [search, setSearch] = useState('')
  const [topic, setTopic] = useState('All interests')
  const [subject, setSubject] = useState('All subjects')
  const mentors = state.people
    .filter((p) => p.role === 'mentor' && isAvailable(state, p))
    .filter((p) => topic === 'All interests' || p.interests.includes(topic))
    .filter((p) => subject === 'All subjects' || p.subject === subject)
    .filter((p) =>
      `${p.alias} ${p.subject} ${p.bio} ${p.interests.join(' ')} ${p.languages.join(' ')}`
        .toLowerCase()
        .includes(search.toLowerCase()),
    )
    .sort(
      (a, b) =>
        b.interests.filter((t) => person.interests.includes(t)).length -
        a.interests.filter((t) => person.interests.includes(t)).length,
    )
  return (
    <>
      <PageHeading
        title="Find a mentor"
        description="Browse mentors with available places. Results are sorted by shared interests."
      />
      <div className="search-row" data-tour="filters">
        <label className="search-box">
          <Search size={18} />
          <span className="sr-only">Search mentors</span>
          <input
            placeholder="Search a subject, interest, or language…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            maxLength={100}
          />
        </label>
        <label className="select-box">
          <SlidersHorizontal size={16} />
          <span className="sr-only">Filter by subject</span>
          <select value={subject} onChange={(e) => setSubject(e.target.value)}>
            <option>All subjects</option>
            {[
              ...new Set(state.people.filter((p) => p.role === 'mentor').map((p) => p.subject)),
            ].map((s) => (
              <option key={s}>{s}</option>
            ))}
          </select>
        </label>
      </div>
      <div className="filter-tabs" aria-label="Filter by interest">
        {['All interests', ...topics].map((t) => (
          <button
            key={t}
            className={topic === t ? 'selected' : ''}
            aria-pressed={topic === t}
            onClick={() => setTopic(t)}
          >
            {t}
          </button>
        ))}
      </div>
      <div className="results-meta">
        <p>
          <strong>{mentors.length}</strong> mentor{mentors.length === 1 ? '' : 's'} found
        </p>
        <span>
          <Sparkles size={14} />
          Shared interests first
        </span>
      </div>
      {mentors.length ? (
        <div className="mentor-grid">
          {mentors.map((m, i) => (
            <MentorCard key={m.id} mentor={m} featured={i === 0} />
          ))}
        </div>
      ) : (
        <EmptyState
          title={state.semesterEnded ? 'Semester completed' : 'No mentors found'}
          action={
            !state.semesterEnded && (
              <button
                className="button secondary"
                onClick={() => {
                  setSearch('')
                  setTopic('All interests')
                  setSubject('All subjects')
                }}
              >
                Clear filters
              </button>
            )
          }
        >
          {state.semesterEnded
            ? 'Reset the demo to reopen matching.'
            : 'Change your search or clear the filters to see available mentors.'}
        </EmptyState>
      )}
      <div className="quiet-note">
        <LockKeyhole size={16} />
        <span>Full names are shown after a request is accepted.</span>
      </div>
    </>
  )
}
