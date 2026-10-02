import { describe, expect, it } from 'vitest'
import {
  activeMatches,
  freePlaces,
  initialState,
  isAvailable,
  MAX_ACTIONS,
  personById,
  restore,
  transition,
  visibleName,
  type Action,
  type DemoState,
} from '../src/demo/model'

function apply(state: DemoState, action: Action) {
  const result = transition(state, action)
  expect(result.error).toBeUndefined()
  return result.state
}
const introduction: Action = {
  type: 'apply',
  actor: 'ava',
  mentor: 'maya',
  message: 'I would love help with coding projects.',
}
const acceptAva = (state: DemoState) =>
  apply(state, {
    type: 'decide',
    actor: 'maya',
    match: state.matches.find(
      (m) => m.mentee === 'ava' && m.mentor === 'maya' && m.status === 'pending',
    )!.id,
    accept: true,
  })

describe('matching lifecycle', () => {
  it('keeps introductions private until acceptance and closes competing requests', () => {
    const fresh = initialState()
    expect(visibleName(fresh, 'ava', personById(fresh, 'maya'))).toBe('campus.coder')
    let state = apply(fresh, introduction)
    state = apply(state, { ...introduction, mentor: 'finley' })
    state = acceptAva(state)
    expect(activeMatches(state, 'ava')).toHaveLength(1)
    expect(state.matches.find((m) => m.mentor === 'finley')).toMatchObject({ status: 'cancelled' })
    expect(visibleName(state, 'ava', personById(state, 'maya'))).toBe('Maya Chen')
    expect(freePlaces(state, personById(state, 'maya'))).toBe(1)
    expect(
      state.notices.some((n) => n.recipient === 'ava' && n.title === 'Mentoring request accepted'),
    ).toBe(true)
    expect(fresh.matches).toHaveLength(2)
  })
  it('rejects duplicate and empty applications without mutating data', () => {
    const state = apply(initialState(), introduction)
    expect(transition(state, introduction)).toEqual({
      state,
      error: 'You’ve already sent this mentor a request.',
    })
    expect(transition(initialState(), { ...introduction, message: ' ' }).error).toBeTruthy()
    expect(
      transition(initialState(), { ...introduction, message: 'hello '.repeat(101) }).error,
    ).toContain('100 words')
  })
  it('enforces mentor capacity at acceptance, including pending requests', () => {
    let state = apply(initialState(), introduction)
    state = apply(state, { type: 'capacity', actor: 'maya', capacity: 1 })
    const result = transition(state, {
      type: 'decide',
      actor: 'maya',
      match: state.matches[0].id,
      accept: true,
    })
    expect(result.error).toContain('no longer available')
    expect(activeMatches(result.state, 'maya')).toHaveLength(1)
  })
  it('does not let another mentor decide a request or an active mentee reapply', () => {
    let state = apply(initialState(), introduction)
    expect(
      transition(state, {
        type: 'decide',
        actor: 'finley',
        match: state.matches[0].id,
        accept: true,
      }).error,
    ).toBeTruthy()
    state = acceptAva(state)
    expect(transition(state, { ...introduction, mentor: 'finley' }).error).toBeTruthy()
  })
  it('allows another introduction after a decline and notifies the mentee', () => {
    let state = apply(initialState(), introduction)
    state = apply(state, {
      type: 'decide',
      actor: 'maya',
      match: state.matches[0].id,
      accept: false,
    })
    expect(state.notices.some((n) => n.recipient === 'ava' && n.title === 'Request declined')).toBe(
      true,
    )
    state = apply(state, introduction)
    expect(state.matches.filter((m) => m.mentee === 'ava' && m.status === 'pending')).toHaveLength(
      1,
    )
  })
  it('only connects eligible waitlisted students and prevents double matching', () => {
    const state = apply(initialState(), { type: 'waitlist', actor: 'maya', mentee: 'theo' })
    expect(activeMatches(state, 'theo')).toHaveLength(1)
    expect(personById(state, 'theo').waitingDays).toBe(0)
    expect(
      transition(state, { type: 'waitlist', actor: 'maya', mentee: 'theo' }).error,
    ).toBeTruthy()
    expect(transition(state, { type: 'waitlist', actor: 'maya', mentee: 'ava' }).error).toBeTruthy()
  })
  it('rejects invalid targets and role combinations', () => {
    for (const action of [
      { ...introduction, actor: 'robin' },
      { ...introduction, mentor: 'missing' },
      { ...introduction, mentor: 'ava' },
      { ...introduction, actor: 'lily' },
    ])
      expect(transition(initialState(), action).error).toBeTruthy()
  })
})

