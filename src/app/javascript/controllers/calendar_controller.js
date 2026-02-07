import { Controller } from "@hotwired/stimulus"
import { Calendar } from "@fullcalendar/core"
import dayGridPlugin from "@fullcalendar/daygrid"

export default class extends Controller {
  connect() {
    this.calendar = new Calendar(this.element, {
      plugins: [dayGridPlugin],
      initialView: "dayGridMonth",
      locale: "ja",
      events: "/events.json",

      height: 700, 
      expandRows: true,   
      fixedWeekCount: false,   
      dayMaxEventRows: true,
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

