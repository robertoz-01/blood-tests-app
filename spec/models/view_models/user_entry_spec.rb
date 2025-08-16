require 'rails_helper'

describe ViewModels::UserEntry do
  describe ".from_check_entry" do
    let(:identifier_uuid) { SecureRandom.uuid }

    it "builds a ViewModel::UserEntry" do
      # Given
      analysis = Analysis.new(
        id: 5,
        default_name: "Red blood cells",
        other_names: [ "Erythrocytes" ],
        unit: "x10^6/ml",
        reference_upper: 4.7,
        reference_lower: 5.8
      )
      check_entry = CheckEntry.new(
        identifier: identifier_uuid,
        value: 123.45,
        analysis: analysis,
      )

      # When
      view_model = ViewModels::UserEntry.from_check_entry(check_entry)

      # Then
      expect(view_model.identifier).to eq(identifier_uuid)
      expect(view_model.name).to eq("Red blood cells")
      expect(view_model.value).to eq(123.45)
      expect(view_model.unit).to eq("x10^6/ml")
      expect(view_model.reference_upper).to eq(4.7)
      expect(view_model.reference_lower).to eq(5.8)
    end
  end

  describe ".from_blood_check" do
    it "builds a list of ViewModel::UserEntry" do
      # Given
      red_cells_entry = CheckEntry.new(
        value: 4.4,
        analysis: Analysis.new(default_name: "Red blood cells",),
      )
      white_cells_entry = CheckEntry.new(
        value: 5.5,
        analysis: Analysis.new(default_name: "White blood cells",),
      )
      blood_check = BloodCheck.new(check_entries: [ red_cells_entry, white_cells_entry ])

      # When
      view_models = ViewModels::UserEntry.from_blood_check(blood_check)

      # Then
      expect(view_models[0].name).to eq("Red blood cells")
      expect(view_models[0].value).to eq(4.4)
      expect(view_models[1].name).to eq("White blood cells")
      expect(view_models[1].value).to eq(5.5)
    end
  end
end
