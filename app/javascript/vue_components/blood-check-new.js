import * as Vue from "vue"

const pageRoot = "#blood-check-new"
const element = document.querySelector(pageRoot)

if (element !== null) {
    let bloodCheck = pageBloodCheck; // Coming from the page inline javascript

    const app = Vue.createApp({
        name: "BloodCheckNew-App",
        data() {
            return {
                bloodCheck: bloodCheck,
                saveFailed: false,
                errors: []
            }
        },
        methods: {
            onSubmit() {
                const postData = {
                    blood_check: {
                        check_date: this.bloodCheck.check_date,
                        notes: this.bloodCheck.notes,
                    }
                };

                fetch("/blood_checks", {
                    method: "POST",
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                    },
                    body: JSON.stringify(postData),
                })
                    .then((response) => {
                        if (response.ok) {
                            response.json().then((user_data) => {
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
            }
        }
    })
    app.mount(pageRoot)
}