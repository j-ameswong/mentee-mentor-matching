import {
  ArrowRight,
  BookOpen,
  Check,
  Clock3,
  HeartHandshake,
  Play,
  ShieldCheck,
  Sparkles,
  Users,
} from 'lucide-react'
import { useDemo } from '../demo/context'
import { activeMatches, isAvailable } from '../demo/model'
import { Badge, ConnectionArt, Stat, TextLink } from '../components/ui'
import { MentorCard } from './Discover'

export function Overview() {
  const { state, person, role, navigate, startTour } = useDemo()
  const matches = activeMatches(state, person.id)
  const pending = state.matches.filter(
    (m) => m.status === 'pending' && (m.mentee === person.id || m.mentor === person.id),
  )
  const mentors = state.people
    .filter((p) => p.role === 'mentor' && isAvailable(state, p))
    .sort(
      (a, b) =>
        b.interests.filter((t) => person.interests.includes(t)).length -
        a.interests.filter((t) => person.interests.includes(t)).length,
    )
  return (
    <>
      <div className="welcome-line">
        <span>
          <span className="hello-dot" />
          MENTORING OVERVIEW
        </span>
        <span>{state.semesterEnded ? 'Semester completed' : 'Semester in progress'}</span>
      </div>
      <section className="hero" data-tour="welcome">
        <div className="hero-copy">
          <Badge tone="hero-badge">
            <Sparkles size={13} />
            {person.name} ·{' '}
            {role === 'admin' ? 'Administrator' : role === 'mentor' ? 'Mentor' : 'Mentee'}
          </Badge>
          <h1 tabIndex={-1}>
            {role === 'mentee' ? (
              <>
                Find a mentor.
                <br />
                <em>Manage your requests.</em>
              </>
            ) : role === 'mentor' ? (
              <>
                Review requests.
                <br />
                <em>Manage your mentees.</em>
              </>
            ) : (
              <>
                Manage accounts.
                <br />
                <em>Review support requests.</em>
              </>
            )}
          </h1>
          <p>
            {role === 'mentee'
              ? 'Browse available mentors by subject and shared interests. Send a request with a short introduction.'
              : role === 'mentor'
                ? 'Accept or decline mentoring requests, view your active connections, and set your availability.'
                : 'Approve new members, review reports and withdrawal requests, and manage mentor capacity.'}
          </p>
          <div className="hero-actions">
            <button
              className="button primary"
              onClick={() =>
                navigate(
                  role === 'mentee' ? 'discover' : role === 'mentor' ? 'matches' : 'approvals',
                )
              }
            >
              {role === 'mentee'
                ? 'Find a mentor'
                : role === 'mentor'
                  ? 'View requests'
                  : 'Review account approvals'}
              <ArrowRight size={17} />
            </button>
            <button className="button ghost" onClick={startTour}>
              <Play size={15} />
              Start guided tour
            </button>
          </div>
          <div className="hero-footnote">
            <span className="mini-avatars">
              <i>A</i>
              <i>M</i>
              <i>R</i>
            </span>
            <span>Demo roles: mentee, mentor and administrator</span>
          </div>
        </div>
        <ConnectionArt />
      </section>
      <div className="stats-grid">
        {role === 'admin' ? (
          <>
            <Stat
              icon={Users}
              label="Approved accounts"
              value={state.people.filter((p) => p.approved).length}
              note="Mentees, mentors and administrators"
            />
            <Stat
              icon={Clock3}
              label="Awaiting approval"
              value={state.people.filter((p) => !p.approved).length}
              note="New accounts requiring review"
            />
            <Stat
              icon={HeartHandshake}
              label="Active connections"
              value={state.matches.filter((m) => m.status === 'active').length}
              note="Accepted mentoring requests"
            />
          </>
        ) : (
          <>
            <Stat
              icon={HeartHandshake}
              label={role === 'mentee' ? 'Available mentors' : 'Active connections'}
              value={role === 'mentee' ? mentors.length : matches.length}
              note={role === 'mentee' ? 'With places available' : 'Your current mentees'}
            />
            <Stat
              icon={Clock3}
              label="Pending requests"
              value={pending.length}
              note={role === 'mentee' ? 'Awaiting a mentor’s response' : 'Awaiting your response'}
            />
            <Stat
              icon={Check}
              label={role === 'mentee' ? 'Profile status' : 'Available places'}
              value={
                role === 'mentee'
                  ? 'Complete'
                  : Math.max(0, Math.min(person.capacity, state.maxCapacity) - matches.length)
              }
              note={
                role === 'mentee'
                  ? 'Introduction, interests and languages'
                  : 'Based on your current capacity'
              }
            />
          </>
        )}
      </div>
      {role === 'mentee' ? (
        <section>
          <div className="section-heading">
            <div>
              <p className="eyebrow">SHARED INTERESTS FIRST</p>
              <h2>Suggested mentors</h2>
            </div>
            <TextLink onClick={() => navigate('discover')}>View all mentors</TextLink>
          </div>
          {mentors.length ? (
            <div className="mentor-grid">
              {mentors.slice(0, 3).map((m) => (
                <MentorCard key={m.id} mentor={m} />
              ))}
            </div>
          ) : (
            <div className="notice-panel">
              No mentors are available. View existing connections or reset the demo to restore the
              starting data.
            </div>
          )}
        </section>
      ) : (
        <section className="next-step-panel">
          <span className="next-icon">
            <BookOpen size={28} />
          </span>
          <div>
            <h2>{role === 'mentor' ? 'Requests and waitlist' : 'Account approvals'}</h2>
            <p>
              {role === 'mentor'
                ? 'Review pending requests or offer a place to a student who has been waiting at least seven days.'
                : 'Review new mentor and mentee accounts. Approved members can send or accept mentoring requests.'}
            </p>
          </div>
          <button
            className="button secondary"
            onClick={() => navigate(role === 'mentor' ? 'matches' : 'approvals')}
          >
            {role === 'mentor' ? 'View requests' : 'Review accounts'}
            <ArrowRight size={16} />
          </button>
        </section>
      )}
      <section className="bottom-panels">
        <div className="how-it-works">
          <h2>How matching works</h2>
          <div className="steps-row">
            {[
              ['01', 'Browse mentors', 'Filter by subject or shared interests.'],
              ['02', 'Send a request', 'Describe what you want help with.'],
              ['03', 'View contact details', 'Full profiles appear when a mentor accepts.'],
            ].map(([n, title, text]) => (
              <div key={n}>
                <span>{n}</span>
                <h3>{title}</h3>
                <p>{text}</p>
              </div>
            ))}
          </div>
        </div>
        <div className="care-card">
          <ShieldCheck size={27} strokeWidth={1.4} />
          <h3>Support requests</h3>
          <p>
            Report an account or request to end a connection. Administrators review each request.
          </p>
          <TextLink onClick={() => navigate('support')}>Visit the support desk</TextLink>
        </div>
      </section>
    </>
  )
}
