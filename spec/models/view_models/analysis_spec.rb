require 'rails_helper'

describe ViewModels::Analysis do
  describe ".from_analysis_model" do
    it "builds a ViewModel::Analysis" do
      # Given
      analysis = Analysis.new(
        id: 5,
        default_name: "Red blood cells",
        other_names: [ "Erythrocytes" ],
        unit: "x10^6/ml",
        reference_upper: 4.7,
        reference_lower: 5.8
      )

      # When
      view_model = ViewModels::Analysis.from_analysis_model(analysis)

      # Then
      expect(view_model.id).to eq(5)
      expect(view_model.name).to eq("Red blood cells")
      expect(view_model.unit).to eq("x10^6/ml")
      expect(view_model.reference_upper).to eq(4.7)
      expect(view_model.reference_lower).to eq(5.8)
    end
  end
end
