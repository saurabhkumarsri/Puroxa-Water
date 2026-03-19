import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["wave"]

  connect() {
    this.handleScroll = this.handleScroll.bind(this)
    window.addEventListener("scroll", this.handleScroll)
  }

  disconnect() {
    window.removeEventListener("scroll", this.handleScroll)
  }

  handleScroll() {
    const scrollY = window.scrollY

    // Scroll se wave speed / movement change
    const move = scrollY * 0.2

    this.waveTargets.forEach((el, index) => {
      el.style.transform = `translateX(${move * (index + 1)}px)`
    })
  }
}