describe('support, administration and privacy', () => {
  it('withdraws only after admin review and releases both people', () => {
    let state = acceptAva(apply(initialState(), introduction))
    const ticket: Action = {
      type: 'ticket',
      actor: 'ava',
      target: 'maya',
      kind: 'withdrawal',
      detail: 'I would like a different connection.',
    }
    state = apply(state, ticket)
    expect(activeMatches(state, 'ava')).toHaveLength(1)
    expect(transition(state, ticket).error).toContain('already have an open request')
    expect(
      transition(state, {
        type: 'resolve',
        actor: 'ava',
        ticket: state.tickets[0].id,
        decision: 'approve-withdrawal',
      }).error,
    ).toBeTruthy()
    state = apply(state, {
      type: 'resolve',
      actor: 'robin',
      ticket: state.tickets[0].id,
      decision: 'approve-withdrawal',
    })
    expect(activeMatches(state, 'ava')).toHaveLength(0)
    expect(freePlaces(state, personById(state, 'maya'))).toBe(2)
    expect(visibleName(state, 'ava', personById(state, 'maya'))).toBe('campus.coder')
    expect(state.tickets[0].outcome).toBe('Withdrawal approved')
  })
  it('does not accept bogus withdrawals or mismatched support decisions', () => {
    const invalidQuestion: Action = {
      type: 'ticket',
      actor: 'ava',
      target: 'missing',
      kind: 'question',
      detail: 'A general question',
    }
    expect(transition(initialState(), invalidQuestion).error).toBeTruthy()
    expect(restore(JSON.stringify({ version: 1, actions: [invalidQuestion] })).actions).toEqual([])
    expect(
      transition(initialState(), {
        type: 'ticket',
        actor: 'ava',
        target: 'maya',
        kind: 'withdrawal',
        detail: 'Goodbye',
      }).error,
    ).toBeTruthy()
    expect(
      transition(initialState(), {
        type: 'resolve',
        actor: 'robin',
        ticket: 'ticket-luca',
        decision: 'approve-withdrawal',
      }).error,
    ).toBeTruthy()
    expect(
      transition(initialState(), {
        type: 'resolve',
        actor: 'robin',
        ticket: 'missing',
        decision: 'resolve',
      }).error,
    ).toBeTruthy()
  })
  it('approves a mentor into discovery and blocks flagged accounts', () => {
    let state = initialState()
    expect(isAvailable(state, personById(state, 'samir'))).toBe(false)
    expect(transition(state, { type: 'approve', actor: 'ava', person: 'samir' }).error).toBeTruthy()
    state = apply(state, { type: 'approve', actor: 'robin', person: 'samir' })
    expect(isAvailable(state, personById(state, 'samir'))).toBe(true)
    state = apply(state, { type: 'flag', actor: 'robin', person: 'maya', flagged: true })
    expect(isAvailable(state, personById(state, 'maya'))).toBe(false)
    expect(transition(state, introduction).error).toBeTruthy()
    expect(transition(state, { type: 'capacity', actor: 'maya', capacity: 3 }).error).toBeTruthy()
    state = apply(state, { type: 'flag', actor: 'robin', person: 'maya', flagged: false })
    expect(isAvailable(state, personById(state, 'maya'))).toBe(true)
  })
  it('resolves reports by flagging and keeps existing matches visible for follow-up', () => {
    let state = apply(initialState(), {
      type: 'ticket',
      actor: 'ava',
      target: 'maya',
      kind: 'report',
      detail: 'A fictional concern for the demo.',
    })
    state = apply(state, {
      type: 'resolve',
      actor: 'robin',
      ticket: state.tickets[0].id,
      decision: 'flag',
    })
    expect(personById(state, 'maya').flagged).toBe(true)
    expect(activeMatches(state, 'maya')).toHaveLength(1)
  })
  it('cannot lower limits below current usage', () => {
    const state = acceptAva(apply(initialState(), introduction))
    expect(transition(state, { type: 'capacity', actor: 'maya', capacity: 1 }).error).toBeTruthy()
    expect(transition(state, { type: 'settings', actor: 'robin', capacity: 1 }).error).toBeTruthy()
    expect(transition(state, { type: 'settings', actor: 'ava', capacity: 3 }).error).toBeTruthy()
  })
  it('ends the semester, archives matches, and prevents new applications', () => {
    let state = apply(initialState(), introduction)
    state = apply(state, { type: 'end-semester', actor: 'robin' })
    expect(state.matches.some((m) => ['active', 'pending'].includes(m.status))).toBe(false)
    expect(state.matches.find((m) => m.id === 'match-luca')?.status).toBe('completed')
    expect(transition(state, introduction).error).toBeTruthy()
    expect(
      transition(state, { type: 'waitlist', actor: 'maya', mentee: 'theo' }).error,
    ).toBeTruthy()
    expect(transition(state, { type: 'end-semester', actor: 'robin' }).error).toBeTruthy()
  })
  it('marks only the current persona’s notifications read', () => {
    let state = apply(initialState(), { type: 'read', actor: 'ava', notice: 'request-zoe' })
    expect(state.notices.find((n) => n.id === 'request-zoe')?.read).toBe(false)
    state = apply(state, { type: 'read', actor: 'ava', notice: 'all' })
    expect(state.notices.find((n) => n.id === 'welcome-ava')?.read).toBe(true)
    expect(state.notices.find((n) => n.id === 'welcome-admin')?.read).toBe(false)
  })
})

describe('bounded browser persistence', () => {
  it('replays valid changes and validates the rules again', () => {
    expect(restore(JSON.stringify({ version: 1, actions: [introduction] })).state).toEqual(
      transition(initialState(), introduction).state,
    )
    expect(
      restore(JSON.stringify({ version: 1, actions: [introduction, introduction] })).actions,
    ).toEqual([])
  })
  it.each([
    null,
    '',
    'broken json',
    '{}',
    '{"version":2,"actions":[]}',
    '{"version":1,"actions":[{"type":"unknown"}]}',
    'a'.repeat(200_001),
    JSON.stringify({ version: 1, actions: Array(MAX_ACTIONS + 1).fill(introduction) }),
  ])('recovers safely from malformed or oversized storage', (raw) => {
    expect(restore(raw)).toEqual({ state: initialState(), actions: [] })
  })
  it('rejects invalid profile attributes and keeps raw text inert', () => {
    const state = initialState()
    expect(
      transition(state, {
        type: 'profile',
        actor: 'ava',
        bio: 'New bio',
        interests: ['Unknown'],
        languages: ['English'],
      }).error,
    ).toBeTruthy()
    const result = transition(state, {
      type: 'profile',
      actor: 'ava',
      bio: '<img src=x onerror=alert(1)>',
      interests: ['Coding'],
      languages: ['English'],
    })
    expect(personById(result.state, 'ava').bio).toBe('<img src=x onerror=alert(1)>')
  })
})
