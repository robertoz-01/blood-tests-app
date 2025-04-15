import * as Vue from "vue"

import VueApexCharts from "vue3-apexcharts"


const listRoot = "#blood-checks-comparison"
const element = document.querySelector(listRoot)

if (element !== null) {
    const analyses = pageAnalyses; // {id: number, name: str, unit: str, reference_upper: number, reference_lower: number}[]
    const bloodChecksValues = pageBloodChecksValues; // {identifier: str, check_date: str, values: {[analysis_id: number]: number}}[]

    const app = Vue.createApp({
        name: "Comparison-App",
        data() {
            return {
                bloodChecksValues: bloodChecksValues,
                analyses: analyses
            }
        },
        computed: {
            analysesDates() {
                return this.bloodChecksValues.map(check => check.check_date);
            },
            analysesRows() {
                return this.analyses.map((analysis) => {
                    const values = this.bloodChecksValues.map(check => check.values[analysis.id]);

                    let y_min = null;
                    let y_max = null;
                    if (analysis.reference_lower !== null && analysis.reference_upper !== null) {
                        const rangeSize = analysis.reference_upper - analysis.reference_lower;
                        y_min = Math.max(0, Math.min(analysis.reference_lower, ...values) - rangeSize * 0.2);
                        y_max = Math.max(analysis.reference_upper, ...values) + rangeSize * 0.2;
                    }


                    return {
                        id: analysis.id,
                        name: analysis.name,
                        details: `${analysis.reference_lower} - ${analysis.reference_upper} ${analysis.unit}`,
                        values: values.map(value => {
                            return {
                                value: value,
                                out_of_range: (analysis.reference_lower !== null && value <= analysis.reference_lower) ||
                                    (analysis.reference_upper !== null && value >= analysis.reference_upper)
                            }
                        }),
                        chartOptions: {
                            chart: {
                                id: `chart-${analysis.id}`,
                            },
                            labels: this.analysesDates,
                            yaxis: {
                                min: y_min,
                                max: y_max,
                            },
                            annotations: {
                                yaxis: [{
                                    y: analysis.reference_lower,
                                    y2: analysis.reference_upper,
                                    strokeDashArray: 0,
                                    fillColor: '#c9ffff',
                                    borderColor: '#775DD0',
                                    label: {
                                        borderColor: '#775DD0',
                                        style: {
                                            color: '#fff',
                                            background: '#775DD0',
                                        },
                                    }
                                }]
                            },
                        },
                        series: [{
                            name: 'values',
                            data: values
                        }]
                    }
                })
            }
        }
    })

    app.use(VueApexCharts);

    app.mount(listRoot)
}