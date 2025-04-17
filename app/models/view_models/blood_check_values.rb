# frozen_string_literal: true

# It corresponds to the javascript type {identifier: str, check_date: str, values: {[analysis_id: number]: number}}
# used in the Vue app
module ViewModels
  class BloodCheckValues
    include ActiveModel::API
    attr_accessor :identifier, :check_date, :values

    def self.from_blood_check(blood_check)
      new(
        identifier: blood_check.identifier,
        check_date: blood_check.check_date.to_s,
        values: blood_check.check_entries.map { |entry| [ entry.analysis_id, entry.value ] }.to_h
      )
    end
  end
end
