import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
  console.log("sidebar connected")
}

  toggleMembers(event) {
    const button = event.currentTarget
    const teamId = button.dataset.teamId

    const list = document.getElementById(`team-members-${teamId}`)
    if (!list) return

    list.classList.toggle("hidden")

    button.textContent =
      list.classList.contains("hidden") ? "▸" : "▾"
  }

  toggleTeam(event) {
    const checked = event.target.checked
    const teamId = event.target.value

    const members = document.querySelectorAll(
      `#team-members-${teamId} .user-toggle`
    )

    members.forEach(el => el.checked = checked)

    this.triggerFilter()
  }


  triggerFilter() {
    const activeTeams = Array.from(
      this.element.querySelectorAll(".team-toggle:checked")
    ).map(el => Number(el.value))

    const activeUsers = Array.from(
      this.element.querySelectorAll(".user-toggle:checked")
    ).map(el => Number(el.value))

    this.dispatch("filter", {
      detail: {
        teams: activeTeams,
        users: activeUsers
      },
      target: window
    })
  }

  selectAll() {
    this.element.querySelectorAll("input[type='checkbox']")
      .forEach(el => el.checked = true)

    this.triggerFilter()
  }

  clearAll() {
    this.element.querySelectorAll("input[type='checkbox']")
      .forEach(el => el.checked = false)

    this.triggerFilter()
  }
}