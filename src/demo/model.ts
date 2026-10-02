import { z } from 'zod'

// Object validation must not attempt runtime code generation under the production CSP.
z.config({ jitless: true })

export const roles = ['mentee', 'mentor', 'admin'] as const
export type Role = (typeof roles)[number]
export type Page =
  | 'overview'
  | 'discover'
  | 'matches'
  | 'notifications'
  | 'profile'
  | 'support'
  | 'approvals'
  | 'community'
  | 'about'
export type Status = 'pending' | 'active' | 'declined' | 'cancelled' | 'completed'

export interface Person {
  id: string
  name: string
  alias: string
  role: Role
  subject: string
  year: number
  bio: string
  interests: string[]
  languages: string[]
  colour: string
  approved: boolean
  flagged: boolean
  capacity: number
  waitingDays: number
}
export interface Match {
  id: string
  mentor: string
  mentee: string
  message: string
  status: Status
}
export interface Notice {
  id: string
  recipient: string
  title: string
  detail: string
  read: boolean
}
export interface Ticket {
  id: string
  author: string
  target: string
  type: 'question' | 'report' | 'withdrawal'
  detail: string
  resolved: boolean
  outcome?: string
}
export interface DemoState {
  people: Person[]
  matches: Match[]
  notices: Notice[]
  tickets: Ticket[]
  maxCapacity: number
  semesterEnded: boolean
}

export const personaIds: Record<Role, string> = { mentee: 'ava', mentor: 'maya', admin: 'robin' }
export const topics = [
  'Study skills',
  'Settling in',
  'Career planning',
  'Coding',
  'Wellbeing',
  'International life',
]
export const languageOptions = ['English', 'Mandarin', 'Spanish', 'French', 'Hindi']

