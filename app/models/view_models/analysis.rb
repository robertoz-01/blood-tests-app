# frozen_string_literal: true

# It corresponds to the javascript type {id: number, name: str, unit: str, reference_upper: number, reference_lower: number}
# used in the Vue app
module ViewModels
  class Analysis
    include ActiveModel::API
    attr_accessor :id, :name, :unit, :reference_upper, :reference_lower

    def self.from_analysis_model(analysis)
        new(
          id: analysis.id,
          name: analysis.default_name,
          unit: analysis.unit,
          reference_upper: analysis.reference_upper,
          reference_lower: analysis.reference_lower
        )
    end
  end
end
