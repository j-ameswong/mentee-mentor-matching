import {
  cloneElement,
  isValidElement,
  useEffect,
  useId,
  useRef,
  type ReactElement,
  type ReactNode,
} from 'react'
import { ArrowRight, Check, Compass, Sprout, X, type LucideIcon } from 'lucide-react'
import type { Person } from '../demo/model'

export function Avatar({
  person,
  size = '',
  named = false,
}: {
  person: Person
  size?: 'large' | 'small' | ''
  named?: boolean
}) {
  return (
    <span className={`avatar ${person.colour} ${size}`} aria-hidden="true">
      {named ? (
        person.name
          .split(' ')
          .map((s) => s[0])
          .join('')
      ) : (
        <Sprout strokeWidth={1.45} />
      )}
    </span>
  )
}

export function Badge({ children, tone = 'neutral' }: { children: ReactNode; tone?: string }) {
  return <span className={`badge ${tone}`}>{children}</span>
}

export function PageHeading({
  title,
  description,
  action,
}: {
  title: string
  description: string
  action?: ReactNode
}) {
  return (
    <div className="page-heading">
      <div>
        <h1 tabIndex={-1}>{title}</h1>
        <p className="page-description">{description}</p>
      </div>
      {action}
    </div>
  )
}

export function EmptyState({
  title,
  children,
  action,
}: {
  title: string
  children: ReactNode
  action?: ReactNode
}) {
  return (
    <div className="empty-state">
      <span className="empty-icon">
        <Compass />
      </span>
      <h3>{title}</h3>
      <p>{children}</p>
      {action}
    </div>
  )
}

export function Stat({
  icon: Icon,
  label,
  value,
  note,
}: {
  icon: LucideIcon
  label: string
  value: string | number
  note: string
}) {
  return (
    <div className="stat">
      <span className="stat-icon">
        <Icon size={20} />
      </span>
      <span className="stat-label">{label}</span>
      <strong>{value}</strong>
      <span className="stat-note">{note}</span>
    </div>
  )
}

export function Modal({
  title,
  children,
  onClose,
  wide = false,
}: {
  title: string
  children: ReactNode
  onClose: () => void
  wide?: boolean
}) {
  const ref = useRef<HTMLDialogElement>(null)
  const id = useId()
  useEffect(() => {
    const dialog = ref.current!
    const previous = document.activeElement as HTMLElement | null
    dialog.showModal()
    dialog.querySelector<HTMLElement>('textarea, input, select')?.focus()
    return () => {
      dialog.close()
      previous?.focus()
    }
  }, [])
  return (
    <dialog
      ref={ref}
      className={`modal ${wide ? 'wide' : ''}`}
      aria-labelledby={id}
      onCancel={onClose}
      onClick={(e) => {
        if (e.target === e.currentTarget) {
          const r = e.currentTarget.getBoundingClientRect()
          if (
            e.clientX < r.left ||
            e.clientX > r.right ||
            e.clientY < r.top ||
            e.clientY > r.bottom
          )
            onClose()
        }
      }}
    >
      <div className="modal-head">
        <h2 id={id}>{title}</h2>
        <button className="icon-button" aria-label="Close dialog" onClick={onClose}>
          <X size={20} />
        </button>
      </div>
      {children}
    </dialog>
  )
}

export function Field({
  label,
  children,
  hint,
}: {
  label: string
  children: ReactNode
  hint?: string
}) {
  const id = useId()
  return (
    <div className="field">
      <label htmlFor={id}>{label}</label>
      {isValidElement(children)
        ? cloneElement(children as ReactElement<{ id?: string; 'aria-describedby'?: string }>, {
            id,
            'aria-describedby': hint ? `${id}-hint` : undefined,
          })
        : children}
      {hint && <small id={`${id}-hint`}>{hint}</small>}
    </div>
  )
}

export function Checklist({ items }: { items: string[] }) {
  return (
    <ul className="checklist">
      {items.map((item) => (
        <li key={item}>
          <Check size={16} />
          {item}
        </li>
      ))}
    </ul>
  )
}

export function TextLink({ children, onClick }: { children: ReactNode; onClick: () => void }) {
  return (
    <button className="text-link" onClick={onClick}>
      {children}
      <ArrowRight size={16} />
    </button>
  )
}

export function ConnectionArt() {
  return (
    <div className="connection-art" aria-hidden="true">
      <div className="orbit orbit-one" />
      <div className="orbit orbit-two" />
      <span className="art-spark spark-one">✳</span>
      <span className="art-spark spark-two">✦</span>
      <div className="art-card art-card-one">
        <span className="art-avatar sage">
          <Sprout size={30} strokeWidth={1.5} />
        </span>
        <span className="art-line" />
        <span className="art-line short" />
        <span className="art-chip">Mentor</span>
      </div>
      <span className="connection-check">
        <Check size={22} strokeWidth={2.5} />
      </span>
      <div className="art-card art-card-two">
        <span className="art-avatar peach">
          <Compass size={30} strokeWidth={1.5} />
        </span>
        <span className="art-line" />
        <span className="art-line short" />
        <span className="art-chip">Mentee</span>
      </div>
      <span className="art-caption">Request accepted</span>
    </div>
  )
}