const people: Person[] = [
  {
    id: 'ava',
    name: 'Ava Walker',
    alias: 'cs.student',
    role: 'mentee',
    subject: 'Computer science',
    year: 1,
    bio: 'First-year computer science student. Looking for help with coding projects and organising my study schedule.',
    interests: ['Coding', 'Settling in', 'Study skills'],
    languages: ['English'],
    colour: 'rose',
    approved: true,
    flagged: false,
    capacity: 0,
    waitingDays: 0,
  },
  {
    id: 'maya',
    name: 'Maya Chen',
    alias: 'campus.coder',
    role: 'mentor',
    subject: 'Computer science',
    year: 3,
    bio: 'I can help with programming assignments, revision and placement applications. I also run a weekly coding study group.',
    interests: ['Coding', 'Study skills', 'Settling in'],
    languages: ['English', 'Mandarin'],
    colour: 'sage',
    approved: true,
    flagged: false,
    capacity: 3,
    waitingDays: 0,
  },
  {
    id: 'finley',
    name: 'Finley Brooks',
    alias: 'engineering.mentor',
    role: 'mentor',
    subject: 'Engineering',
    year: 4,
    bio: 'I completed an engineering placement last year. I can help with group projects, managing deadlines and placement applications.',
    interests: ['Career planning', 'Study skills', 'Settling in'],
    languages: ['English'],
    colour: 'peach',
    approved: true,
    flagged: false,
    capacity: 2,
    waitingDays: 0,
  },
  {
    id: 'ellis',
    name: 'Ellis Morgan',
    alias: 'psychology.mentor',
    role: 'mentor',
    subject: 'Psychology',
    year: 3,
    bio: 'I can help with psychology coursework, revision schedules and balancing study with other commitments.',
    interests: ['Wellbeing', 'Study skills', 'Settling in'],
    languages: ['English', 'Spanish'],
    colour: 'lilac',
    approved: true,
    flagged: false,
    capacity: 2,
    waitingDays: 0,
  },
  {
    id: 'noa',
    name: 'Noa Patel',
    alias: 'business.mentor',
    role: 'mentor',
    subject: 'Business',
    year: 2,
    bio: 'I moved to Sheffield from abroad. I can answer questions about student societies, accommodation and applying for internships.',
    interests: ['International life', 'Career planning', 'Settling in'],
    languages: ['English', 'Hindi'],
    colour: 'sky',
    approved: true,
    flagged: false,
    capacity: 2,
    waitingDays: 0,
  },
  {
    id: 'jules',
    name: 'Jules Laurent',
    alias: 'placement.mentor',
    role: 'mentor',
    subject: 'Computer science',
    year: 4,
    bio: 'I recently completed a software development placement. I can review portfolios and help with coding projects and interview preparation.',
    interests: ['Coding', 'Career planning', 'Study skills'],
    languages: ['English', 'French'],
    colour: 'butter',
    approved: true,
    flagged: false,
    capacity: 2,
    waitingDays: 0,
  },
  {
    id: 'robin',
    name: 'Robin Ellis',
    alias: 'support.admin',
    role: 'admin',
    subject: 'Student support',
    year: 0,
    bio: 'Reviews account applications, support requests and reports for the mentoring programme.',
    interests: [],
    languages: ['English'],
    colour: 'sage',
    approved: true,
    flagged: false,
    capacity: 0,
    waitingDays: 0,
  },
  {
    id: 'luca',
    name: 'Luca Martin',
    alias: 'web.dev.student',
    role: 'mentee',
    subject: 'Computer science',
    year: 1,
    bio: 'Interested in web development and joining the climbing society.',
    interests: ['Coding', 'Wellbeing'],
    languages: ['English'],
    colour: 'sky',
    approved: true,
    flagged: false,
    capacity: 0,
    waitingDays: 0,
  },
  {
    id: 'zoe',
    name: 'Zoe Taylor',
    alias: 'cs.firstyear',
    role: 'mentee',
    subject: 'Computer science',
    year: 1,
    bio: 'I’d like help planning my weekly study schedule and keeping up with lectures.',
    interests: ['Study skills', 'Settling in'],
    languages: ['English'],
    colour: 'lilac',
    approved: true,
    flagged: false,
    capacity: 0,
    waitingDays: 0,
  },
  {
    id: 'theo',
    name: 'Theo James',
    alias: 'engineering.student',
    role: 'mentee',
    subject: 'Engineering',
    year: 1,
    bio: 'Looking for advice on first-year engineering modules and student societies.',
    interests: ['Settling in', 'Study skills'],
    languages: ['English', 'Spanish'],
    colour: 'peach',
    approved: true,
    flagged: false,
    capacity: 0,
    waitingDays: 9,
  },
  {
    id: 'lily',
    name: 'Lily Ahmed',
    alias: 'psychology.student',
    role: 'mentee',
    subject: 'Psychology',
    year: 1,
    bio: 'Looking for advice on psychology coursework and revision.',
    interests: ['Wellbeing', 'Study skills'],
    languages: ['English'],
    colour: 'rose',
    approved: false,
    flagged: false,
    capacity: 0,
    waitingDays: 0,
  },
  {
    id: 'samir',
    name: 'Samir Shah',
    alias: 'business.year3',
    role: 'mentor',
    subject: 'Business',
    year: 3,
    bio: 'I can help with business coursework, placement applications and choosing student societies.',
    interests: ['Career planning', 'Settling in'],
    languages: ['English', 'Hindi'],
    colour: 'butter',
    approved: false,
    flagged: false,
    capacity: 2,
    waitingDays: 0,
  },
]

export function initialState(): DemoState {
  return {
    people: structuredClone(people),
    matches: [
      {
        id: 'match-luca',
        mentor: 'maya',
        mentee: 'luca',
        message: 'Could you help me plan my first coding project?',
        status: 'active',
      },
      {
        id: 'match-zoe',
        mentor: 'maya',
        mentee: 'zoe',
        message:
          'I’m struggling to keep up with lectures and assignments. Could you help me plan a weekly study schedule?',
        status: 'pending',
      },
    ],
    notices: [
      {
        id: 'welcome-ava',
        recipient: 'ava',
        title: 'Profile ready',
        detail:
          'Browse available mentors and send a request. Include a short introduction explaining what you want help with.',
        read: false,
      },
      {
        id: 'request-zoe',
        recipient: 'maya',
        title: 'New mentoring request',
        detail:
          'cs.firstyear sent you a mentoring request. Read their introduction in My connections.',
        read: false,
      },
      {
        id: 'welcome-admin',
        recipient: 'robin',
        title: 'Accounts awaiting approval',
        detail: 'Two accounts are awaiting approval. Open Account approvals to review them.',
        read: false,
      },
    ],
    tickets: [
      {
        id: 'ticket-luca',
        author: 'luca',
        target: '',
        type: 'question',
        detail: 'Where can I find some ideas for our first mentoring meeting?',
        resolved: false,
      },
    ],
    maxCapacity: 4,
    semesterEnded: false,
  }
}

