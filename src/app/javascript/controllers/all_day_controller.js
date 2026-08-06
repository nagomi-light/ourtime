import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "checkbox",
    "timeFields",
    "dateFields",
    "timeInput",
    "dateInput"
  ]

  connect() {
    this.toggle()
  }

  toggle() {
    const allDay = this.checkboxTarget.checked

    this.timeFieldsTarget.classList.toggle("hidden", allDay)
    this.dateFieldsTarget.classList.toggle("hidden", !allDay)

    this.timeInputTargets.forEach(input => {
      input.disabled = allDay
    })

    this.dateInputTargets.forEach(input => {
      input.disabled = !allDay
    })
  }
}