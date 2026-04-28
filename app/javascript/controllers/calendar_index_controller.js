import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggleDropdown() {
    const menu = document.getElementById("view-dropdown-menu")
    if (menu) menu.classList.toggle("hidden")
  }

  closeDropdown() {
    const menu = document.getElementById("view-dropdown-menu")
    if (menu) menu.classList.add("hidden")
  }
}