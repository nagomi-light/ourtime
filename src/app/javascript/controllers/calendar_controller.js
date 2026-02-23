import { Controller } from "@hotwired/stimulus"
import { Calendar } from "@fullcalendar/core"
import dayGridPlugin from "@fullcalendar/daygrid"
import interactionPlugin from "@fullcalendar/interaction"

export default class extends Controller {
  connect() {
    this.calendar = new Calendar(this.element, {
      plugins: [dayGridPlugin, interactionPlugin],
      initialView: "dayGridMonth",
      locale: "ja",
      events: "/events.json",

      height: 700, 
      expandRows: true,   
      fixedWeekCount: false,   
      dayMaxEventRows: true,

      eventClick: function(info) {
        Turbo.visit(`/events/${info.event.id}`)
      }
    })

    this.calendar.render()

    requestAnimationFrame(() => {
      this.calendar.updateSize()
    })
  }

  disconnect() {
    this.calendar?.destroy()
  }
}

