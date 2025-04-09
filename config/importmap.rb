# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@popperjs/core", to: "popper.js", preload: true
if Rails.env.production?
  pin "vue", to: "https://unpkg.com/vue@3.5.13/dist/vue.esm-browser.prod.js"
else
  pin "vue", to: "https://unpkg.com/vue@3.5.13/dist/vue.esm-browser.js"
end
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/vue_components", under: "vue_components"
