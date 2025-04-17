require 'rails_helper'

describe ViewModels::BloodCheckValues do
  describe ".from_blood_check" do
    let(:identifier_uuid) { "48b614b5-c4dc-424c-939d-7c22d98f38fd" }

    it "builds a ViewModel::BloodCheckValues with the check entries values" do
      # Given
      blood_check = BloodCheck.new(
        identifier: identifier_uuid,
        check_date: Date.new(2018, 1, 1),
        notes: "Some notes",
        check_entries: [
          CheckEntry.new(
            identifier: SecureRandom.uuid,
            analysis_id: 1,
            value: 33
          ),
          CheckEntry.new(
            identifier: SecureRandom.uuid,
            analysis_id: 5,
            value: 123.45
          )
        ]
      )

      # When
      view_model = ViewModels::BloodCheckValues.from_blood_check(blood_check)

      # Then
      expect(view_model.identifier).to eq(identifier_uuid)
      expect(view_model.check_date).to eq("2018-01-01")
      expect(view_model.values).to eq({ 1 => 33,  5 => 123.45 })
    end
  end
end
