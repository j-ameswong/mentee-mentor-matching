import { useState } from 'react'
import { Bell, Check, CheckCheck, HeartHandshake, LockKeyhole, Sprout } from 'lucide-react'
import { useDemo } from '../demo/context'
import { languageOptions, topics } from '../demo/model'
import { Avatar, Badge, EmptyState, Field, PageHeading } from '../components/ui'

export function Notifications() {
  const { state, person, act } = useDemo()
  const [unreadOnly, setUnreadOnly] = useState(false)
  const notices = state.notices.filter((n) => n.recipient === person.id && (!unreadOnly || !n.read))
  const unread = state.notices.filter((n) => n.recipient === person.id && !n.read).length
  return (
    <>
      <PageHeading
        title="Inbox"
        description="Notifications about mentoring requests, account changes and support decisions."
        action={
          <button
            className="button secondary"
            disabled={!unread}
            onClick={() =>
              act(
                { type: 'read', actor: person.id, notice: 'all' },
                'All notifications marked as read.',
              )
            }
          >
            <CheckCheck size={17} />
            Mark all as read
          </button>
        }
      />
      <div className="filter-tabs">
        <button
          className={!unreadOnly ? 'selected' : ''}
          aria-pressed={!unreadOnly}
          onClick={() => setUnreadOnly(false)}
        >
          All updates
        </button>
        <button
          className={unreadOnly ? 'selected' : ''}
          aria-pressed={unreadOnly}
          onClick={() => setUnreadOnly(true)}
        >
          Unread ({unread})
        </button>
      </div>
      <div className="inbox" data-tour="inbox">
        {notices.map((n) => (
          <article key={n.id} className={`notification ${n.read ? '' : 'unread'}`}>
            <span className="notice-icon">
              <HeartHandshake size={21} />
            </span>
            <div>
              <h3>
                {n.title}
                {!n.read && <span className="unread-dot" role="img" aria-label="Unread" />}
              </h3>
              <p>{n.detail}</p>
              <small>Demo notification</small>
            </div>
            {!n.read && (
              <button
                className="icon-button"
                aria-label={`Mark “${n.title}” as read`}
                onClick={() => act({ type: 'read', actor: person.id, notice: n.id })}
              >
                <Check size={19} />
              </button>
            )}
          </article>
        ))}
        {!notices.length && (
          <EmptyState title={unreadOnly ? 'No unread notifications' : 'No notifications'}>
            <Bell size={18} /> Updates to requests and accounts appear here.
          </EmptyState>
        )}
      </div>
      <p className="quiet-note">System notifications only. Direct messaging is not available.</p>
    </>
  )
}

export function Profile() {
  const { person, act } = useDemo()
  const [bio, setBio] = useState(person.bio)
  const [interests, setInterests] = useState(person.interests)
  const [languages, setLanguages] = useState(person.languages)
  const toggle = (values: string[], value: string) =>
    values.includes(value) ? values.filter((v) => v !== value) : [...values, value]
  return (
    <>
      <PageHeading
        title="My profile"
        description="Edit your introduction, interests and languages."
      />
      <div className="profile-layout">
        <aside className="profile-summary">
          <Avatar person={person} size="large" named />
          <h2>{person.name}</h2>
          <p>@{person.alias}</p>
          <Badge tone="green">
            {person.role === 'admin'
              ? 'Community administrator'
              : `${person.role === 'mentor' ? 'Mentor' : 'Mentee'} · Year ${person.year}`}
          </Badge>
          <p>{person.subject}</p>
          <div className="profile-summary-note">
            <Sprout size={24} />
            <p>Your introduction is visible before matching. Use fictional details in this demo.</p>
          </div>
        </aside>
        <form
          className="profile-form panel"
          onSubmit={(e) => {
            e.preventDefault()
            act({ type: 'profile', actor: person.id, bio, interests, languages }, 'Profile saved.')
          }}
        >
          <h2>Profile details</h2>
          <Field label="Introduction" hint={`${bio.length} / 500 characters`}>
            <textarea
              required
              rows={5}
              maxLength={500}
              value={bio}
              onChange={(e) => setBio(e.target.value)}
            />
          </Field>
          <fieldset>
            <legend>Interests</legend>
            <p className="field-hint">
              Select at least one. Shared interests determine the order of suggested mentors.
            </p>
            <div className="choice-chips">
              {topics.map((t) => (
                <button
                  type="button"
                  className={interests.includes(t) ? 'selected' : ''}
                  aria-pressed={interests.includes(t)}
                  key={t}
                  onClick={() => setInterests(toggle(interests, t))}
                >
                  {interests.includes(t) && <Check size={14} />}
                  {t}
                </button>
              ))}
            </div>
          </fieldset>
          <fieldset>
            <legend>Languages</legend>
            <p className="field-hint">Select at least one language you speak.</p>
            <div className="choice-chips">
              {languageOptions.map((l) => (
                <button
                  type="button"
                  className={languages.includes(l) ? 'selected' : ''}
                  aria-pressed={languages.includes(l)}
                  key={l}
                  onClick={() => setLanguages(toggle(languages, l))}
                >
                  {languages.includes(l) && <Check size={14} />}
                  {l}
                </button>
              ))}
            </div>
          </fieldset>
          <div className="privacy-note">
            <LockKeyhole size={17} />
            <p>In this demo, your full name is shown to active connections and administrators.</p>
          </div>
          <button
            className="button primary"
            disabled={!bio.trim() || !interests.length || !languages.length}
          >
            Save profile
            <Check size={16} />
          </button>
        </form>
      </div>
    </>
  )
}
