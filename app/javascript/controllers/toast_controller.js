import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toast"]

  connect() {
    this.toast = new bootstrap.Toast(this.toastTarget).show()
  }
}
