import * as Vue from "vue"

const pageRoot = "#blood-check-new"
const element = document.querySelector(pageRoot)

if (element !== null) {
    let bloodCheck = pageBloodCheck; // Coming from the page inline javascript
    let entries = pageEntries; // Coming from the page inline javascript

    const app = Vue.createApp({
        name: "BloodCheckNew-App",
        data() {
            return {
                // bloodCheck: {identifier: str, check_date: str, notes: str}
                bloodCheck: bloodCheck,
                // entries: list[
                //   {identifier: str, name: str, value: number, unit: str, reference: str,
                //     messages: list[{field: str, level: "info"|"warning", text: str}]
                //   }
                // ]
                entries: entries,
                saveFailed: false,
                errors: []
            }
        },
        computed: {
            isNew() {
                return this.bloodCheck.identifier === null
            }
        },
        methods: {
            onSubmit() {
                const postData = {
                    blood_check: {
                        check_date: this.bloodCheck.check_date,
                        notes: this.bloodCheck.notes,
                    },
                    entries: this.entries,
                };

                const fetchUrl = this.isNew ? "/blood_checks" : `/blood_checks/${this.bloodCheck.identifier}`;
                const fetchMethod = this.isNew ? "POST" : "PATCH";
                fetch(fetchUrl, {
                    method: fetchMethod,
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                    },
                    body: JSON.stringify(postData),
                })
                    .then((response) => {
                        if (response.ok) {
                            response.json().then((user_data) => {
                                this.bloodCheck = user_data.blood_check;
                                const toastLiveExample = document.getElementById('successfulCreationToast')
                                const toastBootstrap = bootstrap.Toast.getOrCreateInstance(toastLiveExample)
                                toastBootstrap.show()
                            }).catch((err) => {
                                this.saveFailed = true;
                                console.error(err);
                            });
                        } else {
                            this.saveFailed = true;
                            console.error(`The API returned error: ${response.status}`);
                        }
                    })
                    .catch((err) => {
                        console.error(err);
                        throw err;
                    });
            },
            addEntry() {
                this.entries.push({identifier: crypto.randomUUID(), name: null, value: null, unit: null, reference: null})
            },
            deleteEntry(entry) {
                this.entries.splice(this.entries.indexOf(entry), 1)
            }
        }
    })
    app.mount(pageRoot)
}