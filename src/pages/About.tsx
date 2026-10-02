import {
  ArrowRight,
  Code2,
  Database,
  GraduationCap,
  HeartHandshake,
  Play,
  ShieldCheck,
} from 'lucide-react'
import { useDemo } from '../demo/context'
import { Badge, PageHeading } from '../components/ui'

export function About() {
  const { startTour, navigate } = useDemo()
  return (
    <>
      <PageHeading
        title="About UniConnect"
        description="A portfolio demo of a University of Sheffield mentor–mentee matching project."
      />
      <div className="about-intro panel">
        <GraduationCap size={34} strokeWidth={1.3} />
        <div>
          <Badge tone="green">University of Sheffield · COM1001 · 2024–25</Badge>
          <h2>Project background</h2>
          <p>
            Team 17 built UniConnect as a first-year group project. Students could request a mentor,
            mentors could manage their mentees, and administrators handled account approvals and
            support.
          </p>
          <p>
            The original application used Ruby, Sinatra, Sequel and SQLite. This React and
            TypeScript demo recreates the main features with fictional data stored in your browser
            tab. The original source remains in the repository.
          </p>
          <button className="button primary" onClick={startTour}>
            <Play size={15} />
            Start guided tour
            <ArrowRight size={16} />
          </button>
        </div>
      </div>
      <div className="about-grid">
        {[
          {
            icon: HeartHandshake,
            title: 'Matching rules',
            text: 'Mentors have a limited number of places. Accepting a request closes the mentee’s other pending requests and reveals contact details. Waitlisted students can be matched directly. Withdrawals require administrator approval.',
          },
          {
            icon: Database,
            title: 'Original application',
            text: 'A relational model spanning 16 tables, role-specific controllers, account approvals, match lifecycle management, and RSpec / Capybara acceptance tests.',
          },
          {
            icon: Code2,
            title: 'Portfolio demo',
            text: 'Responsive layouts, keyboard-accessible controls, typed state transitions, and an eight-step guided tour covering mentee, mentor and administrator tasks.',
          },
          {
            icon: ShieldCheck,
            title: 'Demo data',
            text: 'All accounts are fictional. Changes are stored in this tab, and you can reset them at any time. No messages are sent to real people. All sample profiles are included in the downloaded demo, even when their names are hidden in the interface.',
          },
        ].map(({ icon: Icon, title, text }) => (
          <section className="panel" key={title}>
            <Icon size={25} strokeWidth={1.5} />
            <h3>{title}</h3>
            <p>{text}</p>
          </section>
        ))}
      </div>
      <div className="about-footnote">
        <p>An independent student portfolio project. Not an official university service.</p>
        <button className="text-link" onClick={() => navigate('overview')}>
          Back to overview
          <ArrowRight size={16} />
        </button>
      </div>
    </>
  )
}
