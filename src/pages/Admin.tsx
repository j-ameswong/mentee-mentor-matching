import { useState } from 'react'
import { Check, Search, ShieldCheck } from 'lucide-react'
import { useDemo } from '../demo/context'
import { activeMatches } from '../demo/model'
import { Avatar, Badge, EmptyState, Field, Modal, PageHeading } from '../components/ui'

export function Approvals() {
  const { state, person, act } = useDemo()
  const [filter, setFilter] = useState('All members')
  const pending = state.people.filter(
    (p) => !p.approved && (filter === 'All members' || p.role === filter.toLowerCase()),
  )
  return (
    <>
      <PageHeading
        title="Account approvals"
        description="Review new mentor and mentee accounts before they can use matching."
      />
      <div className="filter-tabs">
        {['All members', 'Mentee', 'Mentor'].map((f) => (
          <button
            key={f}
            className={f === filter ? 'selected' : ''}
            aria-pressed={f === filter}
            onClick={() => setFilter(f)}
          >
            {f}
          </button>
        ))}
      </div>
      <div className="approval-list" data-tour="approvals">
        {pending.map((p) => (
          <article className="approval-card" key={p.id}>
            <Avatar person={p} size="large" named />
            <div className="approval-details">
              <Badge tone="amber">Awaiting approval</Badge>
              <h3>{p.name}</h3>
              <p>
                Year {p.year} · {p.subject} · {p.role}
              </p>
              <p className="approval-bio">{p.bio}</p>
              <div className="tags">
                {p.interests.map((t) => (
                  <span key={t}>{t}</span>
                ))}
              </div>
            </div>
            <button
              className="button primary"
              onClick={() =>
                act(
                  { type: 'approve', actor: person.id, person: p.id },
                  `Account approved for ${p.name}.`,
                )
              }
            >
              <Check size={16} />
              Approve {p.name.split(' ')[0]}
            </button>
          </article>
        ))}
        {!pending.length && (
          <EmptyState title="No accounts awaiting approval">
            No new {filter === 'All members' ? 'members' : `${filter.toLowerCase()}s`} are waiting
            for approval.
          </EmptyState>
        )}
      </div>
      <div className="quiet-note">
        <ShieldCheck size={16} />
        Approved mentors appear in the mentee view when they have places available.
      </div>
    </>
  )
}

export function Community() {
  const { state, person, act } = useDemo()
  const [search, setSearch] = useState('')
  const [capacity, setCapacity] = useState(state.maxCapacity)
  const [endOpen, setEndOpen] = useState(false)
  const people = state.people.filter((p) =>
    `${p.name} ${p.alias} ${p.subject}`.toLowerCase().includes(search.toLowerCase()),
  )
  return (
    <>
      <PageHeading
        title="Accounts and settings"
        description="Review account status, set the mentor capacity limit, and complete the semester."
      />
      <div className="community-settings">
        <form
          className="panel"
          onSubmit={(e) => {
            e.preventDefault()
            act({ type: 'settings', actor: person.id, capacity }, 'Mentor capacity limit updated.')
          }}
        >
          <h2>Mentor capacity limit</h2>
          <p>Set the maximum number of mentees any one mentor can support.</p>
          <div className="inline-form">
            <Field label="Maximum mentees per mentor">
              <select value={capacity} onChange={(e) => setCapacity(Number(e.target.value))}>
                {[1, 2, 3, 4].map((n) => (
                  <option key={n} value={n}>
                    {n} mentee{n === 1 ? '' : 's'} per mentor
                  </option>
                ))}
              </select>
            </Field>
            <button className="button secondary">Save limit</button>
          </div>
        </form>
        <div className="panel semester-panel">
          <Badge tone={state.semesterEnded ? 'neutral' : 'green'}>
            {state.semesterEnded ? 'Semester completed' : 'Semester in progress'}
          </Badge>
          <h2>Semester management</h2>
          <p>
            Completing the semester archives active matches, closes pending requests, and notifies
            everyone involved.
          </p>
          <button
            className="button secondary"
            disabled={state.semesterEnded}
            onClick={() => setEndOpen(true)}
          >
            Complete demo semester
          </button>
        </div>
      </div>
      <div className="section-heading">
        <h2>Member accounts</h2>
        <span className="muted">{people.length} fictional members</span>
      </div>
      <label className="search-box community-search">
        <Search size={18} />
        <span className="sr-only">Search community members</span>
        <input
          value={search}
          maxLength={100}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Search members…"
        />
      </label>
      <div className="table-wrap">
        <table>
          <caption className="sr-only">Community members and account status</caption>
          <thead>
            <tr>
              <th>Member</th>
              <th>Role</th>
              <th>Connections</th>
              <th>Status</th>
              <th>
                <span className="sr-only">Action</span>
              </th>
            </tr>
          </thead>
          <tbody>
            {people.map((p) => (
              <tr key={p.id}>
                <td>
                  <div className="table-person">
                    <Avatar person={p} size="small" named />
                    <span>
                      <strong>{p.name}</strong>
                      <small>{p.subject}</small>
                    </span>
                  </div>
                </td>
                <td className="capitalize">{p.role}</td>
                <td>{activeMatches(state, p.id).length}</td>
                <td>
                  <Badge tone={p.flagged ? 'rose' : p.approved ? 'green' : 'amber'}>
                    {p.flagged ? 'Flagged' : p.approved ? 'Approved' : 'Pending'}
                  </Badge>
                </td>
                <td>
                  {p.role !== 'admin' && (
                    <button
                      className="text-button"
                      onClick={() =>
                        act(
                          { type: 'flag', actor: person.id, person: p.id, flagged: !p.flagged },
                          p.flagged
                            ? 'Account flag cleared.'
                            : 'New activity paused for this account.',
                        )
                      }
                    >
                      {p.flagged ? 'Clear flag' : 'Flag for review'}
                    </button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {!people.length && (
          <EmptyState title="No members found">Try another name or subject.</EmptyState>
        )}
      </div>
      <p className="quiet-note">
        Flagged accounts pause new activity and disappear from discovery. Existing connections stay
        visible so the support team can follow up.
      </p>
      {endOpen && (
        <Modal title="Complete the semester?" onClose={() => setEndOpen(false)}>
          <p className="modal-copy">
            This completes every active connection and cancels pending introductions in your demo.
            Matching will pause until you reset the demo.
          </p>
          <div className="form-footer">
            <button className="button secondary" onClick={() => setEndOpen(false)}>
              Cancel
            </button>
            <button
              className="button primary"
              onClick={() => {
                if (
                  act(
                    { type: 'end-semester', actor: person.id },
                    'Semester complete. Every connection has been archived.',
                  )
                )
                  setEndOpen(false)
              }}
            >
              Complete semester
              <Check size={16} />
            </button>
          </div>
        </Modal>
      )}
    </>
  )
}