const id = z.string().min(1).max(80)
const text = z.string().trim().min(1).max(1000)
export const actionSchema = z.discriminatedUnion('type', [
  z.object({ type: z.literal('apply'), actor: id, mentor: id, message: text }),
  z.object({ type: z.literal('decide'), actor: id, match: id, accept: z.boolean() }),
  z.object({ type: z.literal('waitlist'), actor: id, mentee: id }),
  z.object({ type: z.literal('capacity'), actor: id, capacity: z.number().int().min(1).max(4) }),
  z.object({
    type: z.literal('profile'),
    actor: id,
    bio: z.string().trim().min(1).max(500),
    interests: z
      .array(z.enum(topics as [string, ...string[]]))
      .min(1)
      .max(6),
    languages: z
      .array(z.enum(languageOptions as [string, ...string[]]))
      .min(1)
      .max(5),
  }),
  z.object({
    type: z.literal('ticket'),
    actor: id,
    target: z.string().max(80),
    kind: z.enum(['question', 'report', 'withdrawal']),
    detail: text,
  }),
  z.object({
    type: z.literal('resolve'),
    actor: id,
    ticket: id,
    decision: z.enum(['resolve', 'dismiss', 'flag', 'approve-withdrawal']),
  }),
  z.object({ type: z.literal('approve'), actor: id, person: id }),
  z.object({ type: z.literal('flag'), actor: id, person: id, flagged: z.boolean() }),
  z.object({ type: z.literal('read'), actor: id, notice: id }),
  z.object({ type: z.literal('settings'), actor: id, capacity: z.number().int().min(1).max(4) }),
  z.object({ type: z.literal('end-semester'), actor: id }),
])
export type Action = z.infer<typeof actionSchema>
export type Result = { state: DemoState; error?: string }

export const personById = (state: DemoState, id: string) => state.people.find((p) => p.id === id)!
export const activeMatches = (state: DemoState, id: string) =>
  state.matches.filter((m) => m.status === 'active' && (m.mentee === id || m.mentor === id))
export const freePlaces = (state: DemoState, mentor: Person) =>
  Math.max(0, Math.min(state.maxCapacity, mentor.capacity) - activeMatches(state, mentor.id).length)
export const isAvailable = (state: DemoState, p: Person) =>
  p.approved &&
  !p.flagged &&
  !state.semesterEnded &&
  (p.role === 'mentor' ? freePlaces(state, p) > 0 : activeMatches(state, p.id).length === 0)
export const wordCount = (value: string) => value.trim().split(/\s+/).filter(Boolean).length
export const visibleName = (state: DemoState, viewer: string, person: Person) =>
  viewer === person.id ||
  personById(state, viewer).role === 'admin' ||
  activeMatches(state, viewer).some((m) => m.mentor === person.id || m.mentee === person.id)
    ? person.name
    : person.alias

