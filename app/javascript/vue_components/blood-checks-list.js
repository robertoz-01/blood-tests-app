import * as Vue from "vue"

const listRoot = "#blood-checks-list"
const element = document.querySelector(listRoot)

if (element !== null) {
    let bloodChecks = pageBloodChecks; // Coming from the page inline javascript
    bloodChecks = bloodChecks.map(function (item) {
        item.comparisonSelected = false;
        return item;
    });

    const app = Vue.createApp({
        data() {
            return {bloodChecks: bloodChecks}
        },
        computed: {
            selectedBloodChecks() {
                return this.bloodChecks.filter(check => check.comparisonSelected);
            }
        }
    })
    app.mount(listRoot)
}