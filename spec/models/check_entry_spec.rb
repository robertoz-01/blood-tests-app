require 'rails_helper'

RSpec.describe CheckEntry, type: :model do
  describe ".insert_user_entries" do
    let!(:blood_check) { FactoryBot.create(:blood_check) }

    context "when the analysis already exists" do
      let!(:analysis) { FactoryBot.create(:analysis, default_name: analysis_name, unit: unit) }
      let(:analysis_name) { "White Blood Cells" }
      let(:unit) { "x10^6/l" }

      it "creates only a new entry, without changes to the analysis" do
        # Given
        unit_from_entry = "x10^6/l"
        user_entry = ViewModels::UserEntry.new(
          identifier: nil,
          name: analysis_name,
          value: 4.8,
          unit: unit_from_entry,
          reference_lower: 1,
          reference_upper: 2
        )

        # When
        CheckEntry.insert_user_entries([ user_entry ], blood_check)
        blood_check.reload

        # Then
        entries = blood_check.check_entries
        expect(entries.count).to eq(1)
        expect(entries.first.analysis.default_name).to eq(analysis_name)
        expect(entries.first.analysis.unit).to eq(unit)
        expect(entries.first.value).to eq(4.8)
        expect(entries.first.identifier).to be_present
      end
    end

    context "when both analysis and check entry exist" do
      let!(:analysis) { FactoryBot.create(:analysis, default_name: analysis_name, unit: unit) }
      let(:analysis_name) { "White Blood Cells" }
      let(:unit) { "x10^6/l" }
      let!(:existing_entry) do
        FactoryBot.create(:check_entry,
                          blood_check: blood_check,
                          analysis: analysis,
                          identifier: existing_identifier,
                          value: 3.5)
      end
      let(:existing_identifier) { SecureRandom.uuid }

      it "updates only the existing entry with new value" do
        # Given
        user_entry = ViewModels::UserEntry.new(
          identifier: existing_identifier,
          name: analysis_name,
          value: 4.8,
          unit: "g/m",
          reference_lower: 1,
          reference_upper: 2
        )

        # When
        CheckEntry.insert_user_entries([ user_entry ], blood_check)
        blood_check.reload

        # Then
        entries = blood_check.check_entries
        expect(entries.count).to eq(1)
        expect(entries.first.analysis.default_name).to eq(analysis_name)
        expect(entries.first.analysis.unit).to eq(unit)
        expect(entries.first.value).to eq(4.8)
        expect(entries.first.identifier).to eq(existing_identifier)
      end
    end

    context "when neither the analysis nor the check entry exist" do
      let(:unit) { "mg/dL" }

      it "creates both analysis and check entry" do
        # Given
        user_entry = ViewModels::UserEntry.new(
          identifier: nil,
          name: "Cortisol",
          value: 7.7,
          unit: "mg/dl",
          reference_lower: 1,
          reference_upper: 2
        )

        # When
        CheckEntry.insert_user_entries([user_entry], blood_check)
        blood_check.reload

        # Then
        entries = blood_check.check_entries
        expect(entries.count).to eq(1)
        expect(entries.first.analysis.default_name).to eq("Cortisol")
        expect(entries.first.analysis.unit).to eq("mg/dl")
        expect(entries.first.value).to eq(7.7)
        expect(entries.first.identifier).to be_present
        expect(entries.first.analysis.reference_lower).to eq(1)
        expect(entries.first.analysis.reference_upper).to eq(2)
      end
    end
  end
end