/** Business rules are illustrative, not a server-side authorization boundary. */
export function transition(current: DemoState, input: Action): Result {
  const parsed = actionSchema.safeParse(input)
  if (!parsed.success) return { state: current, error: 'Check your details and try again.' }
  const action = parsed.data
  const state = structuredClone(current)
  const actor = personById(state, action.actor)
  const fail = (error: string): Result => ({ state: current, error })
  if (!actor || !actor.approved || actor.flagged)
    return fail('This demo account is not available for this action.')
  const notify = (recipient: string, title: string, detail: string) =>
    state.notices.unshift({
      id: `notice-${state.notices.length + 1}`,
      recipient,
      title,
      detail,
      read: false,
    })
  const accept = (match: Match): string | undefined => {
    const mentor = personById(state, match.mentor)
    const mentee = personById(state, match.mentee)
    if (!isAvailable(state, mentor) || !isAvailable(state, mentee))
      return 'This mentor or mentee is no longer available.'
    match.status = 'active'
    state.matches
      .filter((m) => m.mentee === match.mentee && m.id !== match.id && m.status === 'pending')
      .forEach((m) => {
        m.status = 'cancelled'
      })
    mentee.waitingDays = 0
    notify(
      mentee.id,
      'Mentoring request accepted',
      `${mentor.name} accepted your request. You can now see each other’s full profiles in My connections.`,
    )
    notify(
      mentor.id,
      'Mentee added',
      `You’re now mentoring ${mentee.name}. Their profile is available in My connections.`,
    )
  }
  switch (action.type) {
    case 'apply': {
      const mentor = personById(state, action.mentor)
      if (actor.role !== 'mentee' || !mentor || mentor.role !== 'mentor')
        return fail('Choose an available mentor.')
      if (!isAvailable(state, actor) || !isAvailable(state, mentor))
        return fail('This connection is no longer available.')
      if (wordCount(action.message) > 100)
        return fail('Keep your introduction to 100 words or fewer.')
      if (
        state.matches.some(
          (m) =>
            m.mentee === actor.id &&
            m.mentor === mentor.id &&
            ['pending', 'active'].includes(m.status),
        )
      )
        return fail('You’ve already sent this mentor a request.')
      state.matches.unshift({
        id: `match-${state.matches.length + 1}`,
        mentor: mentor.id,
        mentee: actor.id,
        message: action.message,
        status: 'pending',
      })
      notify(
        mentor.id,
        'New mentoring request',
        `${actor.alias} sent you a mentoring request. Read their introduction in My connections.`,
      )
      notify(
        actor.id,
        'Request sent',
        `Your request to ${mentor.alias} is pending. Their response will appear in this inbox.`,
      )
      break
    }
    case 'decide': {
      const match = state.matches.find((m) => m.id === action.match)
      if (
        actor.role !== 'mentor' ||
        !match ||
        match.mentor !== actor.id ||
        match.status !== 'pending'
      )
        return fail('This request is no longer available.')
      if (action.accept) {
        const error = accept(match)
        if (error) return fail(error)
      } else {
        match.status = 'declined'
        notify(
          match.mentee,
          'Request declined',
          `${actor.alias} declined your request. You can send a request to another available mentor.`,
        )
      }
      break
    }
    case 'waitlist': {
      const mentee = personById(state, action.mentee)
      if (actor.role !== 'mentor' || !mentee || mentee.role !== 'mentee' || mentee.waitingDays < 7)
        return fail('Choose a mentee from the waitlist.')
      const match: Match = {
        id: `match-${state.matches.length + 1}`,
        mentor: actor.id,
        mentee: mentee.id,
        message: 'Matched through the mentee waitlist.',
        status: 'pending',
      }
      const error = accept(match)
      if (error) return fail(error)
      state.matches.unshift(match)
      break
    }
    case 'capacity':
      if (
        actor.role !== 'mentor' ||
        action.capacity > state.maxCapacity ||
        action.capacity < activeMatches(state, actor.id).length
      )
        return fail(
          'Capacity must cover your active connections and stay within the community limit.',
        )
      actor.capacity = action.capacity
      break
    case 'profile':
      actor.bio = action.bio
      actor.interests = [...new Set(action.interests)]
      actor.languages = [...new Set(action.languages)]
      break
    case 'ticket': {
      const target = personById(state, action.target)
      if (action.kind === 'question' && action.target !== '')
        return fail('A general question does not need a target account.')
      if (action.kind !== 'question' && (!target || target.id === actor.id))
        return fail('Choose a person for this request.')
      if (
        action.kind === 'withdrawal' &&
        !activeMatches(state, actor.id).some(
          (m) => m.mentee === action.target || m.mentor === action.target,
        )
      )
        return fail('A withdrawal needs an active connection.')
      if (
        state.tickets.some(
          (t) =>
            t.author === actor.id &&
            t.target === action.target &&
            t.type === action.kind &&
            !t.resolved,
        )
      )
        return fail('You already have an open request of this type.')
      state.tickets.unshift({
        id: `ticket-${state.tickets.length + 1}`,
        author: actor.id,
        target: action.target,
        type: action.kind,
        detail: action.detail,
        resolved: false,
      })
      notify(
        'robin',
        'New support request',
        `A new ${action.kind} request is ready to review at the support desk.`,
      )
      notify(
        actor.id,
        'Support request submitted',
        'Switch to the administrator view and open Support desk to review this request.',
      )
      break
    }
    case 'resolve': {
      const ticket = state.tickets.find((t) => t.id === action.ticket)
      if (actor.role !== 'admin' || !ticket || ticket.resolved)
        return fail('This request is no longer open.')
      const allowed =
        ticket.type === 'withdrawal'
          ? ['approve-withdrawal', 'dismiss']
          : ticket.type === 'report'
            ? ['flag', 'dismiss']
            : ['resolve']
      if (!allowed.includes(action.decision))
        return fail('Choose an appropriate outcome for this request.')
      if (action.decision === 'approve-withdrawal') {
        const match = activeMatches(state, ticket.author).find(
          (m) => m.mentor === ticket.target || m.mentee === ticket.target,
        )
        if (!match) return fail('This connection has already ended. Dismiss the request instead.')
        match.status = 'cancelled'
        notify(
          ticket.target,
          'Connection ended',
          'The support team approved a withdrawal. Your mentoring availability has been updated.',
        )
      }
      if (action.decision === 'flag') {
        const target = personById(state, ticket.target)
        if (!target || target.role === 'admin')
          return fail('This account cannot be flagged in the demo.')
        target.flagged = true
        notify(
          target.id,
          'Account flagged',
          'A report was reviewed by the community team. New activity is paused until the flag is cleared.',
        )
      }
      ticket.resolved = true
      ticket.outcome =
        action.decision === 'approve-withdrawal'
          ? 'Withdrawal approved'
          : action.decision === 'flag'
            ? 'Account flagged'
            : action.decision === 'dismiss'
              ? 'Dismissed'
              : 'Resolved. Suggested agenda: introductions, mentoring goals and a date for the next meeting.'
      notify(ticket.author, 'Support request updated', ticket.outcome)
      break
    }
    case 'approve': {
      const person = personById(state, action.person)
      if (actor.role !== 'admin' || !person || person.approved)
        return fail('This account is no longer awaiting approval.')
      person.approved = true
      notify(
        person.id,
        'Account approved',
        'Your account was approved. You can now use mentoring requests and matching.',
      )
      break
    }
    case 'flag': {
      const person = personById(state, action.person)
      if (actor.role !== 'admin' || !person || person.role === 'admin')
        return fail('This account cannot be changed in the demo.')
      person.flagged = action.flagged
      notify(
        person.id,
        action.flagged ? 'Account flagged' : 'Account flag cleared',
        action.flagged
          ? 'The community team paused new activity on your account.'
          : 'The community team has cleared your account flag.',
      )
      break
    }
    case 'read': {
      state.notices
        .filter(
          (n) => n.recipient === actor.id && (action.notice === 'all' || n.id === action.notice),
        )
        .forEach((n) => {
          n.read = true
        })
      break
    }
    case 'settings':
      if (actor.role !== 'admin')
        return fail('Open the administrator view to change community settings.')
      if (
        state.people.some(
          (p) => p.role === 'mentor' && activeMatches(state, p.id).length > action.capacity,
        )
      )
        return fail('The limit must cover every mentor’s active connections.')
      state.maxCapacity = action.capacity
      break
    case 'end-semester':
      if (actor.role !== 'admin' || state.semesterEnded)
        return fail('This semester has already ended.')
      state.semesterEnded = true
      state.matches.forEach((m) => {
        if (m.status === 'active' || m.status === 'pending') {
          m.status = m.status === 'active' ? 'completed' : 'cancelled'
          notify(
            m.mentee,
            'Semester completed',
            'The semester has ended. Your connection has been archived.',
          )
          notify(
            m.mentor,
            'Semester completed',
            'The semester has ended. Your connection has been archived.',
          )
        }
      })
      break
  }
  return { state }
}

// Persist a validated action log, never hydrate arbitrary user objects from storage.
export const STORAGE_KEY = 'uniconnect-demo-v1'
export const MAX_ACTIONS = 400
export const MAX_STORAGE_LENGTH = 200_000
export function restore(raw: string | null): { state: DemoState; actions: Action[] } {
  const fresh = { state: initialState(), actions: [] as Action[] }
  if (!raw || raw.length > MAX_STORAGE_LENGTH) return fresh
  try {
    const parsed = z
      .object({ version: z.literal(1), actions: z.array(actionSchema).max(MAX_ACTIONS) })
      .safeParse(JSON.parse(raw))
    if (!parsed.success) return fresh
    let state = fresh.state
    for (const action of parsed.data.actions) {
      const result = transition(state, action)
      if (result.error) return fresh
      state = result.state
    }
    return { state, actions: parsed.data.actions }
  } catch {
    return fresh
  }
}
