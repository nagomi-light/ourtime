import { Controller } from "@hotwired/stimulus"
import { Calendar } from "@fullcalendar/core"
import dayGridPlugin from "@fullcalendar/daygrid"
import interactionPlugin from "@fullcalendar/interaction"

export default class extends Controller {

  connect() {
    this.activeTeams = null
    this.activeUsers = null

    this.calendar = new Calendar(this.element, {
      plugins: [dayGridPlugin, interactionPlugin],
      initialView: "dayGridMonth",
      locale: "ja",
      events: this.fetchEvents.bind(this),

      height: "auto", 
      expandRows: false,   
      fixedWeekCount: false, 
      dayMaxEventRows: 3
    })

    this.calendar.render() 

    requestAnimationFrame(() => this.applyRowHeight())

    this.calendar.on('datesSet', () => {
      requestAnimationFrame(() => this.applyRowHeight())
    })
  }

  applyRowHeight() {
    this.element.querySelectorAll('.fc-daygrid-body tr').forEach(tr => {
       tr.style.height = '120px'
    })
  }

  filter(event) {
    this.activeTeams = event.detail.teams
    this.activeUsers = event.detail.users
    this.calendar.refetchEvents()
  }

  async fetchEvents(info, successCallback, failureCallback) {
    try {
      const response = await fetch("/events.json")
      const events = await response.json()

      const filtered = events.filter(event => {

        if (this.activeTeams && event.team_id && !this.activeTeams.includes(event.team_id)) {
          return false
        }

        if (this.activeUsers && event.user_id && !this.activeUsers.includes(event.user_id)) {
          return false
        }

        return true
      })

      successCallback(filtered)

    } catch (error) {
      failureCallback(error)
    }
  }
}
