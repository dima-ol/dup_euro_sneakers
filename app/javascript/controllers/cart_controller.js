import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cart"
export default class extends Controller {
  initialize() {

    console.log("cart controller initialized")
    const cart = JSON.parse(localStorage.getItem("cart"))
    if (!cart) {
      return
    }

    let total = 0
    for (let i=0; i < cart.length; i++) {
      const item = cart[i]
      total += item.price * item.quantity
      const div = document.createElement("div")
      div.classList.add("mt-2", "text-white");
      div.innerText = `Товар: ${item.name} - ${item.price} грн - Кількість: ${item.quantity}`
      const deleteButton = document.createElement("button")
      deleteButton.innerText = "Видалити"
      console.log("item.id: ", item.id)
      deleteButton.value = JSON.stringify({id: item.id, size: item.size})
      deleteButton.classList.add("bg-orange-600", "hover:bg-orange-500", "rounded", "text-white", "px-2", "py-1", "ml-2", "font-semibold", "focus:outline-none", "focus:ring-2", "focus:ring-orange-500")
      deleteButton.addEventListener("click", this.removeFromCart)
      div.appendChild(deleteButton)
      this.element.prepend(div)
    }

    const totalEl = document.createElement("div")
    totalEl.classList.add("text-white", "font-semibold", "text-lg")
    totalEl.innerText= `Підсумок: ${total} грн`
    let totalContainer = document.getElementById("total")
    totalContainer.appendChild(totalEl)
  }

  clear() {
    localStorage.removeItem("cart")
    window.dispatchEvent(new CustomEvent('toast', { detail: { message: 'Кошик очищено' } }))
    setTimeout(() => window.location.reload(), 800)
  }

  removeFromCart(event) {
    const cart = JSON.parse(localStorage.getItem("cart"))
    const values = JSON.parse(event.target.value)
    const {id, size} = values
    const index = cart.findIndex(item => item.id === id && item.size === size)
    if (index >= 0) {
      const removedItem = cart[index]
      cart.splice(index, 1)
      window.dispatchEvent(new CustomEvent('toast', { detail: { message: `${removedItem.name} видалено з кошика` } }))
    }
    localStorage.setItem("cart", JSON.stringify(cart))
    setTimeout(() => window.location.reload(), 800)
  }

  checkout() {
    window.location.href = "/checkout"
  }

}

