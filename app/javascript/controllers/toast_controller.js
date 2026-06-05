import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toast"
export default class extends Controller {
  connect() {
    this._boundShow = (e) => this.show(e)
    window.addEventListener('toast', this._boundShow)
  }

  disconnect() {
    window.removeEventListener('toast', this._boundShow)
  }

  show(event) {
    const message = event.detail?.message || 'Повідомлення'
    const el = document.createElement('div')
    el.className = 'transition-opacity duration-500 fixed top-6 right-6 bg-zinc-900 text-white px-4 py-2 rounded shadow-lg ring-1 ring-orange-500'
    el.innerText = message
    document.body.appendChild(el)
    // auto-hide
    setTimeout(() => {
      el.classList.add('opacity-0')
    }, 3000)
    setTimeout(() => {
      el.remove()
    }, 3800)
  }
}
